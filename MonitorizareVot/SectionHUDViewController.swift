//
//  SectionHUDViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit


/// Use this controller to show the currently selected section, as well as a button that takes you to change it
/// in most view controllers at the top of the screen, right below the nav bar
class SectionHUDViewController: UIViewController {
    
    var model = SectionHUDViewModel()

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    /// Set this to the callback that needs to be messaged when the user taps the change button
    var onChangeAction: (() -> Void)?
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubViews()
        configureTexts()
    }
    
    // MARK: - UI
    
    fileprivate func configureSubViews() {
        view.backgroundColor = .headerBackground
        
        let lighterTextColor = UIColor.defaultText.withAlphaComponent(0.5)
        icon.tintColor = lighterTextColor
        titleLabel.textColor = lighterTextColor
        changeButton.setTitleColor(.navigationBarBackground, for: .normal)
    }
    
    fileprivate func configureTexts() {
        changeButton?.setTitle("Button_ChangeDepartemnt".localized, for: .normal)
        titleLabel.text = model.sectionName
    }
    
    // MARK: - Actions
    
    @IBAction func handleChangeButtonTap(_ sender: Any) {
        onChangeAction?()
    }
}
