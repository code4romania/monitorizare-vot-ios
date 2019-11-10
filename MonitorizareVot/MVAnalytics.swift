//
//  MVAnalytics.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Firebase

enum MVAnalyticsEvent {
    case screen(name: String)
    case onboardingPage(page: Int)
    case loginFailed(error: String)
    case pushNotificationsAllowed
    case pushNotificationsDenied
    case county(name: String)
    case sectionEnvironment(type: String)
    case viewForm(code: String)
    case viewQuestion(code: String)
    case answerQuestion(code: String)
    case viewNote
    case viewNoteForQuestion(questionId: Int)
    case addNote(hasAttachment: Bool)
    case addNoteForQuestion(questionId: Int, hasAttachment: Bool)
    case tapCall
    case tapGuide
    case internetDown
    case tapChangeStation(fromScreen: String)
    case tapManualSync

    var name: String {
        switch self {
        case .screen:               return "screen"
        case .onboardingPage:       return "onboarding_page"
        case .loginFailed:          return "login_failed"
        case .pushNotificationsAllowed: return "push_allowed"
        case .pushNotificationsDenied: return "push_denied"
        case .county:               return "county"
        case .sectionEnvironment:   return "station_environment"
        case .viewForm:             return "form_view"
        case .viewQuestion:         return "question_view"
        case .answerQuestion:       return "question_answer"
        case .viewNote:             return "note_view"
        case .addNote:              return "note_add"
        case .viewNoteForQuestion:  return "note_question_view"
        case .addNoteForQuestion:   return "note_question_add"
        case .tapCall:              return "tap_call"
        case .tapGuide:             return "tap_guide"
        case .internetDown:         return "internet_down"
        case .tapChangeStation:     return "tap_change_station"
        case .tapManualSync:        return "tap_manual_sync"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .screen(let name): return ["name": name]
        case .onboardingPage(let page): return ["page": page]
        case .loginFailed(let error): return ["error": error]
        case .county(let name): return ["county": name]
        case .sectionEnvironment(let type): return ["type": type]
        case .viewForm(let code): return ["code": code]
        case .viewQuestion(let code): return ["code": code]
        case .answerQuestion(let code): return ["code": code]
        case .viewNoteForQuestion(let id): return ["questionId": id]
        case .addNote(let hasAttachment): return ["has_attachment": hasAttachment]
        case .addNoteForQuestion(let id, let hasAttachment): return ["questionId": id, "has_attachment": hasAttachment]
        case .tapChangeStation(let screen): return ["from_screen": screen]
        default: return nil
        }
    }
}

class MVAnalytics: NSObject {
    static let shared = MVAnalytics()
    
    func log(event: MVAnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
        #if DEBUG
        DebugLog("Event: \(event.name). Params: \(event.parameters ?? [:])")
        #endif
    }
}
