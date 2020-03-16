//
//  OnboardingChildViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingChildViewController: UIViewController {
    
    let model: OnboardingChildModel
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    init(withModel model: OnboardingChildModel) {
        self.model = model
        super.init(nibName: "OnboardingChildViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    func updateInterface() {
        imageView.image = model.image
        titleLabel.text = model.title
        detailsLabel.text = model.markdownText
    }

}
