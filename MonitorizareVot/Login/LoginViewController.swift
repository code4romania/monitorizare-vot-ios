//
//  LoginViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

class LoginViewController: MVViewController {
    
    var model: LoginViewModel = LoginViewModel()
    
    @IBOutlet weak var vmLogoImageView: UIImageView!
    @IBOutlet weak var outerCardContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var codeContainer: UIView!
    @IBOutlet weak var developedByLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        bindToUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateInterface()
        updateVersionLabel()
    }
    
    fileprivate func bindToUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }
    
    fileprivate func configureViews() {
        outerCardContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        outerCardContainer.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        outerCardContainer.layer.shadowOffset = .zero
        outerCardContainer.layer.shadowRadius = Configuration.shadowRadius
        outerCardContainer.layer.shadowOpacity = Configuration.shadowOpacity
        cardContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        cardContainer.backgroundColor = .cardBackground
        phoneContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        phoneContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        phoneContainer.layer.borderWidth = 1
        codeContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        codeContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        codeContainer.layer.borderWidth = 1
    }
    
    fileprivate func localize() {
        // TODO: localize
    }
    
    // MARK: - UI
    
    fileprivate func updateVersionLabel() {
        guard let info = Bundle.main.infoDictionary else { return }
        let version = info["CFBundleShortVersionString"] ?? "1.0"
        let build = info["CFBundleVersion"] ?? "1"
        developedByLabel.text = "v\(version)(\(build)) " + "Label_DevelopedBy".localized
    }
    
    fileprivate func updateLoginButtonState() {
        loginButton.isEnabled = model.isReady
    }
    
    fileprivate func updateInterface() {
        updateLoginButtonState()
        phoneTextField.text = model.phoneNumber
        codeTextField.text = model.code
        if model.isLoading {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }
    
    fileprivate func setVMLogo(visible: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.vmLogoImageView.alpha = visible ? 1 : 0
            }
        } else {
            vmLogoImageView.alpha = visible ? 1 : 0
        }
    }
    
    // MARK: - Actions
    
    func login() {
        guard model.isReady else { return }
        model.login { [weak self] error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.proceedToNextScreen()
                self?.askForPushNotificationsPermissions()
            }
        }
    }
    
    func askForPushNotificationsPermissions() {
        // always ask for notifications so that we can detect token changes
        NotificationsManager.shared.registerForRemoteNotifications()
    }

    @IBAction func handleLoginButtonTap(_ sender: Any) {
        login()
    }
    
    func proceedToNextScreen() {
        let sectionModel = SectionPickerViewModel()
        let sectionController = SectionPickerViewController(withModel: sectionModel)
        navigationController?.setViewControllers([sectionController], animated: true)
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setVMLogo(visible: false, animated: true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            codeTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            setVMLogo(visible: true, animated: true)
            login()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updated = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        switch textField {
        case phoneTextField:
            model.phoneNumber = updated
        case codeTextField:
            model.code = updated
        default:
            break
        }
        updateLoginButtonState()
        return true
    }
}
