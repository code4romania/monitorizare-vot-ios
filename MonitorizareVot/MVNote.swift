//  Created by Code4Romania

import Foundation
import UIKit

class MVNote {
    var presidingOfficer: MVPresidingOfficer
    var questionID: String?
    var body: String?
    var image: UIImage?
    var synced: Bool = false
    
    init(presidingOfficer: MVPresidingOfficer) {
        self.presidingOfficer = presidingOfficer
    }
}
