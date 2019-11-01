//
//  AttachNoteViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 31/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

/// This class is used to allow the user to add a new note and it's part of the `NoteViewController` as
/// it backs that screen's history table view's header
class AttachNoteViewController: UIViewController {
    
    let model: AttachNoteViewModel
    
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var outerContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceHolder: UILabel!
    @IBOutlet weak var attachButton: AttachButton!
    @IBOutlet weak var submitButton: ActionButton!
    
    // MARK: - Object
    
    init(withModel model: AttachNoteViewModel) {
        self.model = model
        super.init(nibName: "AttachNoteViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        bindToModelUpdates()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureAppearance()
        updateInterface()
    }
    
    // MARK: - Config
    
    fileprivate func configureAppearance() {
        cardContainer.layer.masksToBounds = true
        cardContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        outerContainer.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        outerContainer.layer.shadowOffset = .zero
        outerContainer.layer.shadowRadius = Configuration.shadowRadius
        outerContainer.layer.shadowOpacity = Configuration.shadowOpacity
        titleLabel.textColor = .defaultText
        textViewContainer.layer.borderWidth = 1
        textViewContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        textViewContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        textView.textContainerInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        textView.contentOffset = .zero
        textView.textColor = .defaultText
    }
    
    fileprivate func localize() {
        titleLabel.text = "Label_AddNote".localized
        attachButton.setTitle("Button_AddPhotoVideo".localized, for: .normal)
        submitButton.setTitle("Button_Submit".localized, for: .normal)
        textViewPlaceHolder.text = "Label_TypeNote".localized
    }
    
    fileprivate func bindToModelUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }
    
    // MARK: - UI
    
    fileprivate func updateInterface() {
        submitButton.isEnabled = model.canBeSaved
        statusIcon.isHidden = !model.isSaved
        statusIcon.image = model.isSynced ? #imageLiteral(resourceName: "icon-check") : #imageLiteral(resourceName: "icon-check-greyed")
        textViewPlaceHolder.isHidden = model.text.count > 0
    }
    
    // MARK: - Actions
    
    @IBAction func handleAttachAction(_ sender: Any) {
        // TODO:
    }
    
    @IBAction func handleSubmitAction(_ sender: Any) {
        submitButton.isEnabled = false
        model.saveAndUpload { [weak self] error in
            guard let self = self else { return }
            if let error = error,
                case AttachNoteError.saveFailed = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                self.submitButton.isEnabled = true
            } else {
                // back out
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}


extension AttachNoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let replaced = (textView.text as NSString).replacingCharacters(in: range, with: text)
        model.text = replaced
        return true
    }
}
