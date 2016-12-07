//  Created by Code4Romania

import Foundation

class MVPresidingOfficer {
    var judet: String?
    var sectie: String?
    var medium: String?
    var genre: String?
    var arriveHour: String = "00"
    var arriveMinute: String = "00"
    var leftHour: String = "00"
    var leftMinute: String = "00"
    var questions : [MVQuestion] = []
    var synced : Bool = false
    
    func resetSectionInformations() {
        medium = nil
        genre = nil
        arriveHour = "00"
        arriveMinute = "00"
        leftHour = "00"
        leftMinute = "00"
    }
}
