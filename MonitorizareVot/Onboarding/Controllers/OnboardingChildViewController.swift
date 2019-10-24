//
//  OnboardingChildViewController.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 24/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingChildViewController: UIViewController {

     // MARK: Variables
       
       private var onboardingView: OnboardingView!
       
       private var onboardingViewModel = OnboardingViewModel(title: "Onboarding_Voting_Station_Title".localized,
                                                             context: "Onboarding_Voting_Station_Context".localized,
                                                             imageString: "1")

       // MARK: Lifecycle
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
        view.backgroundColor = MVColors.white.color

           onboardingView = OnboardingView()
           onboardingView.viewModel = onboardingViewModel
           // Do any additional setup after loading the view
           view.addSubview(onboardingView)
           
           setupConstraints()
       }
       
       func setupConstraints() {
           
           onboardingView.snp.makeConstraints { (make) in
               make.edges.equalToSuperview()
           }
       }

}
