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
    @IBOutlet private var stationHistoryButton: UIButton!
    @IBOutlet private var guideButton: UIButton!
    @IBOutlet private var safetyGuideButton: UIButton!
    @IBOutlet private var feedbackButton: UIButton!
    @IBOutlet private var callButton: UIButton!
    @IBOutlet private var aboutButton: UIButton!
    @IBOutlet private var logoutButton: UIButton!
    
    var hasVisitedAnyStations: Bool {
        DB.shared.getVisitedSections().count > 0
    }
    
    var safetyGuideUrl: URL? {
        if let urlString = RemoteConfigManager.shared.value(of: .safetyGuideUrl).stringValue,
           !urlString.isEmpty {
            return URL(string: urlString)
        }
        return nil
    }
    
    var shouldShowSafetyGuide: Bool { safetyGuideUrl != nil }
    
    var observerFeedbackUrl: URL? {
        if let urlString = RemoteConfigManager.shared.value(of: .observerFeedbackUrl).stringValue,
           !urlString.isEmpty {
            return URL(string: urlString)
        }
        return nil
    }
    
    var shouldShowObserverFeedback: Bool { observerFeedbackUrl != nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
        view.backgroundColor = .white
    }
    
    private func updateInterface() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Menu.Button.Close".localized, style: .done,
            target: self, action: #selector(handleCloseButtonTap))
        internationalize()
    }
    
    private func internationalize() {
        changeStationButton.setTitle("Menu.Button.ChangeStation".localized, for: .normal)
        stationHistoryButton.setTitle("Menu.Button.StationHistory".localized, for: .normal)
        stationHistoryButton.isHidden = !hasVisitedAnyStations
        guideButton.setTitle("Menu.Button.Guide".localized, for: .normal)
        safetyGuideButton.setTitle("Menu.Button.Safety".localized, for: .normal)
        safetyGuideButton.isHidden = !shouldShowSafetyGuide
        feedbackButton.setTitle("Menu.Button.Feedback".localized, for: .normal)
        feedbackButton.isHidden = !shouldShowObserverFeedback
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
        case stationHistoryButton:
            handleGoToSectionHistoryButtonAction()
        case guideButton:
            presentGuideViewController()
        case safetyGuideButton:
            presentSafetyGuideViewController()
        case feedbackButton:
            presentObserverFeedbackViewController()
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
        if let url = safetyGuideUrl {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "Safety guide not available right now")
            present(error, animated: true, completion: nil)
        }
    }
    
    @objc func presentObserverFeedbackViewController() {
        MVAnalytics.shared.log(event: .tapFeedback)
        if let url = observerFeedbackUrl {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "Observer Feedback not available right now")
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
    
    fileprivate func handleGoToSectionHistoryButtonAction() {
        close { [weak self] in
            guard let self = self else { return }
            MVAnalytics.shared.log(event: .tapStationHistory(fromScreen: String(describing: type(of: self))))
            AppRouter.shared.goToStationHistory()
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
