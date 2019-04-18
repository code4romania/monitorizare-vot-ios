//  Created by Code4Romania

import UIKit
import CoreData

enum SectieErrorType {
    case judetNotSet
    case sectieNotSet
    case sectieInvalid
}

class SectieViewController: RootViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - iVars
    private var sectionInfo = MVSectionInfo()
    private var judete = [[String: AnyObject]]()
    private var pickerViewSelection: PickerViewSelection?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    @IBOutlet weak var topFirstLabel: UILabel?
    @IBOutlet weak var topSecondLabel: UILabel?
    @IBOutlet weak var countyLabel: UILabel?
    @IBOutlet weak var selectedCountyLabel: UILabel?
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var bottomTextField: UITextField!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var pickerContainer: UIView!
    private let formsVersionsFetcher = FormsFetcher(formsPersistor: LocalFormsPersistor())
    private let syncer = DBSyncer()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        formsVersionsFetcher.fetch {[weak self] (tokenExpired) in
            if tokenExpired {
                let _ = self?.navigationController?.popToRootViewController(animated: false)
            }
        }
        syncer.syncUnsyncedData()
        layout()
        setDefaultValues()
        loadData()
        setTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocalStorage()
        
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
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .judete
        pickerView.reloadAllComponents()
        pickerContainer.isHidden = !pickerContainer.isHidden
        bottomTextField.resignFirstResponder()
        if sectionInfo.judet == nil, let judet = judete.first?.keys.first {
            sectionInfo.judet = judet
            selectedCountyLabel?.attributedText = NSAttributedString(string: judet, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0), NSAttributedString.Key.foregroundColor: MVColors.black.color])
        }
    }
    
    @IBAction func closePickerButtonTapped(_ sender: UIButton) {
        pickerContainer.isHidden = true
    }
    
    @IBAction func bottomButtonPressed(_ sender: UIButton) {
        if sectionInfo.judet == nil {
            showAlertController(errorType: .judetNotSet)
        } else if sectionInfo.sectie == nil {
            showAlertController(errorType: .sectieNotSet)
        } else {
            for judet in judete {
                if judet.keys.first == sectionInfo.judet {
                    if let sectieMaximum = judet.values.first as? Int, let sectie = Int(sectionInfo.sectie!) {
                        if sectie < 1 || sectie > sectieMaximum {
                            showAlertController(errorType: .sectieInvalid)
                        } else {
                            UserDefaults.standard.set(sectionInfo.judet!, forKey: "judet")
                            UserDefaults.standard.set(sectionInfo.sectie!, forKey: "sectie")
                            showNextScreen()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        if let text = sender.text {
            sectionInfo.sectie = text
        }
    }
    
    // MARK: - Utils
    @objc func keyboardDidShow(notification: Notification) {
        pickerContainer.isHidden = true
        if let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraint.constant = frame.size.height
            performKeyboardAnimation()
        }
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    @objc func keyboardIsHidden() {
        pickerContainer.isHidden = true
        bottomConstraint?.constant = 0
        performKeyboardAnimation()
        bottomTextField.resignFirstResponder()
    }
    
    private func showAlertController(errorType: SectieErrorType) {
        let alertButton = UIAlertAction(title: "AlertButton_Understood".localized, style: .cancel, handler: nil)
        
        switch errorType {
        case .judetNotSet:
            let alertController = UIAlertController(title: "AlertTitle_SelectCounty".localized, message: "AlertMessage_SelectCounty".localized, preferredStyle: .alert)
            alertController.addAction(alertButton)
            self.present(alertController, animated: true, completion: nil)
        case .sectieNotSet:
            let alertController = UIAlertController(title: "AlertTitle_CountyNumber".localized, message: "AlertMessage_CountyNumber".localized, preferredStyle: .alert)
            alertController.addAction(alertButton)
            self.present(alertController, animated: true, completion: nil)
        case .sectieInvalid:
            let alertController = UIAlertController(title: "AlertTitle_CountyNumberInvalid".localized, message: "AlertMessage_CountyNumberInvalid".localized, preferredStyle: .alert)
            alertController.addAction(alertButton)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showNextScreen() {
        if let sectieInfosViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectionInformationsViewController") as? SectionInformationsViewController {
            sectieInfosViewController.sectionInfo = sectionInfo
            sectieInfosViewController.topLabelText = sectionInfo.judet! + " " + String(sectionInfo.sectie!)
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
        topFirstLabel?.text = "Label_PickDepartment".localized
        topSecondLabel?.text  = "Label_PickDepartmentDetails".localized
        countyLabel?.text = "Label_County".localized
        closeButton?.setTitle("Button_Close".localized, for: .normal)
        continueButton?.setTitle("Button_Continue".localized, for: .normal)
        bottomTextField?.placeholder = "TextField_Placeholder_DepartmentNumber".localized
        let attributedText = NSAttributedString(string: "Label_SelectedCounty".localized, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0), NSAttributedString.Key.foregroundColor: MVColors.gray.color])
        selectedCountyLabel?.attributedText = attributedText
    }
    
    private func loadData() {
        if let path = Bundle.main.path(forResource: "Judete", ofType: "plist"), let plistContent = NSArray(contentsOfFile: path) as? [[String: AnyObject]] {
            judete = plistContent
        }
    }
    
    private func checkLocalStorage() {
        if let judet = UserDefaults.standard.string(forKey: "judet") {
            sectionInfo.judet = judet
            selectedCountyLabel?.text = judet
        }
        
        if let sectie = UserDefaults.standard.string(forKey: "sectie") {
            sectionInfo.sectie = sectie
            bottomTextField.text = sectie
        }
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
                return  judete[row].keys.first
            }
        }
        return nil
    }
    
    // MARK: - UIPickerviewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerViewSelection = self.pickerViewSelection {
            switch pickerViewSelection {
            case .judete:
                if let judet = judete[row].keys.first {
                    sectionInfo.judet = judet
                    selectedCountyLabel?.attributedText = NSAttributedString(string: judet, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0), NSAttributedString.Key.foregroundColor: MVColors.black.color])
                }
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
    
}
