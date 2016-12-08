//  Created by Code4Romania

import Foundation
import UIKit

class MVNote {
    var sectionInfo: MVSectionInfo
    var questionID: Int16?
    var body: String?
    var image: UIImage?
    var synced: Bool = false
    
    init(sectionInfo: MVSectionInfo) {
        self.sectionInfo = sectionInfo
    }
}
