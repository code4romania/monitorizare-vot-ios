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
    
    init(withModel model: GenericPickerViewModel) {
        self.model = model
        super.init(nibName: "GenericPickerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColors()
        configureTexts()
        // TODO: finish this implementation when refactoring the section picker screen
    }
    
    // MARK: - Config
    
    fileprivate func configureColors() {
        doneButton.setTitleColor(.navigationBarBackground, for: .normal)
        cancelButton.setTitleColor(.navigationBarBackground, for: .normal)
    }
    
    fileprivate func configureTexts() {
        // TODO:
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButtonTap(_ sender: Any) {
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
    }

}


extension GenericPickerViewController: UIPickerViewDelegate {
    
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
