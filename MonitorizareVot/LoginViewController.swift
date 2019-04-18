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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loadingView.isHidden = false
        
        var udid = NSUUID().uuidString
    
        if let savedUdid = KeychainWrapper.standard.string(forKey: "udid") {
            udid = savedUdid
        } else {
            KeychainWrapper.standard.set(udid, forKey: "udid")
        }
        
        let params: [String: Any] = ["phone":phoneNumberTextField.text ?? "",
                                           "pin": codeTextField.text ?? "",
                                           "udid": udid]
        
        loginAPIRequest?.perform(informations: params) {[weak self] success, response in
            self?.loadingView.isHidden = true
            if let token = response as? String, success {
                KeychainWrapper.standard.set(token, forKey: "token")
                self?.appFeaturesUnlocked()
            } 
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Utils
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
    
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func layout() {
        self.navigationController?.navigationBar.isHidden = true
    }

}
