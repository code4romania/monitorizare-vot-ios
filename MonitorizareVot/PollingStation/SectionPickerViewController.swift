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
    
    @IBOutlet weak var provinceLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var municipalityLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    
    @IBOutlet weak var provinceButton: DropdownButton!
    @IBOutlet weak var countyButton: DropdownButton!
    @IBOutlet weak var municipalityButton: DropdownButton!
    @IBOutlet weak var stationTextContainer: UIView!
    @IBOutlet weak var stationTextField: UITextField!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: ActionButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: ActionButton!
    @IBOutlet weak var selectFromHistoryButton: UIButton!
    @IBOutlet weak var saveLoader: UIActivityIndicatorView!
    @IBOutlet weak var buttonContainer: UIStackView!
    
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
        fetchProvinces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMenuButtonToNavBar()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        localize()
        updateInterface()
    }

    // MARK: - Configuration
    
    fileprivate func configureSubviews() {
        stationTextContainer.layer.masksToBounds = true
        stationTextContainer.layer.cornerRadius = UIConfiguration.buttonCornerRadius
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

    private func fetchProvinces() {
        model.fetchProvinces { [weak self] error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.updateInterface()
            }
        }
    }

    private func fetchCountiesInCurrentProvince() {
        guard let province = model.selectedProvince else { return }
        model.fetchCounties(in: province.code) { [weak self] error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.updateInterface()
            }
        }
    }

    private func fetchMunicipalitiesInCurrentCounty() {
        guard let county = model.selectedCounty else { return }
        model.fetchMunicipalities(in: county.code) { [weak self] error in
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
            let hasData = model.provinces.count > 0
            retryButton.isHidden = hasData
            scrollView.isHidden = !hasData
        }
        
        provinceButton.value = model.selectedProvince?.name
        countyButton.value = model.selectedCounty?.name
        municipalityButton.value = model.selectedMunicipality?.name

        if !stationTextField.isFirstResponder {
            stationTextField.text = model.sectionId != nil ? "\(model.sectionId!)" : nil
        }
        stationTextField.returnKeyType = model.selectedCountyName != nil ? .done : .next
        
        continueButton.isEnabled = model.canContinue && !model.isSaving
        if model.isSaving {
            saveLoader.startAnimating()
            buttonContainer.isHidden = true
        } else {
            saveLoader.stopAnimating()
            buttonContainer.isHidden = false
        }
        
        selectFromHistoryButton.isHidden = !model.hasVisitedAnyStations
        
        if model.isSaving || model.isDownloading {
            view.isUserInteractionEnabled = false
        } else {
            view.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func localize() {
        title = "Title.Section".localized
        chooseLabel.text = "Label_ChooseStation".localized
        provinceLabel.text = "Label_Province".localized
        countyLabel.text = "Label_County".localized
        municipalityLabel.text = "Label_Municipality".localized
        stationLabel.text = "Label_StationNumber".localized
        provinceButton.placeholder = "Label_SelectOption".localized
        countyButton.placeholder = "Label_SelectOption".localized
        municipalityButton.placeholder = "Label_SelectOption".localized
        stationTextField.placeholder = "Label_EnterStation".localized
        continueButton.setTitle("Button_Continue".localized, for: .normal)
        selectFromHistoryButton.setTitle("Button_SelectFromHistory".localized, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func handleSelectAction(_ sender: UIButton) {
        var options: [GenericPickerValue] = []
        var select: ((_ id: Int) -> Void)?
        switch sender {
        case provinceButton:
            options = model.provinces.enumerated().map { GenericPickerValue(id: $0.offset, displayName: $0.element.name) }
            select = {
                self.model.selectedProvince = self.model.provinces[$0]
                self.fetchCountiesInCurrentProvince()
            }
        case countyButton:
            guard let counties = model.currentCounties else { return }
            options = counties.enumerated().map { GenericPickerValue(id: $0.offset, displayName: $0.element.name) }
            select = {
                guard let counties = self.model.currentCounties else { return }
                self.model.selectedCounty = counties[$0]
                self.fetchMunicipalitiesInCurrentCounty()
            }
        case municipalityButton:
            guard let municipalities = model.currentMunicipalities else { return }
            options = municipalities.enumerated().map { GenericPickerValue(id: $0.offset, displayName: $0.element.name) }
            select = {
                guard let municipalities = self.model.currentMunicipalities else { return }
                self.model.selectedMunicipality = municipalities[$0]
            }
        default:
            break
        }
        
        let pickerModel = GenericPickerViewModel(withValues: options)
        let picker = GenericPickerViewController(withModel: pickerModel)
        picker.onCompletion = { [weak self] value in
            if let value {
                select?(value.id as! Int)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func handleRetryDownloadAction(_ sender: Any) {
        fetchProvinces()
    }
    
    @IBAction func handleContinueAction(_ sender: Any) {
        saveAndContinue()
    }
    
    @IBAction func handleSelectFromHistoryAction(_ sender: Any) {
        showStationHistory()
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
        MVAnalytics.shared.log(event: .county(name: model.selectedCounty?.name ?? "-"))
        let detailsModel = SectionDetailsViewModel()
        let detailsController = SectionDetailsViewController(withModel: detailsModel)
        navigationController?.setViewControllers([detailsController], animated: true)
    }
    
    private func showStationHistory() {
        MVAnalytics.shared.log(event: .tapStationHistory(fromScreen: "\(String(describing: Self.self))"))
        AppRouter.shared.goToStationHistory()
    }
}

extension SectionPickerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updated = (textField.text as NSString?)!
            .replacingCharacters(in: range, with: string)
        
        if let number = Int(updated) {
            model.sectionId = number
        } else if updated == "" {
            model.sectionId = nil
        }
        updateInterface()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if model.canContinue {
            saveAndContinue()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard model.selectedMunicipality != nil else {
            let alert = UIAlertController.error(withMessage: "Error.SelectCountyFirst".localized)
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}
