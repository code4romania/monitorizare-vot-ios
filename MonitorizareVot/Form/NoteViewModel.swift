//
//  NoteViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 31/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class NoteViewModel: NSObject {
    
    var questionId: String?
    
    init(withQuestionId questionId: String? = nil) {
        self.questionId = questionId
        super.init()
    }
    
}
