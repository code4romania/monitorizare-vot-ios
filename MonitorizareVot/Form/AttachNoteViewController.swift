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
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var attachmentStackView: UIStackView!
    @IBOutlet weak var attachButton: AttachButton!
    @IBOutlet weak var submitButton: ActionButton!
    
    @IBOutlet var attachmentsTableView: UITableView!
    @IBOutlet var attachmentsTableHeight: NSLayoutConstraint!
    
    var onAttachmentRequest: ((_ sourceView: UIView) -> Void)?
    
    /// Called back when a note was successfully saved (so you can update the interface with the latest data)
    var onNoteSaved: (() -> Void)?
    
    /// Called when the interface was updated. The frame might have changed  so you should
    /// probably do a layout pass
    var onInterfaceUpdate: (() -> Void)?
    
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
        textView.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 13, right: 10)
        textView.contentOffset = .zero
        textView.textColor = .defaultText
        
        
        attachmentsTableView.register(
            UINib(
                nibName: "NoteAttachmentTableCell",
                bundle: nil),
            forCellReuseIdentifier: NoteAttachmentTableCell.reuseIdentifier
        )
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
        submitButton.isEnabled = model.canBeSaved && !model.isSaving
        statusIcon.isHidden = !model.isSaved
        statusIcon.image = model.isSynced ? #imageLiteral(resourceName: "icon-check") : #imageLiteral(resourceName: "icon-check-greyed")
        textViewPlaceHolder.isHidden = model.text.count > 0
        
        if !textView.isFirstResponder {
            textView.text = model.text
        }
        
        attachmentsTableView.reloadData()
        attachmentsTableHeight.constant = attachmentsTableView.contentSize.height
        view.layoutIfNeeded()
        
        onInterfaceUpdate?()
    }
    
    // MARK: - Actions
    
    func handleMediaSelection(filename: String, data: Data) {
        do {
            try model.addAttachment(filename: filename, data: data)
        } catch {
            // TODO: localize error
            let alert = UIAlertController.error(withMessage: error.localizedDescription)
            self.present(alert, animated: true, completion: nil)
            return
        }
        updateInterface()
        view.layoutIfNeeded()
    }
    
    @IBAction func handleAttachAction(_ sender: UIButton) {
        onAttachmentRequest?(sender)
    }
    
    @IBAction func handleSubmitAction(_ sender: Any) {
        textView.resignFirstResponder()
        model.saveAndUpload { [weak self] error in
            guard let self = self else { return }
            if let error = error,
                case AttachNoteError.saveFailed = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.onNoteSaved?()
                
                // back out
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}

extension AttachNoteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.attachments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NoteAttachmentTableCell.reuseIdentifier, for: indexPath) as! NoteAttachmentTableCell
        let attachment = model.attachments[indexPath.row]
        cell.update(with: attachment)
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.model.removeAttachment(at: indexPath.row)
            self.updateInterface()
        }
        return cell
    }
}

extension AttachNoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let replaced = (textView.text as NSString).replacingCharacters(in: range, with: text)
        model.text = replaced
        return true
    }
}

extension NoteAttachmentTableCell {
    func update(with model: NoteAttachmentViewModel) {
        nameLabel.text = model.filename
    }
}
