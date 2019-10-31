//
//  DateTimePickerViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {

    var model: TimePickerViewModel

    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var onCompletion: ((_ date: Date?) -> Void)?
    
    init(withModel model: TimePickerViewModel) {
        self.model = model
        super.init(nibName: "TimePickerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColors()
        configureTexts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
        view.backgroundColor = .clear
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        }, completion: nil)
    }
    
    // MARK: - Config
    
    fileprivate func configureColors() {
        doneButton.setTitleColor(.navigationBarBackground, for: .normal)
        cancelButton.setTitleColor(.navigationBarBackground, for: .normal)
    }
    
    fileprivate func configureTexts() {
        // TODO:
    }
    
    fileprivate func updateInterface() {
        picker.date = model.date
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButtonTap(_ sender: Any) {
        onCompletion?(model.date)
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        onCompletion?(nil)
    }

    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        model.date = sender.date
    }
    
}
