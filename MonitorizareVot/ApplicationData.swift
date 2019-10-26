//
//  ApplicationData.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 26/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class ApplicationData: NSObject {
    static let shared = ApplicationData()
    
    private override init() {
        super.init()
    }
    
    func downloadUpdatedForms(then callback: @escaping (Error?) -> Void) {
        print("Downloading new form summaries")
        let api = APIManager.shared
        api.fetchForms { (forms, error) in
            if let error = error {
                callback(error)
            } else {
                self.downloadUpdatedFormsInSet(forms ?? []) {
                    // store the new summaries
                    LocalStorage.shared.forms = forms
                    callback(nil)
                }
            }
        }
    }
    
    fileprivate func downloadUpdatedFormsInSet(_ forms: [FormResponse], then callback: @escaping () -> Void) {
        let api = APIManager.shared
        let existingForms = LocalStorage.shared.forms ?? []
        let indexedExistingForms = existingForms.reduce(into: [Int: FormResponse]()) { $0[$1.id] = $1 }
        let newForms = forms
        var formsThatNeedUpdates: [FormResponse] = []
        for form in newForms {
            if let existing = indexedExistingForms[form.id],
                existing.version >= form.version {
                continue
            }
            formsThatNeedUpdates.append(form)
        }
        
        guard formsThatNeedUpdates.count > 0 else {
            // no updates necessary
            print("No new forms")
            callback()
            return
        }
        
        print("Downloading \(formsThatNeedUpdates.count) new forms")
        var updatedFormCount = 0
        for form in formsThatNeedUpdates {
            api.fetchForm(withId: form.id) { (formSections, error) in
                updatedFormCount += 1
                if let sections = formSections, sections.count > 0 {
                    // store this
                    print("Downloaded new version for form #\(form.id). New version: \(form.version)")
                    LocalStorage.shared.saveForm(sections, withId: form.id)
                }
                if updatedFormCount == formsThatNeedUpdates.count {
                    print("Done downloading new forms.")
                    callback()
                }
            }
        }
    }
}
