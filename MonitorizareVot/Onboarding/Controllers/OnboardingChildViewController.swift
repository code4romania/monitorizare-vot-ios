//
//  OnboardingChildViewController.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 24/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SnapKit

class OnboardingChildViewController: UIViewController {

     // MARK: Variables
       
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageInBackgroundView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contextLabel: UILabel!
       
    var onboardingViewModel: OnboardingViewModel

       // MARK: Lifecycle
    
    init(withModel model: OnboardingViewModel) {
        onboardingViewModel = model
        super.init(nibName: "OnboardingChildViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
            view.backgroundColor = MVColors.white.color
            titleLabel.text = onboardingViewModel.title
            contextLabel.text = onboardingViewModel.context
            imageInBackgroundView.image = UIImage(named: "Onboarding-\(onboardingViewModel.imageString)")

            // Do any additional setup after loading the view
           
            setupConstraints()
       }
       
       func setupConstraints() {
           backgroundView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(self.view).dividedBy(2.3)
           }
           
           imageInBackgroundView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.lessThanOrEqualTo(195)
                make.height.lessThanOrEqualTo(200)
           }
           
           titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(backgroundView.snp.bottom).offset(24)
                make.leading.equalTo(view.layoutMarginsGuide.snp.leading)
                make.trailing.equalTo(view.layoutMarginsGuide.snp.trailing)
                make.height.lessThanOrEqualTo(25)
           }
           
           contextLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
                make.leading.equalTo(view.layoutMarginsGuide.snp.leading)
                make.trailing.equalTo(view.layoutMarginsGuide.snp.trailing)
           }
       }

}
