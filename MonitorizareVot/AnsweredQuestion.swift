//
//  AnsweredQuestion.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/19/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

class AnsweredQuestion {
    var question: MVQuestion
    var presidingOfficer: MVPresidingOfficer
    
    init(question: MVQuestion, presidingOfficer: MVPresidingOfficer) {
        self.question = question
        self.presidingOfficer = presidingOfficer
    }
}
