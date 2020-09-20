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

class AboutViewController: MVViewController {
    
    let model = AboutViewModel()

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var bodyHeight: NSLayoutConstraint!
    @IBOutlet var languageButton: UIButton!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var policyButton: UIButton!
    @IBOutlet var developedByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    private func updateInterface() {
        title = "Text.About.Title".localized
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
        developedByLabel.text = "\(model.versionText) " + "Label_DevelopedBy".localized
        developedByLabel.textColor = .defaultText
        developedByLabel.alpha = 0.3
    }
    
    @IBAction func handleChangeLanguageTap(_ sender: Any) {
        showLanguagePicker()
    }
    
    @IBAction func handleContactUsTap(_ sender: Any) {
        MVAnalytics.shared.log(event: .tapContact)
        if let mailUrl = model.contactEmailUrl {
            UIApplication.shared.openURL(mailUrl)
        } else {
            let error = UIAlertController.error(withMessage: "No email contact available")
            present(error, animated: true, completion: nil)
        }
    }
    
    @IBAction func handlePolicyTap(_ sender: Any) {
        if let url = model.privacyPolicyUrl {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "No policy available")
            present(error, animated: true, completion: nil)
        }
    }
    
    private func showLanguagePicker() {
        let possibleValues = model.languageOptions
        let pickerModel = GenericPickerViewModel(withValues: possibleValues)
        pickerModel.selectedIndex = model.selectedLanguageIndex
        let controller = GenericPickerViewController(withModel: pickerModel)
        controller.onCompletion = { [weak self] value in
            guard let self = self else { return }
            if let value = value?.id as? String {
                self.model.selectedLanguage = value
                self.model.saveLanguage()
            }
            self.updateInterface()
            self.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
    }
}
