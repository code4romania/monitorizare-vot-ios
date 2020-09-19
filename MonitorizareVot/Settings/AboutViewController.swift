//
//  AboutViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 19/09/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import SwiftyMarkdown
import SafariServices

class AboutViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var bodyHeight: NSLayoutConstraint!
    @IBOutlet var languageButton: UIButton!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var policyButton: UIButton!
    @IBOutlet var developedByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text.About.Title".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    private func updateInterface() {
        titleLabel.text = "Text.About.Title".localized
        titleLabel.textColor = .defaultText
        let markdown = SwiftyMarkdown(string: "Text.About.Body".localized)
        markdown.setFontSizeForAllStyles(with: 14)
        markdown.setFontColorForAllStyles(with: .defaultText)
        bodyTextView.isUserInteractionEnabled = true
        bodyTextView.attributedText = markdown.attributedString()
        bodyTextView.contentInset = UIEdgeInsets(top: -6, left: -4, bottom: 6, right: -4)
        let availableSize = CGSize(width: bodyTextView.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let fitSize = bodyTextView.sizeThatFits(availableSize)
        languageButton.setTitle("Menu.Button.ChangeLanguage".localized, for: .normal)
        languageButton.setTitleColor(.defaultText, for: .normal)
        contactButton.setTitle("Menu.Button.ContactUs".localized, for: .normal)
        contactButton.setTitleColor(.defaultText, for: .normal)
        policyButton.setTitle("Menu.Button.PrivacyPolicy".localized, for: .normal)
        policyButton.setTitleColor(.defaultText, for: .normal)
        bodyHeight.constant = fitSize.height
        updateVersionLabel()
        view.layoutIfNeeded()
    }

    private func updateVersionLabel() {
        guard let info = Bundle.main.infoDictionary else { return }
        let version = info["CFBundleShortVersionString"] ?? "1.0"
        let build = info["CFBundleVersion"] ?? "1"
        var versionString = "v\(version)"
        #if DEBUG
        versionString += "(\(build))"
        #endif
        
        developedByLabel.text = "\(versionString) " + "Label_DevelopedBy".localized
        developedByLabel.textColor = .defaultText
        developedByLabel.alpha = 0.3
    }
    
    @IBAction func handleChangeLanguageTap(_ sender: Any) {
        // TODO: change language
    }
    
    @IBAction func handleContactUsTap(_ sender: Any) {
        MVAnalytics.shared.log(event: .tapContact)
        if let email = RemoteConfigManager.shared.value(of: .contactEmail).stringValue {
            let mailtoPath = "mailto:\(email)"
            if let mailtoURL = NSURL(string: mailtoPath) {
                UIApplication.shared.openURL(mailtoURL as URL)
            }
        } else {
            let error = UIAlertController.error(withMessage: "No phone support available")
            present(error, animated: true, completion: nil)
        }
    }
    
    @IBAction func handlePolicyTap(_ sender: Any) {
        if let urlString = RemoteConfigManager.shared.value(of: .privacyPolicyUrl).stringValue,
            let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "No guide available")
            present(error, animated: true, completion: nil)
        }
    }
}
