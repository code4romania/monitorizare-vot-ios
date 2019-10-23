//
//  AddNotesViewController.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 13/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class AddNotesViewController: UIViewController {

    // MARK: Variables
    
    private var onboardingView: OnboardingView!
    
    private var onboardingViewModel = OnboardingViewModel(title: "Onboarding_Notes_Title".localized,
                                                          context: "Onboarding_Notes_Context".localized,
                                                          imageString: "3")

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = MVColors.white

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
