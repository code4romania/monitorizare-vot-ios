//
//  EmptyDetailsViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class EmptyDetailsViewController: MVViewController {

    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        if AppRouter.shared.isPad {
            shouldDisplayHeaderContainer = false
        }
        super.viewDidLoad()
        configureView()
    }
    
    fileprivate func configureView() {
        view.backgroundColor = .appBackground
        contentLabel.textColor = UIColor.defaultText.withAlphaComponent(0.4)
        contentLabel.text = "Label_Empty".localized
    }

}
