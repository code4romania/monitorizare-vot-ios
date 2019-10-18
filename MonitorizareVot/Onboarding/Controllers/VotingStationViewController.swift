//
//  VotingStationViewController.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 12/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SnapKit

class VotingStationViewController: UIViewController {
    
    // MARK: Variables
    
    private var onboardingView: OnboardingView!
    
    private var onboardingViewModel = OnboardingViewModel(title: "Pick your voting station",
                                                          context: "STEP 1: \nMention the voting station you are in, choosing the county and it’s number. \n\nSTEP 2: \nAdd some details (urban/ rural area, details about the section president, your arrival time). Don’t worry, you can edit the information later.",
                                                          imageString: "1")

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
