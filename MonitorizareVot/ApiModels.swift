//
//  ApiModels.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 20/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//
//  API:
//  https://mv-mobile-test.azurewebsites.net/swagger/index.html

import Foundation

// MARK: - Requests

struct LoginRequest: Codable {
    var user: String
    var password: String
    var uniqueId: String
}

struct UpdatePollingStationRequest: Codable {
    var id: Int
    var countyCode: String
    var municipalityCode: String
    var arrivalTime: String
    var numberOfVotersOnTheList: Int
    var numberOfCommissionMembers: Int
    var numberOfFemaleMembers: Int
    var minPresentMembers: Int
    var chairmanPresence: Bool
    var singlePollingStationOrCommission: Bool
    var adequatePollingStationSize: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "pollingStationNumber"
        case countyCode
        case municipalityCode
        case arrivalTime = "observerArrivalTime"
        case numberOfVotersOnTheList
        case numberOfCommissionMembers
        case numberOfFemaleMembers
        case minPresentMembers
        case chairmanPresence
        case singlePollingStationOrCommission
        case adequatePollingStationSize
    }
}

/// will not be encoded, but used to extract the data and add it as multipart to the request
struct UploadNoteRequest {
    var questionId: Int?
    var countyCode: String
    var municipalityCode: String
    var pollingStationId: Int?
    var text: String

    var attachments: [NoteAttachment]
    
    enum CodingKeys: String, CodingKey {
        case questionId
        case countyCode
        case municipalityCode
        case pollingStationId = "pollingStationNumber"
        case text
        case attachments = "files"
    }
}

struct UploadAnswersRequest: Codable {
    var answers: [AnswerRequest]
}

struct AnswerRequest: Codable {
    var questionId: Int
    var countyCode: String
    var municipalityCode: String
    var pollingStationId: Int
    var options: [AnswerOptionRequest]
    
    enum CodingKeys: String, CodingKey {
        case questionId
        case countyCode
        case municipalityCode
        case pollingStationId = "pollingStationNumber"
        case options
    }
}

struct AnswerOptionRequest: Codable {
    var id: Int
    var value: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "optionId"
        case value
    }
}

// MARK: - Responses

struct ErrorResponse: Codable {
    var error: String
}

struct LoginResponse: Codable {
    var accessToken: String?
    var expiresIn: Int?
    var error: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case error
    }
}

protocol Sortable {
    var order: Int { get }
    var name: String { get }
}

struct ProvinceResponse: Codable, Sortable, Equatable {
    var id: Int
    var name: String
    var code: String
    var order: Int
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
    
    static func basic(name: String?, code: String?) -> ProvinceResponse? {
        guard let name, let code else { return nil }
        return Self.init(id: 0, name: name, code: code, order: 0)
    }
}

struct CountyResponse: Codable, Sortable, Equatable {
    var id: Int
    var name: String
    var code: String
    var provinceCode: String
    var diaspora: Bool?
    var order: Int
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
    
    static func basic(name: String?, code: String?) -> CountyResponse? {
        guard let name, let code else { return nil }
        return Self.init(id: 0, name: name, code: code, provinceCode: "", diaspora: nil, order: 0)
    }
}

struct MunicipalityResponse: Codable, Sortable, Equatable {
    var id: Int
    var name: String
    var code: String
    var countyCode: String
    var numberOfPollingStations: Int
    var order: Int
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
    
    static func basic(name: String?, code: String?) -> MunicipalityResponse? {
        // TODO: the number of polling stations is mocked
        guard let name, let code else { return nil }
        return Self.init(id: 0, name: name, code: code, countyCode: "", numberOfPollingStations: 1000, order: 0)
    }
}

struct FormListResponse: Codable {
    var forms: [FormResponse]

    enum CodingKeys: String, CodingKey {
        case forms = "formVersions"
    }
}

struct FormResponse: Codable {
    var id: Int
    var code: String
    var version: Int
    var description: String
    var order: Int?
    var isDiasporaOnly: Bool?
    var draft: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case version = "currentVersion"
        case description
        case order
        case isDiasporaOnly = "diaspora"
        case draft
    }
}

struct FormSectionResponse: Codable {
    var id: Int
    var uniqueId: String
    var code: String
    var description: String
    var orderNumber: Int
    var questions: [QuestionResponse]
}

struct QuestionResponse: Codable {
    
    enum QuestionType: Int, Codable {
        case multipleAnswers
        case singleAnswer
        case singleAnswerWithText
        case multipleAnswerWithText
    }
    
    var id: Int
    var code: String
    var questionType: QuestionType
    var text: String
    var orderNumber: Int?
    var options: [QuestionOptionResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case questionType
        case text
        case options = "optionsToQuestions"
        case orderNumber
    }
}

struct QuestionOptionResponse: Codable {
    var id: Int
    var text: String
    var isFreeText: Bool
    var order: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "optionId"
        case text
        case isFreeText
        case order = "orderNumber"
    }
}

struct AppInformationResponse: Decodable {
    struct ResultResponse: Decodable {
        var version: String
        var releaseNotes: String
    }
    
    var resultCount: Int
    var results: [ResultResponse]
}

