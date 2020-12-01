//
//  FormSetsViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SnapKit

class FormListViewController: MVViewController {
    
    var model: FormListViewModel
    
    @IBOutlet weak var syncContainer: UIView!
    
    @IBOutlet weak var downloadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var errorContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: ActionButton!
    
    // MARK: - Object
    
    init(withModel model: FormListViewModel) {
        self.model = model
        super.init(nibName: "FormListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureChildren()
        configureSubviews()
        addMenuButtonToNavBar()
        bindToUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateLabelsTexts()
        model.reload()
        updateInterface()
        DispatchQueue.main.async {
            if self.model.forms.isEmpty {
                // only show the spinner and hide the table view if there are no forms
                self.tableView.isHidden = true
                self.downloadingSpinner.startAnimating()
            }
            self.errorContainer.isHidden = true
            self.model.downloadFreshData()
        }
    }
    
    // MARK: - Config
    
    fileprivate func bindToUpdates() {
        model.onDownloadComplete = { [weak self] error in
            guard let self = self else { return }
            self.downloadingSpinner.stopAnimating()
            
            // if there's an error, show the error container
            if let _ = error {
                self.errorContainer.isHidden = false
                self.tableView.isHidden = true
                self.syncContainer.alpha = 0
            } else {
                self.tableView.isHidden = false
                self.syncContainer.alpha = 1
                self.updateInterface()
            }
            
            // alternate way - only show if there's no info loaded
//            if self.model.forms.isEmpty {
//                // only treat this as a failure if we have no forms yet.
//                // otherwise, leave the older versions
//                if let _ = error {
//                    self.errorContainer.isHidden = false
//                    self.tableView.isHidden = true
//                } else {
//                    self.updateInterface()
//                }
//            } else {
//                self.tableView.isHidden = false
//                self.errorContainer.isHidden = true
//                self.updateInterface()
//            }
        }
        model.onDownloadingStateChanged = { [weak self] in
            guard let self = self else { return }
            self.model.isDownloadingData ? self.downloadingSpinner.startAnimating() : self.downloadingSpinner.stopAnimating()
            self.tableView.alpha = self.model.isDownloadingData ? 0.3 : 1
            self.tableView.isUserInteractionEnabled = !self.model.isDownloadingData
            self.syncContainer.alpha = self.model.isDownloadingData ? 0 : 1
        }
    }

    fileprivate func configureSubviews() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "FormSetTableCell", bundle: nil),
                           forCellReuseIdentifier: FormSetTableCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        errorContainer.isHidden = true
    }
    
    private func configureChildren() {
        let syncStatus = SyncStatusViewController()
        addChild(syncStatus)
        syncStatus.didMove(toParent: self)
        syncContainer.addSubview(syncStatus.view)
        syncStatus.view.snp.makeConstraints { make in
            make.edges.equalTo(self.syncContainer)
        }
    }
    
    // MARK: - UI
    
    fileprivate func updateInterface() {
        tableView.reloadData()
    }
    
    fileprivate func updateLabelsTexts() {
        title = "Title.FormSets".localized
        retryButton.setTitle("Button_Retry".localized, for: .normal)
        errorLabel.text = "Error.FormDownloadFailed".localized
    }
    
    // MARK: - Logic
    
    // MARK: - Actions
    
    @IBAction func handleRetryButtonAction(_ sender: Any) {
        errorContainer.isHidden = true
        downloadingSpinner.startAnimating()
        tableView.isHidden = true
        model.downloadFreshData()
    }
    
    fileprivate func continueToForm(withCode code: String) {
        guard let questionsModel = QuestionListViewModel(withFormUsingCode: code) else {
            let message = "Error: can't load question list model for form with code \(code)"
            let alert = UIAlertController.error(withMessage: message)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let questionsVC = QuestionListViewController(withModel: questionsModel)
        navigationController?.pushViewController(questionsVC, animated: true)
        AppRouter.shared.resetDetailsPane()
    }
    
    fileprivate func continueToNote() {
        AppRouter.shared.openAddNote()
    }
}

// MARK: - Table View Data Source + Delegate

extension FormListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model.forms.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormSetTableCell.reuseIdentifier,
                                                       for: indexPath) as? FormSetTableCell else { fatalError("Wrong cell type") }
        switch indexPath.section {
        case 0:
            let cellModel = model.forms[indexPath.row]
            cell.update(withModel: cellModel)
        default:
            // note cell
            cell.updateAsNote()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: .zero)
        header.backgroundColor = .clear
        return header
    }
}

extension FormListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // form was tapped
            let formSet = model.forms[indexPath.row]
            continueToForm(withCode: formSet.code)
            break
        default:
            // add note was tapped
            continueToNote()
            break
        }
    }
}
