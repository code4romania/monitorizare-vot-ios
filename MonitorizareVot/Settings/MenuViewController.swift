//
//  AboutViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/02/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import SafariServices

class MenuViewController: MVViewController {

    @IBOutlet private var closeButton: UIButton!
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var changeStationButton: UIButton!
    @IBOutlet private var guideButton: UIButton!
    @IBOutlet private var safetyGuideButton: UIButton!
    @IBOutlet private var callButton: UIButton!
    @IBOutlet private var aboutButton: UIButton!
    @IBOutlet private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    private func updateInterface() {
//        titleLabel.text = presentingViewController?.title ?? "Menu"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Menu.Button.Close".localized, style: .done,
            target: self, action: #selector(handleCloseButtonTap))
        internationalize()
    }
    
    private func internationalize() {
//        closeButton.setTitle("Menu.Button.Close".localized, for: .normal)
        changeStationButton.setTitle("Menu.Button.ChangeStation".localized, for: .normal)
        guideButton.setTitle("Menu.Button.Guide".localized, for: .normal)
        safetyGuideButton.setTitle("Menu.Button.Safety".localized, for: .normal)
        callButton.setTitle("Menu.Button.Call".localized, for: .normal)
        aboutButton.setTitle("Menu.Button.About".localized, for: .normal)
        logoutButton.setTitle("Menu.Button.Logout".localized, for: .normal)
    }

    @objc private func handleCloseButtonTap() {
        close(then: nil)
    }
    
    @IBAction func handleMenuButtonTap(_ sender: UIButton) {
        switch sender {
        case changeStationButton:
            handleChangeSectionButtonAction()
        case guideButton:
            presentGuideViewController()
        case safetyGuideButton:
            presentSafetyGuideViewController()
        case callButton:
            performCall()
        case aboutButton:
            showAbout()
        case logoutButton:
            logout()
        default:
            break
        }
    }
    
    private func close(then callback: (() -> Void)?) {
        dismiss(animated: true, completion: callback)
    }
    
    // MARK: - Handlers
    
    @objc func presentGuideViewController() {
        MVAnalytics.shared.log(event: .tapGuide)
        if let urlString = RemoteConfigManager.shared.value(of: .observerGuideUrl).stringValue,
            let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "No guide available")
            present(error, animated: true, completion: nil)
        }
    }
    
    @objc func presentSafetyGuideViewController() {
        MVAnalytics.shared.log(event: .tapSafetyGuide)
        if let urlString = RemoteConfigManager.shared.value(of: .safetyGuideUrl).stringValue,
            let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "Safety guide not available right now")
            present(error, animated: true, completion: nil)
        }
    }
    
    @objc func performCall() {
        MVAnalytics.shared.log(event: .tapCall)
        if let phone = RemoteConfigManager.shared.value(of: .callCenterPhone).stringValue {
            let phoneCallPath = "telprompt://\(phone)"
            if let phoneCallURL = NSURL(string: phoneCallPath) {
                UIApplication.shared.openURL(phoneCallURL as URL)
            }
        } else {
            let error = UIAlertController.error(withMessage: "No phone support available")
            present(error, animated: true, completion: nil)
        }
    }

    fileprivate func handleChangeSectionButtonAction() {
        close { [weak self] in
            guard let self = self else { return }
            MVAnalytics.shared.log(event: .tapChangeStation(fromScreen: String(describing: type(of: self))))
            AppRouter.shared.goToChooseStation()
        }
    }
    
    fileprivate func showAbout() {
        let ctl = AboutViewController()
        navigationController?.pushViewController(ctl, animated: true)
    }
    
    fileprivate func logout() {
        AccountManager.shared.accessToken = nil
        AppRouter.shared.goToLogin()
    }
    

}
