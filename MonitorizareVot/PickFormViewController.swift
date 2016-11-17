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
    private var localFormProvider = LocalFormProvider()
    @IBOutlet var buttonsBackgroundViews: [UIView]!
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        
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
        
    }
    
    // MARK: - Utils
    private func layout() {
        for aView in buttonsBackgroundViews {
            aView.layer.cornerRadius = 4
            aView.layer.borderWidth = 1
            aView.layer.borderColor = UIColor(colorLiteralRed: 172.0/255.0, green:180.0/255.0, blue:190.0/255.0, alpha:1).cgColor
            aView.layer.shadowColor = UIColor.black.cgColor
            aView.layer.shadowRadius = 4
            aView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            aView.layer.shadowOpacity = 0.07
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
