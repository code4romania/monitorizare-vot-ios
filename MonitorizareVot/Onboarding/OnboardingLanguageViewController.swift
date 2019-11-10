//
//  OnboardingLanguageViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 04/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingLanguageViewController: UIViewController {
    
    let model = OnboardingLanguageViewModel()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageButton: DropdownButton!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateInterface()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    fileprivate func localize() {
        titleLabel.text = "Title.Language".localized
        nextButton.setTitle("Next".localized, for: .normal)
        languageButton.placeholder = "Label_SelectOption".localized
    }
    
    fileprivate func updateInterface() {
        if let selectedValue = model.selectedLanguage {
            languageButton.value = model.languageName(forIdentifier: selectedValue)
        } else {
            languageButton.value = nil
        }
        nextButton.isEnabled = model.selectedLanguage != nil
    }

    @IBAction func handleLanguageButtonTap(_ sender: Any) {
        let possibleValues = model.supportedLanguages.map { GenericPickerValue(id: $0, displayName: model.languageName(forIdentifier: $0)) }
        let pickerModel = GenericPickerViewModel(withValues: possibleValues)
        pickerModel.selectedIndex = model.selectedLanguageIndex ?? 0
        let controller = GenericPickerViewController(withModel: pickerModel)
        controller.onCompletion = { value in
            if let value = value?.id as? String {
                self.model.selectedLanguage = value
            }
            self.updateInterface()
            self.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func handleNextButtonTap(_ sender: Any) {
        model.save {
            let next = OnboardingViewController()
            navigationController?.setViewControllers([next], animated: true)
        }
    }

}
