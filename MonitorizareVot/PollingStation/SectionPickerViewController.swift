//
//  SectionPickerViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class SectionPickerViewController: MVViewController {
    
    var model: SectionPickerViewModel

    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var countyButton: DropdownButton!
    @IBOutlet weak var stationButton: DropdownButton!
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
        bindToModelUpdates()
        localize()
        fetchStations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateInterface()
    }

    // MARK: - Configuration
    
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
        stationButton.value = model.sectionId != nil ? "\(model.sectionId!)" : nil
        
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
        stationButton.placeholder = "Label_SelectOption".localized
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
    
    @IBAction func handleSelectStationAction(_ sender: Any) {
        guard let county = model.countyCode else {
            let alert = UIAlertController.error(withMessage: "Error.SelectCountyFirst".localized)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let pickerOptions = model.availableSectionIds(inCounty: county).map { GenericPickerValue(id: $0, displayName: "\($0)") }
        let pickerModel = GenericPickerViewModel(withValues: pickerOptions)
        let picker = GenericPickerViewController(withModel: pickerModel)
        picker.onCompletion = { [weak self] value in
            if let value = value,
                let id = value.id as? Int {
                self?.model.sectionId = id
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func handleRetryDownloadAction(_ sender: Any) {
        fetchStations()
    }
    
    @IBAction func handleContinueAction(_ sender: Any) {
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
        let detailsModel = SectionDetailsViewModel()
        let detailsController = SectionDetailsViewController(withModel: detailsModel)
        navigationController?.pushViewController(detailsController, animated: true)
    }
}
