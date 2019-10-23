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
    var isUrbanArea: Bool
    var leaveTime: String
    var arrivalTime: String
    var isPresidentFemale: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case countyCode
        case isUrbanArea = "urbanArea"
        case leaveTime = "observerLeaveTime"
        case arrivalTime = "observerArrivalTime"
        case isPresidentFemale = "isPollingStationPresidentFemale"
    }
}

struct UploadNoteRequest: Codable {
    var imageData: Data?
    var questionId: Int?
    var countyCode: String
    var pollingStationId: Int?
    var text: String
}

struct UploadAnswersRequest: Codable {
    var answers: [AnswerRequest]
}

struct AnswerRequest: Codable {
    var questionId: Int
    var countyCode: String
    var pollingStationId: Int
    var options: [AnswerOptionRequest]
    
    enum CodingKeys: String, CodingKey {
        case questionId
        case countyCode
        case pollingStationId = "pollingStationNumber"
        case options
    }
}

struct AnswerOptionRequest: Codable {
    var id: Int
    var value: String
    
    enum CodingKeys: String, CodingKey {
        case id = "optionId"
        case value
    }
}

// MARK: - Responses

struct ErrorResponse: Codable {
    var error: String
}

struct PollingStationResponse: Codable {
    var id: Int
    var name: String
    var code: String
    var limit: Int
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case version = "ver"
        case description
    }
}

struct FormSectionResponse: Codable {
    var id: Int
    var uniqueId: String
    var code: String
    var questions: [QuestionResponse]
}

struct QuestionResponse: Codable {
    var id: Int
    var code: String
    var questionType: Int
    var text: String
    var options: [QuestionOptionResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case questionType
        case text
        case options = "optionsToQuestions"
    }
}

struct QuestionOptionResponse: Codable {
    var id: Int
    var text: String
    var isFreeText: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "idOption"
        case text
        case isFreeText
    }
}

