//
//  TextEntryViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 30/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

class TextEntryViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomContainer: UIView!
    
    var initialText: String?
    
    var onClose: ((String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            bottomContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(handleCloseAction(_:)))
        isModalInPopover = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = initialText {
            textView.text = text
        }
        textView.becomeFirstResponder()
    }

    @IBAction func handleSaveAction(_ sender: Any) {
        onClose?(textView.text)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleCloseAction(_ sender: Any) {
        onClose?(initialText)
        dismiss(animated: true, completion: nil)
    }

}
