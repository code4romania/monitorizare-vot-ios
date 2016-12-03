//
//  AddNoteViewController.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AddNoteViewController: RootViewController, UITextViewDelegate, MVUITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - iVars
    var presidingOfficer: MVPresidingOfficer?
    private var note: MVNote?
    private var noteSaver = NoteSaver()
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var cameraPicker: UIImagePickerController?
    @IBOutlet weak var bottomButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var bottomLeftLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: MVUITextView!
    @IBOutlet weak var textViewBackgroundView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextView.customDelegate = self
        bodyTextView.placeholder = "Scrie aici ..."
        if let presidingOfficer = self.presidingOfficer {
            note = MVNote(presidingOfficer: presidingOfficer)
        }
        layout()
        setTapGestureRecognizer()
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
        bodyTextView.resignFirstResponder()
    }
    
    private func layout() {
        textViewBackgroundView.layer.defaultCornerRadius(borderColor: MVColors.lightGray.cgColor)
        bottomRightButton.layer.defaultCornerRadius(borderColor: MVColors.lightGray.cgColor)
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddNoteViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - IBActions
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        bodyTextView.resignFirstResponder()
        if let note = self.note {
            loadingView.isHidden = false
            noteSaver.save(note: note, completion: { 
                let _ = self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func bottomRightButtonTapped(_ sender: UIButton) {
        bodyTextView.resignFirstResponder()
        if note?.image == nil {
            switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            case .authorized, .notDetermined:
                let cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                self.cameraPicker = cameraPicker
                navigationController?.present(cameraPicker, animated: true, completion: nil)
            case .denied, .restricted:
                let appSettings = UIAlertAction(title: "Setări", style: .default) { (action) in
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                }
                let cancel = UIAlertAction(title: "Închide", style: .cancel, handler: nil)
                
                let alertController = UIAlertController(title: "Accessul este restricționat", message: "Te rugăm să accesezi setările și să ne oferi permisiuni de acces la librăria de poze.", preferredStyle: .alert)
                alertController.addAction(appSettings)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            note?.image = nil
            bottomLeftLabel.text = "Adaugă o fotografie"
            bottomRightButton.setImage(UIImage(named: "camera")!, for: .normal)
        }
    }
    
    // MARK: - MVUITextViewDelegate
    func textView(textView: MVUITextView, didChangeText text: String) {
        note?.body = text
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: false, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            note?.image = image
            bottomLeftLabel.text = "Șterge"
            bottomRightButton.setImage(UIImage(named: "trash")!, for: .normal)
        }
    }
    
}
