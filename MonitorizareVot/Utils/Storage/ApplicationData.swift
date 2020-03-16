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
        DebugLog("Downloading new form summaries")
        
        // for diaspora we might have different forms, so first check if the user is in diaspora or not
        var isCountyDiaspora = false
        if let countyCode = PreferencesManager.shared.county,
            let stationCounty = LocalStorage.shared.getCounty(withCode: countyCode) {
            isCountyDiaspora = stationCounty.diaspora ?? false
        }
        
        let api = APIManager.shared
        api.fetchForms(diaspora: isCountyDiaspora) { (forms, error) in
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
            DebugLog("No new forms")
            callback()
            return
        }
        
        DebugLog("Downloading \(formsThatNeedUpdates.count) new forms")
        var updatedFormCount = 0
        for form in formsThatNeedUpdates {
            
            // delete any questions, answers, notes that were answered to the old form
            if let existing = indexedExistingForms[form.id] {
                deleteUserData(forForm: form.code, formVersion: existing.version)
            }
            
            api.fetchForm(withId: form.id) { (formSections, error) in
                updatedFormCount += 1
                if let sections = formSections, sections.count > 0 {
                    // store this
                    DebugLog("Downloaded new version for form #\(form.id). New version: \(form.version)")
                    LocalStorage.shared.saveForm(sections, withId: form.id)
                }
                if updatedFormCount == formsThatNeedUpdates.count {
                    DebugLog("Done downloading new forms.")
                    callback()
                }
            }
        }
    }
    
    fileprivate func deleteUserData(forForm formCode: String, formVersion: Int) {
        let questions = DB.shared.getQuestions(forForm: formCode, formVersion: formVersion)
        DB.shared.delete(questions: questions)
    }
}
