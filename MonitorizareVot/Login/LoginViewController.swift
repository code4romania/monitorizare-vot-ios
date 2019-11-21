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
        setupStaticText()
        bindToUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateInterface()
    }
    
    fileprivate func bindToUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }
    
    fileprivate func configureViews() {
        outerCardContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        outerCardContainer.layer.shadowColor = UIColor.colorSchema.cardDarkerShadow.cgColor
        outerCardContainer.layer.shadowOffset = .zero
        outerCardContainer.layer.shadowRadius = Configuration.shadowRadius
        outerCardContainer.layer.shadowOpacity = Configuration.shadowOpacity
        cardContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        cardContainer.backgroundColor = UIColor.colorSchema.cardBackground
        phoneContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        phoneContainer.layer.borderColor = UIColor.colorSchema.textViewContainerBorder.cgColor
        phoneContainer.layer.borderWidth = 1
        codeContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        codeContainer.layer.borderColor = UIColor.colorSchema.textViewContainerBorder.cgColor
        codeContainer.layer.borderWidth = 1
    }
    
    // MARK: - UI
    
    fileprivate func updateLoginButtonState() {
        loginButton.isEnabled = model.isReady
        loginButton.setTitle(model.buttonTitle, for: .normal)
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
    
    private func setupStaticText() {
        phoneTextField.placeholder = "Label_TelephoneTextInput_Placeholder".localized
        codeTextField.placeholder = "Label_CodeTextInput_Placeholder".localized
        
        updateVersionLabel()
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
                MVAnalytics.shared.log(event: .loginFailed(error: error.localizedDescription))
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
        AppRouter.shared.proceedToAuthenticated()
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
