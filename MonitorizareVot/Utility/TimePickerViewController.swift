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
    @IBOutlet weak var container: UIView!

    var onCompletion: ((_ date: Date?) -> Void)?
    
    init(withModel model: TimePickerViewModel) {
        self.model = model
        super.init(nibName: "TimePickerViewController", bundle: nil)
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
        configureView()
        configureTexts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
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
    
    fileprivate func updateInterface() {
        picker.date = model.date
        picker.minimumDate = model.minDate
        picker.maximumDate = model.maxDate
    }
    
    // MARK: - Actions

    @IBAction func handleDoneButtonTap(_ sender: Any) {
        model.date = picker.clampedDate
        onCompletion?(model.date)
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        onCompletion?(nil)
    }

    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        model.date = sender.date
    }
    
}

extension UIDatePicker {
    /// Returns the date that reflects the displayed date clamped to the `minuteInterval` of the picker.
    /// - note: Adapted from [ima747's](http://stackoverflow.com/users/463183/ima747) answer on [Stack Overflow](http://stackoverflow.com/questions/7504060/uidatepicker-with-15m-interval-but-always-exact-time-as-return-value/42263214#42263214})
    public var clampedDate: Date {
        let referenceTimeInterval = self.date.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTimeInterval.truncatingRemainder(dividingBy: TimeInterval(minuteInterval*60))
        let timeRoundedToInterval = referenceTimeInterval - remainingSeconds
        return Date(timeIntervalSinceReferenceDate: timeRoundedToInterval)
    }
}
