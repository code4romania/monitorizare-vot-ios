//
//  AddNoteViewController.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate, MVUITextViewDelegate {
    
    // MARK: - iVars
    var presidingOfficer: PresidingOfficer?
    private var note: Note?
    private var noteSaver = NoteSaver()
    @IBOutlet weak var bottomButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: MVUITextView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextView.customDelegate = self
        bodyTextView.placeholder = "Scrie aici ..."
        if let presidingOfficer = self.presidingOfficer {
            note = Note(presidingOfficer: presidingOfficer)
        }
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNoteViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNoteViewController.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Utils
    func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraint.constant = frame.size.height - bottomButtonHeight.constant
            performKeyboardAnimation()
        }
    }
    
    func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    func keyboardIsHidden() {
        bottomConstraint?.constant = 0
        performKeyboardAnimation()
    }
    
    private func layout() {
        bottomRightButton.layer.defaultCornerRadius(borderColor: UIColor.darkGray.cgColor)
        bodyTextView.inputView?.layer.defaultCornerRadius(borderColor: UIColor.darkGray.cgColor)
    }
    
    // MARK: - IBActions
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let note = self.note {
            noteSaver.save(note: note)
        }
    }
    
    @IBAction func bottomRightButtonTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - MVUITextViewDelegate
    func textView(textView: MVUITextView, didChangeText text: String) {
        note?.body = text
    }
    
}
