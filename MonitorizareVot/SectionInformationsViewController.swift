//
//  SecondFormViewController.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/15/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

enum PickerViewSelection {
    case Sosire
    case Plecare
}

class SectionInformationsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - iVars
    var presidingOfficer = PresidingOfficer()
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet var formsButtons: [UIButton]!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    @IBOutlet weak var fifthButton: UIButton!
    @IBOutlet weak var sixthButton: UIButton!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    private var pickerViewSelection: PickerViewSelection?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        pickerContainer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - IBActions
    @IBAction func topRightButtonPressed(_ sender: UIButton) {

    }
    
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: secondButton, selected: false)
        presidingOfficer.medium = "urban"
    }

    @IBAction func secondButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: firstButton, selected: false)
        presidingOfficer.medium = "rural"
    }
    
    @IBAction func thirdButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: fourthButton, selected: false)
        presidingOfficer.genre = "masculin"
    }
    
    @IBAction func fourthButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: thirdButton, selected: false)
        presidingOfficer.genre = "feminin"
    }
    
    @IBAction func fifthButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .Sosire
        pickerContainer.isHidden = false
    }
    
    @IBAction func sixthButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .Plecare
        pickerContainer.isHidden = false
    }
    
    @IBAction func bottomButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func pickerButton(_ sender: UIButton) {
        pickerContainer.isHidden = true
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.selectRow(0, inComponent: 1, animated: false)
    }
    
    // MARK: - Utils
    private func adjustButton(button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = MVColors.Yellow.color
        } else {
            button.backgroundColor = UIColor.white
        }
    }
    
    private func layout() {
        for aButton in formsButtons {
            aButton.layer.cornerRadius = 5
            aButton.layer.borderColor = UIColor.lightGray.cgColor
            aButton.layer.borderWidth = 1.0
        }
        
        topButton.layer.cornerRadius = 5
        topButton.layer.borderColor = UIColor.gray.cgColor
        topButton.layer.borderWidth = 1.0
    }
    
    private func setupButtonsWithPickerValues() {
        var arriveHour = "00"
        var arriveMinute = "00"
        var leftHour = "00"
        var leftMinute = "00"
        
        if let arriveSavedHour = presidingOfficer.arriveHour {
            if arriveSavedHour < 10 {
                arriveHour = "0" + String(arriveSavedHour)
            } else {
                arriveHour = String(arriveSavedHour)
            }
        }
        
        if let arriveSavedMinute = presidingOfficer.arriveMinute {
            if arriveSavedMinute < 10 {
                arriveMinute = "0" + String(arriveSavedMinute)
            } else {
                arriveMinute = String(arriveSavedMinute)
            }
        }
        fifthButton.setTitle(arriveHour + ":" + arriveMinute, for: .normal)
        
        if let leftSavedHour = presidingOfficer.leftHour {
            if leftSavedHour < 10 {
                leftHour = "0" + String(leftSavedHour)
            } else {
                leftHour = String(leftSavedHour)
            }
        }
        
        if let leftSavedMinute = presidingOfficer.leftMinute {
            if leftSavedMinute < 10 {
                leftMinute = "0" + String(leftSavedMinute)
            } else {
                leftMinute = String(leftSavedMinute)
            }
        }
        sixthButton.setTitle(leftHour + ":" + leftMinute, for: .normal)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        }
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < 10 {
            return "0" + String(row)
        }
        return String(row)
    }
    
    // MARK: - UIPickerviewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerViewSelection = self.pickerViewSelection {
            switch pickerViewSelection {
            case .Sosire:
                if component == 0 {
                    presidingOfficer.arriveHour = row
                } else if component == 1 {
                    presidingOfficer.arriveMinute = row
                }
            case .Plecare:
                if component == 0 {
                    presidingOfficer.leftHour = row
                } else if component == 1 {
                    presidingOfficer.leftMinute = row
                }
            }
            setupButtonsWithPickerValues()
        }
    }
    
    
}
