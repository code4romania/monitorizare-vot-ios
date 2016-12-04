//  Created by Code4Romania

import Foundation
import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - iVars
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layout()
    }
    
    // MARK: - Utils
    private func layout() {
        self.layer.dropDefaultShadow()
    }
}
