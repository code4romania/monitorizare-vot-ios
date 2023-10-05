//
//  RemoteSyncer.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

enum RemoteSyncerError: LocalizedError {
    case noConnection
    case invalidStationData
    case stationError(reason: APIError?)
    case noteError(reason: APIError?)
    case questionError(reason: APIError?)

    var errorDescription: String? {
        switch self {
        case .noConnection: return "Error.InternetConnection".localized
        case .invalidStationData: return "Error.IncorrectStationNumber".localized
        case .stationError(let reason): return "Error.StationSaveFailed".localized +  " \(reason?.localizedDescription ?? "")"
        case .noteError(let reason): return "Error.UploadNoteFailed".localized + "  \(reason?.localizedDescription ?? "")"
        case .questionError(let reason): return "Error.AnswerSaveFailed".localized + " \(reason?.localizedDescription ?? "")"
        }
    }
}

/// Will upload unsynced data to the server
class RemoteSyncer: NSObject {
    static let shared = RemoteSyncer()
    
    static let answersSyncedNotification = Notification.Name("answersSyncedNotification")
    static let notificationAnswersKey = "answers"

    var needsSync: Bool {
        return DB.shared.needsSync
    }
    
    func syncUnsyncedData(then callback: @escaping (RemoteSyncerError?) -> Void) {
        guard let section = DB.shared.currentSectionInfo() else {
            // this shouldn't happen but hey
            callback(.invalidStationData)
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
    
    func uploadUnsyncAnswersAndNotes(then callback: @escaping (RemoteSyncerError?) -> Void) {
        var errors = [RemoteSyncerError]()
        uploadUnsyncedNotes { [weak self] error in
            if let error = error {
                errors.append(error)
            }
            self?.uploadUnsyncedQuestions(then: { error in
                if let error = error {
                    errors.append(error)
                }
                callback(errors.first)
            })
        }
    }
    
    func uploadSectionInfo(_ section: SectionInfo, then callback: @escaping (RemoteSyncerError?) -> Void) {
        let sectionNumber = Int(section.sectionId)
        guard let county = section.countyCode,
              let municipality = section.municipalityCode else {
                callback(.invalidStationData)
                return
        }
        
        let dateFmt = APIManager.shared.apiDateFormatter
        let arrivalTime = section.arriveTime != nil ? dateFmt.string(from: section.arriveTime!) : ""
        let leaveTime = section.leaveTime != nil ? dateFmt.string(from: section.leaveTime!) : nil
        
        let stationRequest = UpdatePollingStationRequest(
            id: sectionNumber,
            countyCode: county,
            municipalityCode: municipality,
            arrivalTime: arrivalTime,
            numberOfVotersOnTheList: Int(section.numberOfVotersOnTheList),
            numberOfCommissionMembers: Int(section.numberOfCommissionMembers),
            numberOfFemaleMembers: Int(section.numberOfFemaleMembers),
            minPresentMembers: Int(section.minPresentMembers),
            chairmanPresence: section.chairmanPresence,
            singlePollingStationOrCommission: section.singlePollingStationOrCommission,
            adequatePollingStationSize: section.adequatePollingStationSize
        )
        
        APIManager.shared.upload(pollingStation: stationRequest) { error in
            if let error = error {
                callback(.stationError(reason: error))
            } else {
                callback(nil)
            }
        }
        
    }
    
    func uploadUnsyncedNotes(then callback: @escaping (RemoteSyncerError?) -> Void) {
        let notes = DB.shared.getAllUnsyncedNotes()
        let totalRequests = notes.count
        guard totalRequests > 0 else {
            DebugLog("No notes to upload.")
            callback(nil)
            return
        }
        var errors: [RemoteSyncerError] = []
        
        DebugLog("Uploading \(totalRequests) notes...")
        let group = DispatchGroup()
        
        for note in notes {
            let station = note.sectionInfo
            // TODO: we should guard against nil section info, the request will fail anyway
            // TODO: acccount for multiple attachments
//            let uploadRequest = UploadNoteRequest(
//                imageData: note.file as Data?,
//                questionId: note.questionID != -1 ? Int(note.questionID) : nil,
//                countyCode: station?.countyCode ?? "",
//                pollingStationId: Int(station?.sectionId ?? 0),
//                text: note.body ?? "")
//            group.enter()
//            APIManager.shared.upload(note: uploadRequest) { error in
//                if let error = error {
//                    errors.append(.noteError(reason: error))
//                    DebugLog("Failed to uploaded note: \(error.localizedDescription)")
//                } else {
//                    DebugLog("Uploaded note")
//                    
//                    // also mark it as synced
//                    note.synced = true
//                    try? CoreData.save()
//                }
//                
//                group.leave()
//            }
        }
        
        group.notify(queue: .main) {
            DebugLog("Finished upload for \(totalRequests) notes")
            callback(errors.first)
        }
    }

    func uploadUnsyncedQuestions(then callback: @escaping (RemoteSyncerError?) -> Void) {
        let questions = DB.shared.getAllUnsyncedQuestions()
        var answers: [AnswerRequest] = []
        for question in questions {
            var answerRequests: [AnswerOptionRequest] = []
            if let questionAnswers = question.answers?.allObjects as? [Answer] {
                for qAnswer in questionAnswers {
                    guard qAnswer.selected else { continue }
                    // TODO: what should be sent, text or inputText as the value?
                    let option = AnswerOptionRequest(id: Int(qAnswer.id), value: qAnswer.inputText)
                    answerRequests.append(option)
                }
            }
            let station = question.sectionInfo
            let question = AnswerRequest(
                questionId: Int(question.id),
                countyCode: station?.countyCode ?? "",
                municipalityCode: station?.municipalityCode ?? "",
                pollingStationId: Int(station?.sectionId ?? 0),
                options: answerRequests)
            answers.append(question)
        }
        
        guard answers.count > 0 else {
            DebugLog("No answers to upload.")
            callback(nil)
            return
        }
        
        let request = UploadAnswersRequest(answers: answers)
        DebugLog("Uploading answers for \(answers.count) questions...")
        APIManager.shared.upload(answers: request) { error in
            if let error = error {
                DebugLog("Uploading answers failed: \(error)")
                callback(RemoteSyncerError.questionError(reason: error))
            } else {
                DebugLog("Uploaded answers.")
                
                // update the questions sync status
                self.markQuestionsAsSynced(usingAnswers: answers)
                
                // notify any interested objects
                NotificationCenter.default.post(name: RemoteSyncer.answersSyncedNotification,
                                                object: self,
                                                userInfo: [RemoteSyncer.notificationAnswersKey: answers])
                
                callback(nil)
            }
        }
    }
    
    // MARK: - Internal
    
    fileprivate func markQuestionsAsSynced(usingAnswers answers: [AnswerRequest]) {
        do {
            // new
            let section = DB.shared.currentSectionInfo()
            assert(section != nil, "No current section!")
            guard let section else { return }
            
            for answer in answers {
                // old
//                let section = DB.shared.sectionInfo(for: answer.countyCode, sectionId: answer.pollingStationId)
                
                let question = DB.shared.getQuestion(withId: answer.questionId, inSection: section)
                question?.synced = true
            }
            try CoreData.save()
        } catch {
            DebugLog("Error: couldn't save synced status locally: \(error)")
        }
    }
}
