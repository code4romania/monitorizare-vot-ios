//
//  FormsViewController.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 12/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class FormsViewController: UIViewController {
    
    // MARK: Variables
    
    private var onboardingView: OnboardingView!
    
    private var onboardingViewModel = OnboardingViewModel(title: "Fill in the forms",
                                                          context: "In order to help you detect problems, we provide some forms with the standard rules for a voting station. \nOn each form you can mark wether certain procedures have been followed or not.",
                                                          imageString: "2")

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

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
