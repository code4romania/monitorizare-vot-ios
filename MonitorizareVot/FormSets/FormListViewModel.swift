//
//  FormSetsViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class FormListViewModel: NSObject {
    var forms: [FormSetCellModel] = []
    
    /// Check this flag, it tells you the download state
    var isDownloadingData: Bool = false
    
    /// Check this flag, it tells you whether we're syncing or not
    var isSynchronising: Bool = false
    
    /// Get notified when new sets are downloaded
    var onDownloadComplete: ((APIError?) -> Void)?

    /// Get notified when downloading state has changed
    var onDownloadingStateChanged: (() -> Void)?

    /// Get notified when syncing state has changed
    var onSyncingStateChanged: (() -> Void)?

    // TODO: remove them when not needed anymore
    /// Use these until we completely update the API
    var legacyForms: [[String: Any]] = []
    var legacyPersistor = LocalFormsPersistor()
    
    override init() {
        super.init()
        loadCachedData()
    }
    
    func loadCachedData() {
        if let cached = LocalStorage.shared.forms {
            convertToViewModels(responses: cached)
        }
    }
    
    fileprivate func convertToViewModels(responses: [FormResponse]?) {
        if let objects = responses {
            forms = objects.map { set in
                let image = UIImage(named: "icon-formset-\(set.code.lowercased())") ?? UIImage(named: "icon-formset-default")
                let answeredQuestions = DB.shared.getAnsweredQuestions(inFormWithCode: set.code).count
                let formSections = LocalStorage.shared.loadForm(withId: set.id)
                let totalQuestions = formSections?.reduce([QuestionResponse](), { $0 + $1.questions }).count ?? 0
                let progress = totalQuestions > 0 ? CGFloat(answeredQuestions) / CGFloat(totalQuestions) : 0
                return FormSetCellModel(
                    icon: image ?? UIImage(), // just in case
                    title: set.description,
                    code: set.code.uppercased(),
                    progress: progress,
                    answeredOutOfTotalQuestions: "\(answeredQuestions)/\(totalQuestions)")
            }
        }
    }
    
    func downloadFreshData() {
        isDownloadingData = true
        APIManager.shared.fetchForms { (forms, error) in
            self.isDownloadingData = false
            self.convertToViewModels(responses: forms)
            self.onDownloadComplete?(error)
            if let forms = forms {
                // Also cache them for later
                DispatchQueue.main.async {
                    LocalStorage.shared.forms = forms
                }
            }
        }
    }
}
