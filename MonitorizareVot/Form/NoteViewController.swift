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
        let noteModel = AttachNoteViewModel(withQuestionId: model.questionId)
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
        title = "Title.Note".localized
        configureTableView()
        addContactDetailsToNavBar()
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHeaderIfNecessary()
    }
    
    fileprivate func configureTableView() {
        if #available(iOS 11.0, *) {
            historyTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        historyTableView.register(UINib(nibName: "NoteHistoryTableCell", bundle: nil),
                                  forCellReuseIdentifier: NoteHistoryTableCell.reuseIdentifier)
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = 60
        
    }
    
    fileprivate func addHeaderIfNecessary() {
        let attachNote = attachNoteController
        if attachNote.parent == nil {
            addChild(attachNote)
        }
        
        attachNoteController.view.translatesAutoresizingMaskIntoConstraints = false
        attachNoteController.contentWidth.constant = view.frame.width
        attachNoteController.view.layoutIfNeeded()

        historyTableView.tableHeaderView = attachNote.content
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
        return model.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteHistoryTableCell.reuseIdentifier,
                                                 for: indexPath) as! NoteHistoryTableCell
        let cellModel = model.notes[indexPath.row]
        cell.update(withModel: cellModel)
        return cell
    }
}

extension NoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = tableView.bounds.width
        let header = DefaultTableHeader(frame: CGRect(x: 0, y: 0, width: width, height: TableSectionHeaderHeight))
        header.titleLabel.text = "Title.NoteHistory".localized
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableSectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TableSectionFooterHeight
    }
    
}

