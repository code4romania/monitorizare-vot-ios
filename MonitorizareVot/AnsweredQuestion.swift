//  Created by Code4Romania

import Foundation

class AnsweredQuestion {
    var question: MVQuestion
    var presidingOfficer: MVPresidingOfficer
    
    init(question: MVQuestion, presidingOfficer: MVPresidingOfficer) {
        self.question = question
        self.presidingOfficer = presidingOfficer
    }
}
