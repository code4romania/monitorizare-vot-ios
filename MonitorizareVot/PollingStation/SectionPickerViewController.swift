//
//  SectionPickerViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

class SectionPickerViewController: MVViewController {
    
    var model: SectionPickerViewModel

    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var countyButton: DropdownButton!
    @IBOutlet weak var stationTextContainer: UIView!
    @IBOutlet weak var stationTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: ActionButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: ActionButton!
    @IBOutlet weak var saveLoader: UIActivityIndicatorView!

    // MARK: - Object
    
    init(withModel model: SectionPickerViewModel) {
        self.model = model
        super.init(nibName: "SectionPickerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        bindToModelUpdates()
        localize()
        fetchStations()
        addContactDetailsToNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateInterface()
    }

    // MARK: - Configuration
    
    fileprivate func configureSubviews() {
        stationTextContainer.layer.masksToBounds = true
        stationTextContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        stationTextContainer.layer.borderWidth = 1
        stationTextContainer.layer.borderColor = UIColor.chooserButtonBorder.cgColor
        stationTextField.textColor = .defaultText
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    fileprivate func bindToModelUpdates() {
        model.onDownloadStateChanged = { [weak self] in
            self?.updateInterface()
        }
        model.onStateChanged = { [weak self] in
            self?.updateInterface()
        }
        model.onSaveStateChanged = { [weak self] in
            self?.updateInterface()
        }
    }
    
    fileprivate func fetchStations() {
        model.fetchPollingStations { [weak self] error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.updateInterface()
            }
        }
    }
    
    // MARK: - UI
    
    func updateInterface() {
        if model.isDownloading {
            loader.startAnimating()
            retryButton.isHidden = true
            scrollView.isHidden = true
        } else {
            loader.stopAnimating()
            let hasData = model.availableCounties.count > 0
            retryButton.isHidden = hasData
            scrollView.isHidden = !hasData
        }
        
        countyButton.value = model.selectedCountyName
        
        if !stationTextField.isFirstResponder {
            stationTextField.text = model.sectionId != nil ? "\(model.sectionId!)" : nil
        }
        stationTextField.returnKeyType = model.selectedCountyName != nil ? .done : .next
        
        continueButton.isEnabled = model.canContinue && !model.isSaving
        if model.isSaving {
            saveLoader.startAnimating()
            continueButton.isHidden = true
        } else {
            saveLoader.stopAnimating()
            continueButton.isHidden = false
        }
        
        if model.isSaving || model.isDownloading {
            view.isUserInteractionEnabled = false
        } else {
            view.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func localize() {
        title = "Title.Section".localized
        chooseLabel.text = "Label_ChooseStation".localized
        countyLabel.text = "Label_County".localized
        stationLabel.text = "Label_StationNumber".localized
        countyButton.placeholder = "Label_SelectOption".localized
        stationTextField.placeholder = "Label_EnterStation".localized
        continueButton.setTitle("Button_Continue".localized, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func handleSelectCountyAction(_ sender: Any) {
        let pickerOptions = model.availableCounties.map { GenericPickerValue(id: $0.code, displayName: $0.name.capitalized) }
        let pickerModel = GenericPickerViewModel(withValues: pickerOptions)
        let picker = GenericPickerViewController(withModel: pickerModel)
        picker.onCompletion = { [weak self] value in
            if let value = value {
                self?.model.countyCode = value.id as? String
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func handleRetryDownloadAction(_ sender: Any) {
        fetchStations()
    }
    
    @IBAction func handleContinueAction(_ sender: Any) {
        saveAndContinue()
    }
    
    func saveAndContinue() {
        guard model.isSectionNumberCorrect else {
            let alert = UIAlertController.error(withMessage: "Error.IncorrectStationNumber".localized)
            present(alert, animated: true, completion: nil)
            return
        }
        
        model.persist { [weak self] error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.proceedToNextScreen()
            }
        }
    }
    
    func proceedToNextScreen() {
        MVAnalytics.shared.log(event: .county(name: model.countyCode ?? "-"))
        let detailsModel = SectionDetailsViewModel()
        let detailsController = SectionDetailsViewController(withModel: detailsModel)
        navigationController?.setViewControllers([detailsController], animated: true)
    }
}

extension SectionPickerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let updated = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            if let number = Int(updated) {
                model.sectionId = number
            } else if updated == "" {
                model.sectionId = nil
            } else {
                return false
            }
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if model.canContinue {
            saveAndContinue()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard model.countyCode != nil else {
            let alert = UIAlertController.error(withMessage: "Error.SelectCountyFirst".localized)
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}
