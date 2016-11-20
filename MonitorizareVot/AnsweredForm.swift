//
//  AnsweredForm.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/19/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

class AnsweredForm {
    var question: Question
    var presidingOfficer: PresidingOfficer
    
    init(question: Question, presidingOfficer: PresidingOfficer) {
        self.question = question
        self.presidingOfficer = presidingOfficer
    }
}
