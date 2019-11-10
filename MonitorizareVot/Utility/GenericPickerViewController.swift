//
//  GenericPickerViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class GenericPickerViewController: UIViewController {
    
    var model: GenericPickerViewModel

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var container: UIView!
    
    var onCompletion: ((_ value: GenericPickerValue?) -> Void)?
    
    init(withModel model: GenericPickerViewModel) {
        self.model = model
        super.init(nibName: "GenericPickerViewController", bundle: nil)
        if #available(iOS 13.0, *) {
            modalPresentationStyle = .automatic
        } else {
            modalPresentationStyle = .overCurrentContext
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTexts()
        configureView()
        picker.selectRow(model.selectedIndex, inComponent: 0, animated: false)
    }
    
    // MARK: - Config
    
    fileprivate func configureView() {
        container.backgroundColor = .navigationBarBackground
        container.tintColor = .navigationBarTint
        container.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        container.layer.shadowRadius = Configuration.shadowRadius
        container.layer.shadowOffset = .zero
        container.layer.shadowOpacity = Configuration.shadowOpacity
        container.layer.cornerRadius = Configuration.buttonCornerRadius
    }
    
    fileprivate func configureTexts() {
        doneButton.setTitle("Select".localized, for: .normal)
        cancelButton.setTitle("Cancel".localized, for: .normal)
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButtonTap(_ sender: Any) {
        onCompletion?(model.selectedValue)
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        onCompletion?(nil)
    }

}


extension GenericPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        model.selectedIndex = row
    }
}

extension GenericPickerViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return model.values[row].displayName
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
