//
//  SectieViewController.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/17/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import UIKit

class SectieViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - iVars
    private var presidingOfficer = PresidingOfficer()
    private var judete = [String]()
    private var pickerViewSelection: PickerViewSelection?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var bottomTextField: UITextField!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var pickerContainer: UIView!
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var pickerButton: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setDefaultValues()
        loadData()
        setTapGestureRecognizer()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        self.pickerButton.layer.dropDefaultShadow()
        self.pickerButton.layer.defaultCornerRadius(borderColor: UIColor .black.cgColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SectieViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SectieViewController.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - IBActions
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .judete
        pickerView.reloadAllComponents()
        pickerContainer.isHidden = false
    }
    
    @IBAction func closePickerButtonTapped(_ sender: UIButton) {
        pickerContainer.isHidden = true
        if presidingOfficer.judet == nil, let judet = judete.first {
            presidingOfficer.judet = judet
            firstLabel.attributedText = NSAttributedString(string: judet, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0), NSForegroundColorAttributeName: UIColor.black])
        }
    }
    
    @IBAction func bottomButtonPressed(_ sender: UIButton) {
        if presidingOfficer.judet == nil || presidingOfficer.sectie == nil {
           showAlertController()
        } else {
            showNextScreen()
        }
    }
    
    // MARK: - Utils
    func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraint.constant = frame.size.height
            performKeyboardAnimation()
        }
    }
    
    func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    func keyboardIsHidden() {
        bottomConstraint?.constant = 0
        performKeyboardAnimation()
        bottomTextField.resignFirstResponder()
    }
    
    private func showAlertController() {
        let alertButton = UIAlertAction(title: "Am înțeles", style: .cancel, handler: nil)
        
        if presidingOfficer.judet == nil {
            let alertController = UIAlertController(title: "Selecteaza județ", message: "Alege un județ pentru a putea trece la urmatorul pas", preferredStyle: .alert)
            alertController.addAction(alertButton)
            self.present(alertController, animated: true, completion: nil)
        } else if presidingOfficer.sectie == nil {
            let alertController = UIAlertController(title: "Inserează codul secției", message: "Este nevoie să precizezi codul secției pentru a putea trece la urmatorul pas", preferredStyle: .alert)
            alertController.addAction(alertButton)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    private func showNextScreen() {
        if let sectieInfosViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectionInformationsViewController") as? SectionInformationsViewController {
            sectieInfosViewController.presidingOfficer = presidingOfficer
            sectieInfosViewController.topLabelText = presidingOfficer.judet! + " " + presidingOfficer.sectie!
            self.navigationController?.pushViewController(sectieInfosViewController, animated: true)
        }
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SectieViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func layout() {
        for aButton in buttons {
            aButton.layer.dropDefaultShadow()
        }
    }
    
    private func setDefaultValues() {
        let attributedText = NSAttributedString(string: "Alege", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0), NSForegroundColorAttributeName: MVColors.Grey.color])
        firstLabel.attributedText = attributedText
    }
    
    private func loadData() {
        let path = Bundle.main.path(forResource: "Judete", ofType: "plist")
        judete = NSArray(contentsOfFile: path!) as! [String]
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerViewSelection == .judete {
            return judete.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let pickerViewSelection = self.pickerViewSelection {
            if pickerViewSelection == .judete {
                return judete[row]
            }
        }
        return nil
    }
    
    // MARK: - UIPickerviewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerViewSelection = self.pickerViewSelection {
            switch pickerViewSelection {
            case .judete:
                let judet = judete[row]
                presidingOfficer.judet = judet
                firstLabel.attributedText = NSAttributedString(string: judet, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0), NSForegroundColorAttributeName: UIColor.black])
            default:
                break
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        presidingOfficer.sectie = sender.text
    }

}
