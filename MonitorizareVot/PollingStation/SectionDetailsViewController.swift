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
    
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var numberOfVotersLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var numberOfWomenLabel: UILabel!
    @IBOutlet weak var lowestNoMembersLabel: UILabel!
    @IBOutlet weak var chairmanPresentLabel: UILabel!
    @IBOutlet weak var onlyOneLabel: UILabel!
    @IBOutlet weak var sizeAdequateLabel: UILabel!
    
    @IBOutlet weak var arrivalButton: UIButton!
    @IBOutlet weak var departureButton: UIButton!
    @IBOutlet weak var numberOfVotersField: UITextField!
    @IBOutlet weak var numberOfMembersField: UITextField!
    @IBOutlet weak var numberOfWomenField: UITextField!
    @IBOutlet weak var lowestNoMembersField: UITextField!

    @IBOutlet weak var chairmanPresentNoButton: ChooserButton!
    @IBOutlet weak var chairmanPresentYesButton: ChooserButton!

    @IBOutlet weak var onlyOneNoButton: ChooserButton!
    @IBOutlet weak var onlyOneYesButton: ChooserButton!

    @IBOutlet weak var sizeAdequateNoButton: ChooserButton!
    @IBOutlet weak var sizeAdequateYesButton: ChooserButton!
    
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
        configureSubviews()
        bindToUpdates()
        addMenuButtonToNavBar()
        initializeValuesFromModel()
        isLoading = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabelsTexts()
        updateInterface()
    }
    
    // MARK: - Config
    
    fileprivate func bindToUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }

    fileprivate func configureSubviews() {
        let optionButtons: [UIButton] = [
            chairmanPresentNoButton,
            chairmanPresentYesButton,
            onlyOneNoButton,
            onlyOneYesButton,
            sizeAdequateNoButton,
            sizeAdequateYesButton
        ]
        optionButtons.forEach { button in
            button.addTarget(self, action: #selector(handleOptionButtonTap), for: .touchUpInside)
        }
        
        let textFields: [UITextField] = [
            numberOfVotersField,
            numberOfMembersField,
            numberOfWomenField,
            lowestNoMembersField
        ]
        textFields.forEach { textField in
            textField.delegate = self
        }
    }
    
    
    // MARK: - UI
    
    fileprivate func formattedTime(fromDate date: Date?) -> String {
        if let date = date {
            return timeFormatter.string(from: date)
        } else {
            return "--:--"
        }
    }
    
    fileprivate func initializeValuesFromModel() {
        numberOfVotersField.text = "\(model.numberOfVotersOnTheList ?? 0)"
        numberOfMembersField.text = "\(model.numberOfCommissionMembers ?? 0)"
        numberOfWomenField.text = "\(model.numberOfFemaleMembers ?? 0)"
        lowestNoMembersField.text = "\(model.minPresentMembers ?? 0)"
3    }
    
    fileprivate func updateInterface() {
        arrivalButton.setTitle(formattedTime(fromDate: model.arrivalTime), for: .normal)
        departureButton.setTitle(formattedTime(fromDate: model.leaveTime), for: .normal)

        chairmanPresentNoButton.isSelected = model.chairmanPresence == false
        chairmanPresentYesButton.isSelected = model.chairmanPresence == true
        onlyOneNoButton.isSelected = model.singlePollingStationOrCommission == false
        onlyOneYesButton.isSelected = model.singlePollingStationOrCommission == true
        sizeAdequateNoButton.isSelected = model.adequatePollingStationSize == false
        sizeAdequateYesButton.isSelected = model.adequatePollingStationSize == true
        
        continueButton.isEnabled = model.isReady
    }
    
    fileprivate func updateLabelsTexts() {
        title = "Title.StationDetails".localized

        arrivalTimeLabel.text = "Label_CountyArriveTime".localized
        departureTimeLabel.text = "Label_CountyLeaveTime".localized
        
        numberOfVotersLabel.text = "Label_CountyVotersCount".localized
        numberOfMembersLabel.text = "Label_CountyMembersCount".localized
        numberOfWomenLabel.text = "Label_CountyWomenCount".localized
        lowestNoMembersLabel.text = "Label_CountyLowestMemberCount".localized
        chairmanPresentLabel.text = "Label_CountyChairmanPresent".localized
        onlyOneLabel.text = "Label_CountyOnlyOneStation".localized
        sizeAdequateLabel.text = "Label_CountySizeAdequate".localized

        chairmanPresentNoButton.setTitle("Label_No".localized, for: .normal)
        chairmanPresentYesButton.setTitle("Label_Yes".localized, for: .normal)

        onlyOneNoButton.setTitle("Label_No".localized, for: .normal)
        onlyOneYesButton.setTitle("Label_Yes".localized, for: .normal)
        
        sizeAdequateNoButton.setTitle("Label_No".localized, for: .normal)
        sizeAdequateYesButton.setTitle("Label_Yes".localized, for: .normal)
        
        continueButton.setTitle("Button_ContinueToForms".localized, for: .normal)
    }
    
    // MARK: - Actions
    
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
    
    @objc func handleOptionButtonTap(_ sender: UIButton) {
        switch sender {
        case chairmanPresentNoButton:
            model.chairmanPresence = false
        case chairmanPresentYesButton:
            model.chairmanPresence = true
        case onlyOneNoButton:
            model.singlePollingStationOrCommission = false
        case onlyOneYesButton:
            model.singlePollingStationOrCommission = true
        case sizeAdequateNoButton:
            model.adequatePollingStationSize = false
        case sizeAdequateYesButton:
            model.adequatePollingStationSize = true
        default:
            break
        }
    }
}

extension SectionDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let replaced = (textField.text as? NSString)?.replacingCharacters(in: range, with: string) else { return false }
        
        if replaced.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        
        let numberValue = Int(replaced)
        
        switch textField {
        case numberOfVotersField:
            model.numberOfVotersOnTheList = numberValue
        case numberOfMembersField:
            model.numberOfCommissionMembers = numberValue
        case numberOfWomenField:
            model.numberOfFemaleMembers = numberValue
        case lowestNoMembersField:
            model.minPresentMembers = numberValue
        default:
            break
        }
        
        return true
    }
}
