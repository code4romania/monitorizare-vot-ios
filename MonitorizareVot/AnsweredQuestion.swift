//  Created by Code4Romania

import Foundation

class AnsweredQuestion {
    var question: MVQuestion
    var sectionInfo: MVSectionInfo
    
    init(question: MVQuestion, sectionInfo: MVSectionInfo) {
        self.question = question
        self.sectionInfo = sectionInfo
    }
}
