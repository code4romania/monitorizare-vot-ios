//
//  PickFormViewController.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class PickFormViewController: UIViewController {
    
    // MARK: - iVars
    var presidingOfficer: PresidingOfficer?
    var topLabelText: String?
    private var localFormProvider = LocalFormProvider()
    @IBOutlet private var buttonsBackgroundViews: [UIView]!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupOutlets()
        if let topLabelText = self.topLabelText {
            self.navigationItem.set(title: topLabelText, subtitle: "Alege formular")
        }
    }
    
    // MARK: - IBActions
    @IBAction func firstButtonPressed(_ sender: UIButton) {
        pushFormViewController(type: "A")
    }
    
    @IBAction func secondButtonPressed(_ sender: UIButton) {
        pushFormViewController(type: "B")
    }
    
    @IBAction func thirdButtonPressed(_ sender: UIButton) {
        pushFormViewController(type: "C")
    }
    
    @IBAction func fourthButtonPressed(_ sender: UIButton) {
        let addNoteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNoteViewController") as! AddNoteViewController
        addNoteViewController.presidingOfficer = presidingOfficer
        self.navigationController?.pushViewController(addNoteViewController, animated: true)
    }
    
    @IBAction func topRightButtonPressed(_ sender: UIButton) {
        if let childs = self.navigationController?.childViewControllers {
            for aChild in childs {
                if aChild is SectieViewController {
                    self.navigationController?.popToViewController(aChild, animated: true)
                }
            }
        }
    }
    
    // MARK: - Utils
    private func layout() {
        for aView in buttonsBackgroundViews {
            aView.layer.dropDefaultShadow()
        }
        topButton.layer.defaultCornerRadius(borderColor: UIColor.gray.cgColor)
    }
    
    private func setupOutlets() {
        if let topLabelText = self.topLabelText {
            topLabel.text = topLabelText
        }
    }
    
    private func pushFormViewController(type: String) {
        let formViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FormViewController") as! FormViewController
        if let form = localFormProvider.getForm(named: type) {
            var questions = [Question]()
            for aSection in form.sections {
                questions.append(contentsOf: aSection.questions)
            }
            formViewController.questions = questions
            formViewController.form = type
            formViewController.topTitle = type + "." + form.title
            self.navigationController?.pushViewController(formViewController, animated: true)
        }
    }
}
