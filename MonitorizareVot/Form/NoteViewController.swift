//
//  NoteViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 31/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

/// This is the main Note screen. It shows the form to add a note, as well as the history of past notes
class NoteViewController: MVViewController {
    
    var model: NoteViewModel
    
    @IBOutlet weak var historyTableView: UITableView!
    
    /// This backs the history table view's header to allow the user to add notes
    lazy var attachNoteController: AttachNoteViewController = {
        let noteModel = AttachNoteViewModel()
        let controller = AttachNoteViewController(withModel: noteModel)
        return controller
    }()
    
    // MARK: - Object
    
    init(withModel model: NoteViewModel) {
        self.model = model
        super.init(nibName: "NoteViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        attachNoteController.removeFromParent()
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        addContactDetailsToNavBar()
        configureSubviews()
    }
    
    fileprivate func configureTableView() {
        if #available(iOS 11.0, *) {
            historyTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // TODO: register cell
        
        let attachNote = attachNoteController
        addChild(attachNote)
        historyTableView.tableHeaderView = attachNote.view
    }
    
    fileprivate func configureSubviews() {
        historyTableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }

}


extension NoteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
}
