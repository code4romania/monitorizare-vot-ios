//
//  FormSetsViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class FormListViewController: MVViewController {
    
    var model: FormListViewModel
    
    @IBOutlet weak var syncingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var syncDetailsLabel: UILabel!
    @IBOutlet weak var syncButton: ActionButton!
    @IBOutlet weak var syncContainerHeightZero: NSLayoutConstraint!
    @IBOutlet weak var syncContainer: UIView!
    
    @IBOutlet weak var retryButton: ActionButton!
    @IBOutlet weak var downloadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerContainer: UIView!
    weak var headerViewController: SectionHUDViewController?
    
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
        title = "Title.FormSets".localized
        configureSubviews()
        configureHeader()
        addContactDetailsToNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
        bindToUpdates()
        DispatchQueue.main.async {
            self.configureSyncContainer()
            self.model.downloadFreshData()
        }
    }
    
    // MARK: - Config
    
    fileprivate func bindToUpdates() {
        model.onDownloadComplete = { [weak self] error in
            if let _ = error {
                let alert = UIAlertController(title: "Error".localized,
                                              message: "Error.DataDownloadFailed".localized,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                self?.retryButton.isHidden = false
            } else {
                self?.updateInterface()
            }
        }
        model.onDownloadingStateChanged = { [weak self] in
            guard let self = self else { return }
            self.model.isDownloadingData ? self.downloadingSpinner.startAnimating() : self.downloadingSpinner.stopAnimating()
            self.tableView.alpha = self.model.isDownloadingData ? 0.3 : 1
            self.tableView.isUserInteractionEnabled = !self.model.isDownloadingData
            self.syncContainer.alpha = self.model.isDownloadingData ? 0 : 1
        }
        model.onSyncingStateChanged = { [weak self] in
            guard let self = self else { return }
            self.model.isSynchronising ? self.syncingSpinner.startAnimating() : self.syncingSpinner.stopAnimating()
            self.tableView.alpha = self.model.isSynchronising ? 0.3 : 1
        }
    }

    fileprivate func configureSubviews() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "FormSetTableCell", bundle: nil),
                           forCellReuseIdentifier: FormSetTableCell.reuseIdentifier)
        retryButton.isHidden = true
    }
    
    fileprivate func configureHeader() {
        let controller = SectionHUDViewController()
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        controller.willMove(toParent: self)
        addChild(controller)
        controller.view.frame = headerContainer.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerContainer.addSubview(controller.view)
        controller.didMove(toParent: self)
        headerViewController = controller
        controller.onChangeAction = { [weak self] in
            self?.handleChangeSectionButtonAction()
        }
    }
    
    fileprivate func configureSyncContainer() {
        let needsSync = DBSyncer.shared.needsSync()
        setSyncContainer(hidden: !needsSync)
    }

    // MARK: - UI
    
    fileprivate func updateInterface() {
        tableView.reloadData()
    }
    
    fileprivate func updateLabelsTexts() {
        syncDetailsLabel.text = "Info.DataNotSyncronised".localized
        syncButton.setTitle("Button_SyncData".localized, for: .normal)
        retryButton.setTitle("Button_Retry".localized, for: .normal)
    }
    
    fileprivate func setSyncContainer(hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.setSyncContainer(hidden: hidden)
        }
    }

    fileprivate func setSyncContainer(hidden: Bool) {
        syncContainerHeightZero.isActive = hidden
        view.layoutIfNeeded()
    }

    // MARK: - Logic
    
    // MARK: - Actions
    
    fileprivate func handleChangeSectionButtonAction() {
        // simply take the user back to the section selection screen
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func handleRetryButtonAction(_ sender: Any) {
        retryButton.isHidden = true
        model.downloadFreshData()
    }
    
    @IBAction func handleSyncButtonAction(_ sender: Any) {
        // TODO: implement progress once the API Calls are refactored
        setSyncContainer(hidden: true, animated: true)
        DBSyncer.shared.syncUnsyncedData()
    }
    
    fileprivate func continueToForm(withCode code: String) {
        // TODO: replace all this after refactoring the form
        let localFormProvider = LocalFormProvider()
        let formViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FormViewController") as! FormViewController
        let persistedSectionInfo = DBSyncer.shared.sectionInfo(
            for: PreferencesManager.shared.county!,
            sectie: PreferencesManager.shared.section!)
        if let form = localFormProvider.getForm(named: code) {
            var questions = [MVQuestion]()
            for aSection in form.sections {
                if let persistedQuestions = persistedSectionInfo.questions as? Set<Question> {
                    let persistedQuestionsArray = Array(persistedQuestions)
                    for questionToAdd in aSection.questions {
                        let indexOfPersistedQuestionInSection = persistedQuestionsArray.firstIndex { (persistedQuestion: Question) -> Bool in
                            return persistedQuestion.id == questionToAdd.id
                        }
                        if let indexOfPersistedQuestionInSection = indexOfPersistedQuestionInSection {
                            let dbSyncer = DBSyncer()
                            let persistedQuestion = persistedQuestionsArray[indexOfPersistedQuestionInSection]
                            let parsedQuestions = dbSyncer.parseQuestions(questionsToParse: [persistedQuestion])
                            questions.append(parsedQuestions.first!)
                        }
                        else {
                            questions.append(questionToAdd)
                        }
                    }
                }
                else {
                    questions.append(contentsOf: aSection.questions)
                }
            }
            formViewController.questions = questions
            formViewController.form = code
//            formViewController.sectionInfo = sectionInfo
//            formViewController.persistedSectionInfo = persistedSectionInfo
            formViewController.title = form.title
            self.navigationController?.pushViewController(formViewController, animated: true)
        }
    }
    
    fileprivate func continueToNote() {
        // TODO: replace this after refactoring the note
        let addNoteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNoteViewController") as! AddNoteViewController
        self.navigationController?.pushViewController(addNoteViewController, animated: true)
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
            // set was tapped
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
