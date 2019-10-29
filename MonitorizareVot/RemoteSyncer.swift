//
//  RemoteSyncer.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

enum RemoteSyncerError: Error {
    case noConnection
    case invalidStationData
    case noteError(reason: String?)
    case questionError(reason: String?)
    
    var localizedDescription: String {
        // TODO: localize
        switch self {
        case .noConnection: return "No internet connection"
        case .invalidStationData: return "Invalid station data"
        case .noteError(let reason): return "Can't save note. \(reason ?? "")"
        case .questionError(let reason): return "Can't save answer to question. \(reason ?? "")"
        }
    }
}

/// Will upload unsynced data to the server
class RemoteSyncer: NSObject {
    static let shared = RemoteSyncer()
    
    var needsSync: Bool {
        return DBSyncer.shared.needsSync()
    }
    
    func syncUnsyncedData(then callback: @escaping ([RemoteSyncerError]) -> Void) {
        guard let section = DB.shared.currentSectionInfo() else {
            // this shouldn't happen but hey
            callback([])
            return
        }
        
        if !section.synced {
            uploadSectionInfo(section, then: { error in
                self.uploadUnsyncAnswersAndNotes(then: callback)
            })
        } else {
            self.uploadUnsyncAnswersAndNotes(then: callback)
        }
    }
    
    func uploadUnsyncAnswersAndNotes(then callback: @escaping ([RemoteSyncerError]) -> Void) {
        var allErrors: [RemoteSyncerError] = []
        uploadUnsyncedNotes { [weak self] errors in
            allErrors.append(contentsOf: errors)
            self?.uploadUnsyncedQuestions(then: { errors in
                allErrors.append(contentsOf: errors)
                callback(allErrors)
            })
        }
    }
    
    func uploadSectionInfo(_ section: SectionInfo, then callback: @escaping (RemoteSyncerError?) -> Void) {
        guard let stationId = Int(section.sectie ?? ""),
            let county = section.judet,
            let medium = SectionInfo.Medium(rawValue: section.medium ?? ""),
            let presidentGenre = SectionInfo.Genre(rawValue: section.genre ?? "") else {
                callback(.invalidStationData)
                return
        }
        
        // TODO: extract correct time once it's saved correctly into the db
        let arrivalTime = ""
        let leaveTime = ""
        
        let section = UpdatePollingStationRequest(
            id: stationId,
            countyCode: county,
            isUrbanArea: medium == .urban,
            leaveTime: leaveTime,
            arrivalTime: arrivalTime,
            isPresidentFemale: presidentGenre == .woman)
        
        // TODO: add actual API call once it's implemented
        
        callback(nil)
    }
    
    func uploadUnsyncedNotes(then callback: @escaping ([RemoteSyncerError]) -> Void) {
        // TODO: implement
        callback([])
    }

    func uploadUnsyncedQuestions(then callback: @escaping ([RemoteSyncerError]) -> Void) {
        guard let section = DB.shared.currentSectionInfo() else { return }
        let questions = DB.shared.getUnsyncedQuestions()
        var answers: [AnswerRequest] = []
        for question in questions {
            var answerRequests: [AnswerOptionRequest] = []
            if let questionAnswers = question.answers?.allObjects as? [Answer] {
                for qAnswer in questionAnswers {
                    guard qAnswer.selected else { continue }
                    // TODO: what should be sent, text or inputText as the value?
                    let option = AnswerOptionRequest(id: Int(qAnswer.id), value: qAnswer.text ?? "")
                    answerRequests.append(option)
                }
            }
            let question = AnswerRequest(
                questionId: Int(question.id),
                countyCode: section.judet ?? "",
                pollingStationId: Int(section.sectie ?? "") ?? 0,
                options: answerRequests)
            answers.append(question)
        }
        
        let request = UploadAnswersRequest(answers: answers)
        print("Uploading answers for \(answers.count) questions...")
        APIManager.shared.upload(answers: request) { error in
            if let error = error {
                print("Uploading answers failed: \(error)")
                callback([RemoteSyncerError.questionError(reason: error.localizedDescription)])
            } else {
                print("Uploaded answers.")
                callback([])
            }
        }
    }
}
