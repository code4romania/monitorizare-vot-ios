//  Created by Code4Romania

import Foundation
import UIKit
import CoreData

class SectionInformationsViewController: RootViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - iVars
    var presidingOfficer: MVPresidingOfficer?
    var topLabelText: String?
    private var pickerViewSelection: PickerViewSelection?
    private var sectionSaver = SectionSaver()
    @IBOutlet private var formsButtons: [UIButton]!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
    @IBOutlet private weak var thirdButton: UIButton!
    @IBOutlet private weak var fourthButton: UIButton!
    @IBOutlet private weak var fifthButton: UIButton!
    @IBOutlet private weak var sixthButton: UIButton!
    @IBOutlet private weak var pickerContainer: UIView!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet weak var loadingDataView: UIView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupOutlets()
        presidingOfficer?.resetSectionInformations()
        pickerContainer.isHidden = true
        fifthButton.setTitle("Alege...", with: MVColors.lightGray.color, for: .normal)
        sixthButton.setTitle("Alege...", with: MVColors.lightGray.color, for: .normal)
        
        if let topLabelText = self.topLabelText {
            self.navigationItem.set(title: topLabelText, subtitle: "Informații despre secție")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetHourButtons()
        checkLocalStorage()
    }
    
    // MARK: - IBActions
    @IBAction func topRightButtonPressed(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: secondButton, selected: false)
        presidingOfficer?.medium = "urban"
        UserDefaults.standard.set("urban", forKey: "medium")
    }

    @IBAction func secondButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: firstButton, selected: false)
        presidingOfficer?.medium = "rural"
        UserDefaults.standard.set("rural", forKey: "medium")
    }
    
    @IBAction func thirdButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: fourthButton, selected: false)
        presidingOfficer?.genre = "masculin"
        UserDefaults.standard.set("masculin", forKey: "genre")
    }
    
    @IBAction func fourthButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: thirdButton, selected: false)
        presidingOfficer?.genre = "feminin"
        UserDefaults.standard.set("feminin", forKey: "genre")
    }
    
    @IBAction func fifthButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .sosire
        pickerContainer.isHidden = false
    }
    
    @IBAction func sixthButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .plecare
        pickerContainer.isHidden = false
    }
    
    @IBAction func bottomButtonTapped(_ sender: UIButton) {
        if let pickFormViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PickFormViewController") as? PickFormViewController, let presidingOfficer = self.presidingOfficer {
            pickFormViewController.presidingOfficer = presidingOfficer
            pickFormViewController.topLabelText = presidingOfficer.judet! + " " + String(presidingOfficer.sectie!)
            loadingDataView.isHidden = false
            sectionSaver.save(presidingOfficer: presidingOfficer, completion: {[weak self] (success, tokenExpired) in
                self?.loadingDataView.isHidden = true
                if tokenExpired {
                    let _ = self?.navigationController?.popToRootViewController(animated: false)
                } else {
                    self?.navigationController?.pushViewController(pickFormViewController, animated: true)
                }
            })
        }
    }
    
    @IBAction func pickerButton(_ sender: UIButton) {
        pickerContainer.isHidden = true
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.selectRow(0, inComponent: 1, animated: false)
    }
    
    // MARK: - Utils
    private func resetHourButtons() {
        sixthButton.setTitle("00:00", for:.normal)
        fifthButton.setTitle("00:00", for:.normal)
    }
    
    private func checkLocalStorage() {
        if let medium = UserDefaults.standard.value(forKey: "medium") as? String {
            presidingOfficer?.medium = medium
            adjustButton(button: firstButton, selected: (medium == "urban") ? true : false)
            adjustButton(button: secondButton, selected: (medium == "rural") ? true : false)
        }
        
        if let genre = UserDefaults.standard.value(forKey: "genre") as? String {
            presidingOfficer?.genre = genre
            adjustButton(button: thirdButton, selected: (genre == "masculin") ? true : false)
            adjustButton(button: fourthButton, selected: (genre == "feminin") ? true : false)
        }
        
        let arriveHour = UserDefaults.standard.value(forKey: "arriveHour")
        let arriveMinute = UserDefaults.standard.value(forKey: "arriveMinute")
        
        var firstButtonTitle = "00:00"
        if let arriveHourString = arriveHour as? String, let arriveMinuteString = arriveMinute as? String {
            firstButtonTitle = arriveHourString + ":" + arriveMinuteString
            presidingOfficer?.arriveHour = arriveHourString
            presidingOfficer?.arriveMinute = arriveMinuteString
        } else if let arriveHourString = arriveHour as? String {
            firstButtonTitle = arriveHourString + ":00"
            presidingOfficer?.arriveHour = arriveHourString
        } else if let arriveMinuteString = arriveMinute as? String {
            firstButtonTitle =  "00:" + arriveMinuteString
            presidingOfficer?.arriveMinute = arriveMinuteString
        }
        fifthButton.setTitle(firstButtonTitle, with: MVColors.black.color, for: .normal)
        
        let leftHour = UserDefaults.standard.value(forKey: "leftHour")
        let leftMinute = UserDefaults.standard.value(forKey: "leftMinute")
        
        var secondButtonTitle = "00:00"
        if let leftHourString = leftHour as? String, let leftMinuteString = leftMinute as? String {
            secondButtonTitle = leftHourString + ":" + leftMinuteString
            presidingOfficer?.leftHour = leftHourString
            presidingOfficer?.leftMinute = leftMinuteString
        } else if let leftHourString = leftHour as? String {
            secondButtonTitle = leftHourString + ":00"
            presidingOfficer?.leftHour = leftHourString
        } else if let leftMinuteString = leftMinute as? String {
            secondButtonTitle =  "00:" + leftMinuteString
            presidingOfficer?.leftMinute = leftMinuteString
        }
        sixthButton.setTitle(secondButtonTitle, with: MVColors.black.color, for: .normal)
    }
    
    private func adjustButton(button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = MVColors.yellow.color
        } else {
            button.backgroundColor = MVColors.white.color
        }
    }
    
    private func layout() {
        for aButton in formsButtons {
            aButton.layer.defaultCornerRadius(borderColor: MVColors.lightGray.cgColor)
        }
        topButton.layer.defaultCornerRadius(borderColor: MVColors.gray.cgColor)
    }
    
    private func setupOutlets() {
        if let topLabelText = self.topLabelText {
            topLabel.text = topLabelText
        }
    }
    
    private func setupButtonsWithPickerValues() {
        if let presidingOfficer = self.presidingOfficer {
            let arriveHour = presidingOfficer.arriveHour
            let arriveMinute =  presidingOfficer.arriveMinute
            fifthButton.setTitle(arriveHour + ":" + arriveMinute, with: MVColors.black.color, for: .normal)
            
            let leftHour = presidingOfficer.leftHour
            let leftMinute = presidingOfficer.leftMinute
            sixthButton.setTitle(leftHour + ":" + leftMinute, with: MVColors.black.color, for: .normal)
        }
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
            case .sosire:
                if component == 0 {
                    row < 10 ? (presidingOfficer?.arriveHour = "0" + String(row)) : (presidingOfficer?.arriveHour = String(row))
                    UserDefaults.standard.set(presidingOfficer?.arriveHour, forKey: "arriveHour")
                } else if component == 1 {
                    row < 10 ? (presidingOfficer?.arriveMinute = "0" + String(row)) : (presidingOfficer?.arriveMinute = String(row))
                    UserDefaults.standard.set(presidingOfficer?.arriveMinute, forKey: "arriveMinute")
                }
            case .plecare:
                if component == 0 {
                    row < 10 ? (presidingOfficer?.leftHour = "0" + String(row)) : (presidingOfficer?.leftHour = String(row))
                    UserDefaults.standard.set(presidingOfficer?.leftHour, forKey: "leftHour")
                } else if component == 1 {
                    row < 10 ? (presidingOfficer?.leftMinute = "0" + String(row)) : (presidingOfficer?.leftMinute = String(row))
                    UserDefaults.standard.set(presidingOfficer?.leftMinute, forKey: "leftMinute")
                }
            default:
                break
            }
            setupButtonsWithPickerValues()
        }
    }
    
    
}
