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
    
    private var onboardingViewModel = OnboardingViewModel(title: "Add notes",
                                                          context: "Did you notice any problem that does not appear in the form? Use the ‘Add note’ button, write a message and/or attach a picture.",
                                                          imageString: "3")

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
