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
    case stationError(reason: APIError?)
    case noteError(reason: APIError?)
    case questionError(reason: APIError?)

    var localizedDescription: String {
        // TODO: localize
        switch self {
        case .noConnection: return "No internet connection"
        case .invalidStationData: return "Invalid station data"
        case .stationError(let reason): return "Can't save station data. \(reason?.localizedDescription ?? "")"
        case .noteError(let reason): return "Can't save note. \(reason?.localizedDescription ?? "")"
        case .questionError(let reason): return "Can't save answer to question. \(reason?.localizedDescription ?? "")"
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
        let stationId = Int(section.sectionId)
        guard let county = section.countyCode,
            let medium = SectionInfo.Medium(rawValue: section.medium ?? ""),
            let presidentGenre = SectionInfo.Genre(rawValue: section.presidentGender ?? "") else {
                callback(.invalidStationData)
                return
        }
        
        let dateFmt = APIManager.shared.apiDateFormatter
        let arrivalTime = section.arriveTime != nil ? dateFmt.string(from: section.arriveTime!) : ""
        let leaveTime = section.leaveTime != nil ? dateFmt.string(from: section.leaveTime!) : ""
        
        let section = UpdatePollingStationRequest(
            id: stationId,
            countyCode: county,
            isUrbanArea: medium == .urban,
            leaveTime: leaveTime,
            arrivalTime: arrivalTime,
            isPresidentFemale: presidentGenre == .woman)
        
        APIManager.shared.upload(pollingStation: section) { error in
            if let error = error {
                callback(.stationError(reason: error))
            } else {
                callback(nil)
            }
        }
        
    }
    
    func uploadUnsyncedNotes(then callback: @escaping (RemoteSyncerError?) -> Void) {
        guard let section = DB.shared.currentSectionInfo() else { return }
        let notes = DB.shared.getUnsyncedNotes()
        var passedRequests = 0
        let totalRequests = notes.count
        guard totalRequests > 0 else {
            callback(nil)
            return
        }
        var errors: [RemoteSyncerError] = []
        
        DebugLog("Uploading \(totalRequests) notes...")
        
        for note in notes {
            let uploadRequest = UploadNoteRequest(
                imageData: note.file as Data?,
                questionId: note.questionID != -1 ? Int(note.questionID) : nil,
                countyCode: section.countyCode ?? "",
                pollingStationId: Int(section.sectionId),
                text: note.body ?? "")
            APIManager.shared.upload(note: uploadRequest) { error in
                if let error = error {
                    errors.append(.noteError(reason: error))
                    DebugLog("Failed to uploaded note: \(error.localizedDescription)")
                } else {
                    DebugLog("Uploaded note")
                    
                    // also mark it as synced
                    note.synced = true
                    try? CoreData.save()
                }
                
                passedRequests += 1
                if passedRequests == totalRequests {
                    DebugLog("Finished upload for \(totalRequests) notes")
                    callback(errors.first)
                }
            }
        }
        
        callback(nil)
    }

    func uploadUnsyncedQuestions(then callback: @escaping (RemoteSyncerError?) -> Void) {
        guard let section = DB.shared.currentSectionInfo() else { return }
        let questions = DB.shared.getUnsyncedQuestions()
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
            let question = AnswerRequest(
                questionId: Int(question.id),
                countyCode: section.countyCode ?? "",
                pollingStationId: Int(section.sectionId),
                options: answerRequests)
            answers.append(question)
        }
        
        guard answers.count > 0 else {
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
        let questionIds = answers.map { Int16($0.questionId) }
        DB.shared.setQuestionsSynced(withIds: questionIds)
    }
}
