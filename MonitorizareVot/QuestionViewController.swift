//  Created by Code4Romania

import Foundation
import UIKit

protocol QuestionViewControllerDelegate: class {
    func showNextQuestion(currentQuestion: MVQuestion)
    func showPreviousQuestion(currentQuestion: MVQuestion)
}

class QuestionViewController: RootViewController, UITableViewDataSource, UITableViewDelegate, AnswerTableViewCellDelegate, ButtonHandler, AddNoteViewControllerDelegate {
    
    // MARK: - iVars
    var question: MVQuestion?
    var sectionInfo: MVSectionInfo?
    var persistedSectionInfo: SectionInfo? {
        didSet {
            answeredQuestionSaver.persistedSectionInfo = persistedSectionInfo
        }
    }
    private let answerWithTextTableViewCellConfigurator = AnswerWithTextTableViewCellConfigurator()
    private let basicAnswerTableViewCellConfigurator = BasicAnswerTableViewCellConfigurator()
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var answeredQuestionSaver = AnsweredQuestionSaver()
    private var addNoteViewController: AddNoteViewController?
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loadingView: UIView!
    weak var delegate: QuestionViewControllerDelegate?
    
    /// Tells you if the text answer was selected by the user. This will allow you to automatically make the text view first responder while still not doing it when the user enters the screen
    var isTextAnswerManuallySelected = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell(identifier: "AnswerWithTextTableViewCell")
        registerCell(identifier: "BasicAnswerTableViewCell")
        registerCell(identifier: "QuestionBodyTableViewCell")
        setTapGestureRecognizer()
        tableView.rowHeight = UITableView.automaticDimension
        continueButton?.setTitle("Button_NextQuestion".localized, for: .normal)
        
        addGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let question = self.question, let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? QuestionBodyTableViewCell {
            if question.note == nil  {
                firstCell.button.setTitle("Button_AddNoteToQuestion".localized, for: .normal)
            } else {
                firstCell.button.setTitle("Button_EditNote".localized, for: .normal)
            }
        }
        
        // disable the default swipe to go back in the nav controller hierarchy so it will not
        // interfere with the swipe gesture to go back to the previous question
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)


        // re-enable the default swipe to go back on the nav controller that we disabled in viewDidAppear
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

    }
    
    // MARK: - Utils
    @objc func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            var inset = continueButton.frame.size.height
            if #available(iOS 11.0, *) {
                inset += view.safeAreaInsets.bottom
            }
            bottomConstraint.constant = frame.size.height - inset
            performKeyboardAnimation()
            
            // scroll the tableview to bottom to reveal the text view
            DispatchQueue.main.async {
                self.tableView.layoutIfNeeded()
                var visibleRect = CGRect(origin: .zero, size: self.tableView.frame.size)
                visibleRect.origin.y = self.tableView.contentSize.height - visibleRect.size.height
                self.tableView.scrollRectToVisible(visibleRect, animated: true)
            }
        }
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    @objc func keyboardIsHidden() {
        bottomConstraint?.constant = 0
        performKeyboardAnimation()
        let cells = tableView.visibleCells
        for aCell in cells {
            if let aCell = aCell as? AnswerWithTextTableViewCell {
                aCell.textView.resignFirstResponder()
            }
        }
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestionViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func registerCell(identifier: String) {
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    private func hasAtLeastOneAnswer(answers: [MVAnswer]) -> Bool {
        for aAnswer in answers {
            if aAnswer.selected == true {
                return true
            }
        }
        return false
    }
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let question = self.question {
            return question.answers.count + 1
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionBodyTableViewCell") as! QuestionBodyTableViewCell
            cell.label.text = question!.text
            cell.delegate = self
            if let question = question, question.note == nil  {
                cell.button.setTitle("Button_AddNoteToQuestion".localized, for: .normal)
            } else {
                cell.button.setTitle("Button_EditNote".localized, for: .normal)
            }
            return cell
        }
        
        let answer = question!.answers[indexPath.row-1]
        
        if answer.inputAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AnswerWithTextTableViewCell") as! AnswerWithTextTableViewCell
            cell = answerWithTextTableViewCellConfigurator.configure(cell: cell, answer: answer, delegate: self, selected: answer.selected) as! AnswerWithTextTableViewCell
            if answer.selected && isTextAnswerManuallySelected {
                DispatchQueue.main.async {
                    cell.textView.becomeFirstResponder()
                }
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "BasicAnswerTableViewCell") as! BasicAnswerTableViewCell
            cell = basicAnswerTableViewCellConfigurator.configure(cell: cell, answer: answer, delegate: self, selected: answer.selected) as! BasicAnswerTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        
        let answer = question!.answers[indexPath.row - 1]
        if answer.inputAvailable && answer.selected {
            return 234
        }
        return 64
    }

    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: UIButton) {
        loadingView.isHidden = false
        let answeredQuestion = AnsweredQuestion(question: question!, sectionInfo: sectionInfo!)
        if let answers = question?.answers {
            if hasAtLeastOneAnswer(answers: answers) {
                answeredQuestionSaver.save(answeredQuestion: answeredQuestion) {[weak self] (success, tokenExpired) in
                    self?.loadingView.isHidden = true
                    if tokenExpired {
                        let _ = self?.navigationController?.popToRootViewController(animated: false)
                    } else {
                        self?.delegate?.showNextQuestion(currentQuestion: answeredQuestion.question)
                    }
                }
            } else {
                delegate?.showNextQuestion(currentQuestion: answeredQuestion.question)
            }
        }
    }
    
    // MARK: - AnswerTableViewCellDelegate
    func didTapOnButton(answer: MVAnswer) {
        let newAnswer = MVAnswer(id: answer.id, text: answer.text, selected: !answer.selected, inputAvailable: answer.inputAvailable, inputText: answer.inputText)
        
        isTextAnswerManuallySelected = true
        
        var answers = [MVAnswer]()
        if let question = self.question {
            for aAnswer in question.answers {
                if aAnswer.id != newAnswer.id {
                    if question.type == .MultipleAnswer || question.type == .MultipleAnswerWithText {
                        answers.append(aAnswer)
                    } else {
                        let newAnswer = MVAnswer(id: aAnswer.id, text: aAnswer.text, selected: false, inputAvailable: aAnswer.inputAvailable, inputText: aAnswer.inputText)
                        answers.append(newAnswer)   
                    }
                } else {
                    answers.append(newAnswer)
                }
            }
            let questionUpdated = MVQuestion(form: question.form, id: question.id, text: question.text, type: question.type, answered: true, answers: answers, synced: false, sectionInfo: nil, note: question.note)
            self.question = questionUpdated
            tableView.reloadData()
        }
    }
    
    func didChangeText(answer: MVAnswer, text: String) {
        let newAnswer = MVAnswer(id: answer.id, text: answer.text, selected: answer.selected, inputAvailable: answer.inputAvailable, inputText: text)
        
        var answers = [MVAnswer]()
        if let question = self.question {
            for aAnswer in question.answers {
                if aAnswer.id != newAnswer.id {
                    answers.append(aAnswer)
                } else {
                    answers.append(newAnswer)
                }
            }
            let questionUpdated = MVQuestion(form: question.form, id: question.id, text: question.text, type: question.type, answered: question.answered, answers: answers, synced: false, sectionInfo: nil, note: question.note)
            self.question = questionUpdated
        }
    }
    
    // MARK: - ButtonHandler
    func didTapOnButton() {
        if let addNoteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNoteViewController") as? AddNoteViewController {
            addNoteViewController.delegate = self
            addNoteViewController.sectionInfo = sectionInfo
            addNoteViewController.note = question?.note
            addNoteViewController.questionID = question?.id
            self.navigationController?.pushViewController(addNoteViewController, animated: true)
        }
    }
    
    // MARK: - AddNoteViewControllerDelegate
    func attach(note: MVNote) {
        question?.note = note
    }
    
    // MARK: - Gestures
    
    fileprivate func addGestureRecognizers() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc fileprivate func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let question = question else { return }
        delegate?.showPreviousQuestion(currentQuestion: question)
    }

}
