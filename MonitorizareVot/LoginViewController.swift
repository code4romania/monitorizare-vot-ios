//  Created by Code4Romania

import Foundation
import UIKit
import SwiftKeychainWrapper

class LoginViewController: RootViewController, UITextFieldDelegate {
    
    // MARK: - iVars
    private var tapGestureRecognizer: UITapGestureRecognizer?
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var codeTextField: UITextField!
    @IBOutlet private weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var formViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerButton: UIButton?
    @IBOutlet private weak var developerBy: UILabel!
    private var loginAPIRequest: LoginAPIRequest?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginAPIRequest = LoginAPIRequest(parentView: self)
        layout()
        setTapGestureRecognizer()
        phoneNumberTextField.placeholder = "TextField_Placeholder_PhoneNumber".localized
        codeTextField.placeholder = "TextField_Placeholder_PINNumber".localized
        centerButton?.isEnabled = false
        centerButton?.setTitle("Button_Authenticate".localized, for: .normal)
        developerBy?.text = "Label_DevelopedBy".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

        prepopulateTestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loadingView.isHidden = false
        
        let phone = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let code = codeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        APIManager.shared.login(withPhone: phone, pin: code) { error in
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                if let error = error {
                    self.displayError(error.localizedDescription)
                } else {
                    self.appFeaturesUnlocked()
                }
            }
        }
    }
    
    @IBAction func textChanged(_ sender: Any) {
        if let phoneText = phoneNumberTextField.text,
            let codeText = codeTextField.text {
            centerButton?.isEnabled = phoneText.count > 0 && codeText.count > 0
        } else {
            centerButton?.isEnabled = false
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Utils
    
    fileprivate func prepopulateTestData() {
        // set these in your local config if you want the phone and pin to be prepopulated,
        // saving you a bunch of typing/pasting
        let prefilledPhone = Bundle.main.infoDictionary?["TEST_PHONE"] as? String ?? ""
        let prefilledPin = Bundle.main.infoDictionary?["TEST_PIN"] as? String ?? ""
        if prefilledPin.count > 0 {
            DispatchQueue.main.async {
                self.phoneNumberTextField.text = prefilledPhone
                self.codeTextField.text = prefilledPin
                self.centerButton?.isEnabled = true
            }
        }
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            formViewBottomConstraint.constant = frame.size.height - buttonHeight.constant
            performKeyboardAnimation()
        }
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    @objc func keyboardIsHidden() {
        formViewBottomConstraint?.constant = 0
        performKeyboardAnimation()
        phoneNumberTextField.resignFirstResponder()
        codeTextField.resignFirstResponder()
    }
    
    private func appFeaturesUnlocked() {
        let sectieViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectieViewController")
        self.navigationController?.setViewControllers([sectieViewController], animated: true)
        
        // download any new forms
        ApplicationData.shared.downloadUpdatedForms { _ in
        }
    
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func layout() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func displayError(_ message: String) {
        let alert = UIAlertController(title: "Error".localized,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
