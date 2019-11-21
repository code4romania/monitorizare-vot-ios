//
//  AppRouter.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

/// Handles navigation inside the app
class AppRouter: NSObject {
    static let shared = AppRouter()
    
    var isPad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    var isPhone: Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    
    var window: UIWindow? { return AppDelegate.shared.window }
    var splitViewController: UISplitViewController? { return AppDelegate.shared.window?.rootViewController as? UISplitViewController }
    var navigationController: UINavigationController? {
        return splitViewController?.viewControllers.first as? UINavigationController
        ?? AppDelegate.shared.window?.rootViewController as? UINavigationController
    }

    func showAppEntry() {
        if OnboardingViewModel.shouldShowOnboarding {
            goToOnboarding()
        } else {
            goToLogin()
        }
    }
    
    func goToLogin() {
        let entryViewController = LoginViewController()
        window?.rootViewController = entryViewController
    }
    
    func goToOnboarding() {
        let entryViewController = OnboardingLanguageViewController()
        let navigation = UINavigationController(rootViewController: entryViewController)
        window?.rootViewController = navigation
    }
    
    func createSplitControllerIfNecessary() {
        guard splitViewController == nil else { return }
    }
    
    func goToChooseStation() {
        let sectionModel = SectionPickerViewModel()
        let sectionController = SectionPickerViewController(withModel: sectionModel)
        if isPad && splitViewController == nil {
            AppDelegate.shared.window?.rootViewController = UISplitViewController()
            splitViewController?.viewControllers = [UINavigationController()]
            if isPad {
                splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
            }
        } else if isPhone {
            AppDelegate.shared.window?.rootViewController = UINavigationController()
        }
        navigationController?.setViewControllers([sectionController], animated: true)
        resetDetailsPane()
    }
    
    func proceedToAuthenticated() {
        goToChooseStation()
    }

    func goToForms(from vc: UIViewController) {
        let formsModel = FormListViewModel()
        let formsVC = FormListViewController(withModel: formsModel)
        navigationController?.setViewControllers([formsVC], animated: true)
        resetDetailsPane()
    }
    
    func open(questionModel: QuestionAnswerViewModel) {
        let controller = QuestionAnswerViewController(withModel: questionModel)
        if isPad,
            let split = splitViewController {
            let navigation = UINavigationController(rootViewController: controller)
            split.showDetailViewController(navigation, sender: nil)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openAddNote() {
        let noteModel = NoteViewModel()
        let controller = NoteViewController(withModel: noteModel)
        if isPad,
            let split = splitViewController {
            let navigation = UINavigationController(rootViewController: controller)
            split.showDetailViewController(navigation, sender: nil)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /// Will make the details pane go back to blank
    func resetDetailsPane() {
        guard isPad else { return }
        guard let split = AppDelegate.shared.window?.rootViewController as? UISplitViewController else { return}
        let controller = EmptyDetailsViewController()
        let navigation = UINavigationController(rootViewController: controller)
        split.showDetailViewController(navigation, sender: nil)
    }
}
