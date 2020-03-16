//
//  OnboardingViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

struct OnboardingChildModel {
    var image: UIImage
    var title: String
    var markdownText: String
}

class OnboardingViewModel: NSObject {
    static var shouldShowOnboarding: Bool { return !PreferencesManager.shared.wasOnboardingShown }
    
    var currentPage: Int = 0
    
    let children = [
        OnboardingChildModel(image: UIImage(named: "onboarding-station")!,
                             title: "Onboarding.Title.Station".localized,
                             markdownText: "Onboarding.Text.Station".localized),
        OnboardingChildModel(image: UIImage(named: "onboarding-forms")!,
                             title: "Onboarding.Title.Forms".localized,
                             markdownText: "Onboarding.Text.Forms".localized),
        OnboardingChildModel(image: UIImage(named: "onboarding-notes")!,
                             title: "Onboarding.Title.Notes".localized,
                             markdownText: "Onboarding.Text.Notes".localized)
    ]
}
