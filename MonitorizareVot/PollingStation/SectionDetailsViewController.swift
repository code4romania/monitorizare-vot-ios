//
//  SectionDetailsViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class SectionDetailsViewController: MVViewController {
    
    var model: SectionDetailsViewModel

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var environmentLabel: UILabel!
    @IBOutlet weak var chairmanGenderLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    
    @IBOutlet weak var envUrbanButton: UIButton!
    @IBOutlet weak var envRuralButton: UIButton!
    @IBOutlet weak var genderWomanButton: UIButton!
    @IBOutlet weak var genderManButton: UIButton!
    @IBOutlet weak var arrivalButton: UIButton!
    @IBOutlet weak var departureButton: UIButton!
    
    @IBOutlet weak var continueButton: UIButton!
    
    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinner.startAnimating()
                continueButton.isEnabled = false
            } else {
                spinner.stopAnimating()
                continueButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Object
    
    init(withModel model: SectionDetailsViewModel) {
        self.model = model
        super.init(nibName: "SectionDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Title.StationDetails".localized
        configureSubviews()
        bindToUpdates()
        addContactDetailsToNavBar()
        updateLabelsTexts()
        isLoading = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    // MARK: - Config
    
    fileprivate func bindToUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }

    fileprivate func configureSubviews() {
    }
    
    
    // MARK: - UI
    
    fileprivate func formattedTime(fromDate date: Date?) -> String {
        if let date = date {
            return timeFormatter.string(from: date)
        } else {
            return "--:--"
        }
    }
    
    fileprivate func updateInterface() {
        envUrbanButton.isSelected = model.medium == .urban
        envRuralButton.isSelected = model.medium == .rural
        genderWomanButton.isSelected = model.gender == .woman
        genderManButton.isSelected = model.gender == .man
        arrivalButton.setTitle(formattedTime(fromDate: model.arrivalTime), for: .normal)
        departureButton.setTitle(formattedTime(fromDate: model.leaveTime), for: .normal)
        continueButton.isEnabled = model.isReady
    }
    
    fileprivate func updateLabelsTexts() {
        environmentLabel.text = "Label_CountyLocation".localized
        envUrbanButton.setTitle("Button_Urban".localized, for: .normal)
        envRuralButton.setTitle("Button_Rural".localized, for: .normal)
        
        chairmanGenderLabel.text = "Label_CountyPresidentGender".localized
        genderWomanButton.setTitle("Button_Female".localized, for: .normal)
        genderManButton.setTitle("Button_Male".localized, for: .normal)
        
        arrivalTimeLabel.text = "Label_CountyArriveTime".localized
        departureTimeLabel.text = "Label_CountyLeaveTime".localized
        
        continueButton.setTitle("Button_ContinueToForms".localized, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func handleEnvironmentButtonTap(_ sender: UIButton) {
        var medium: SectionInfo.Medium!
        switch sender {
        case envUrbanButton: medium = .urban
        case envRuralButton: medium = .rural
        default: break
        }
        model.medium = medium
    }
    
    @IBAction func handleGenderButtonTap(_ sender: UIButton) {
        var gender: SectionInfo.Genre!
        switch sender {
        case genderWomanButton: gender = .woman
        case genderManButton: gender = .man
        default: break
        }
        model.gender = gender
    }
    
    @IBAction func handleTimeButtonTap(_ sender: UIButton) {
        let isArrivalTime = sender == arrivalButton
        let initialTime = isArrivalTime ? model.arrivalTime : model.leaveTime

        let pickerModel = TimePickerViewModel(withTime: initialTime, dateFormatter: timeFormatter)
        if let arrivalTime = model.arrivalTime, !isArrivalTime {
            pickerModel.minDate = arrivalTime
        }
        let controller = TimePickerViewController(withModel: pickerModel)
        controller.onCompletion = { [weak self] time in
            if isArrivalTime {
                self?.model.arrivalTime = time
                let departureDate = self?.model.leaveTime
                if let departure = departureDate,
                    let arrival = time,
                    arrival > departure {
                    // reset the departure in case the arrival date has been set in the future
                    self?.model.leaveTime = nil
                }
            } else {
                self?.model.leaveTime = time
                let arrivalDate = self?.model.arrivalTime
                // this shouldn't happen anymore
                if let arrival = arrivalDate,
                    let departure = time,
                    arrival > departure {
                    // reset the arrival to the same time
                    self?.model.arrivalTime = time
                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func handleContinueButtonTap(_ sender: Any) {

        // persist the data first
        self.isLoading = true
        model.persist { [weak self] (error, isTokenExpired) in
            guard let self = self else { return }
            self.isLoading = false

            if isTokenExpired {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                if error == nil {
                    MVAnalytics.shared.log(event: .sectionEnvironment(type: self.model.medium == .urban ? "urban" : "rural"))
                    AppRouter.shared.goToForms(from: self)
                } else {
                    let alert = UIAlertController(title: "Error".localized,
                                                  message: error?.localizedDescription ?? "An error occured",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

    }
}
