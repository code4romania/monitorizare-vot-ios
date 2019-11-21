//
//  QuestionAnswerViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class QuestionAnswerViewController: MVViewController {
    
    /// Will post this notification every time the user goes to the next/previous question. You can listen to this in your question list and update as necessary
    static let questionChangedNotification = Notification.Name("QuestionChangedNotification")
    static let questionSavedNotification = Notification.Name("QuestionSavedNotification")
    static let questionUserInfoKey = "question"
    
    var model: QuestionAnswerViewModel
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: ActionButton!
    @IBOutlet weak var nextButton: ActionButton!
    
    /// we only keep this as a reference so we can send analytics events when the current question actually changes
    fileprivate var lastViewedQuestionIndex: Int?
    
    /// Set this to true before you scroll the collection view but it shouldn't be tracked. Set it back to true once that's complete
    fileprivate var scrollTrackingIsDisabled = false
    
    let HorizontalSpace: CGFloat = 8
    let HorizontalSectionInset: CGFloat = 8
    
    // MARK: - Object
    
    init(withModel model: QuestionAnswerViewModel) {
        self.model = model
        super.init(nibName: "QuestionAnswerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        if AppRouter.shared.isPad {
            shouldDisplayHeaderContainer = false
        }
        super.viewDidLoad()
        configureCollectionView()
        bindToUpdateEvents()
        if !AppRouter.shared.isPad {
            addContactDetailsToNavBar()
        }
        view.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.updateInterface()
            self.scrollToCurrentIndex()
            self.updateCurrentQuestionRelatedElements()
        }
    }
    
    // MARK: - Config
    
    fileprivate func configureCollectionView() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.insetsLayoutMarginsFromSafeArea = false
        }
        collectionView.register(UINib(nibName: "QuestionCollectionCell", bundle: nil),
                                forCellWithReuseIdentifier: QuestionCollectionCell.reuseIdentifier)
    }
    
    fileprivate func bindToUpdateEvents() {
        model.onModelUpdate = { [weak self] in
            NotificationCenter.default.post(name: QuestionAnswerViewController.questionSavedNotification, object: nil)
            self?.updateInterface()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    fileprivate func localize() {
        previousButton.setTitle("Previous".localized, for: .normal)
        nextButton.setTitle("Next".localized, for: .normal)
    }

    // MARK: - UI
    
    func updateInterface() {
        view.layoutIfNeeded()
        collectionView.reloadData()
    }
    
    func updateCurrentQuestionRelatedElements() {
        updateTitle()
        updateNavigationButtons()
    }
    
    func handleQuestionChanged() {
        updateCurrentQuestionRelatedElements()
        let currentPage = getDisplayedRow()
        if currentPage != lastViewedQuestionIndex
            && currentPage >= 0 && currentPage < model.questions.count {
            MVAnalytics.shared.log(event: .viewQuestion(code: model.questions[currentPage].questionCode))
            lastViewedQuestionIndex = currentPage

            let question = model.questions[currentPage]
            NotificationCenter.default.post(name: QuestionAnswerViewController.questionChangedNotification,
                                            object: self,
                                            userInfo: [QuestionAnswerViewController.questionUserInfoKey: question])
        }
    }
    
    func updateTitle() {
        let row = getDisplayedRow()
        guard row >= 0 && row < model.questions.count else { return }
        title = "Title.Question".localized + " \(row+1)/\(model.questions.count)"
    }

    func updateNavigationButtons() {
        let currentPage = getDisplayedRow()
        previousButton.isEnabled = currentPage > 0
        if AppRouter.shared.isPad {
            nextButton.isEnabled = currentPage < model.questions.count - 1
        } else {
            nextButton.setTitle((currentPage < model.questions.count - 1 ? "Next" : "Done").localized, for: .normal)
        }
    }
    
    func scrollToCurrentIndex() {
        scrollTrackingIsDisabled = true
        collectionView.scrollToItem(at: IndexPath(row: model.currentQuestionIndex, section: 0),
                                    at: .centeredHorizontally, animated: false)
        scrollTrackingIsDisabled = false
    }
    
    func getDisplayedRow() -> Int {
        let frameWidth = collectionView.frame.size.width
        let currentXOffset = collectionView.contentOffset.x
        return Int(floor(currentXOffset / frameWidth))
    }
    
    // MARK: - Actions
    
    func handleAnswer(ofQuestion question: QuestionAnswerCellModel, answerIndex: Int) {
        // then, if it requires free text and the answer was not selected already, ask for it
        if question.questionAnswers[answerIndex].isFreeText
            && !question.questionAnswers[answerIndex].isSelected {
            askForText(ofQuestion: question, answerIndex: answerIndex) { text in
                self.model.updateUserText(ofQuestion: question, answerIndex: answerIndex, userText: text)
                self.updateInterface()
                NotificationCenter.default.post(name: QuestionAnswerViewController.questionSavedNotification, object: nil)
            }
        } else {
            // first update the answer selection
            model.updateSelection(ofQuestion: question, answerIndex: answerIndex)
            updateInterface()
            NotificationCenter.default.post(name: QuestionAnswerViewController.questionSavedNotification, object: nil)
        }
        
    }
    
    func handleAddNote(toQuestion question: QuestionAnswerCellModel) {
        let noteModel = NoteViewModel(withQuestionId: question.questionId)
        let noteController = NoteViewController(withModel: noteModel)
        navigationController?.pushViewController(noteController, animated: true)
    }
    
    func askForText(ofQuestion question: QuestionAnswerCellModel, answerIndex: Int,
                    then completion: @escaping (String?) -> Void) {
        let textEntry = TextEntryViewController(nibName: "TextEntryViewController", bundle: nil)
        textEntry.initialText = question.questionAnswers[answerIndex].userText
        textEntry.onClose = completion
        let navigation = UINavigationController(rootViewController: textEntry)
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigation.modalPresentationStyle = .formSheet
        }
        present(navigation, animated: true, completion: nil)
    }
    
    @IBAction func handleGoPrevious(_ sender: Any) {
        let currentRow = getDisplayedRow()
        guard currentRow > 0 else { return }
        let indexPath = IndexPath(row: currentRow - 1, section: 0)
        let question = model.questions[indexPath.row]
        NotificationCenter.default.post(name: QuestionAnswerViewController.questionChangedNotification,
                                        object: self,
                                        userInfo: [QuestionAnswerViewController.questionUserInfoKey: question])
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func handleGoNext(_ sender: Any) {
        let currentRow = getDisplayedRow()
        guard currentRow < model.questions.count - 1 else {
            // we're done, so let's back out of this screen
            navigationController?.popViewController(animated: true)
            return
        }
        let indexPath = IndexPath(row: currentRow + 1, section: 0)
        let question = model.questions[indexPath.row]
        NotificationCenter.default.post(name: QuestionAnswerViewController.questionChangedNotification,
                                        object: self,
                                        userInfo: [QuestionAnswerViewController.questionUserInfoKey: question])
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func handleOrientationChange() {
        collectionView.alpha = 0
        DispatchQueue.main.async {
            self.updateInterface()
            self.scrollToCurrentIndex()
            self.collectionView.alpha = 1
        }
    }
}


extension QuestionAnswerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestionCollectionCell.reuseIdentifier,
                                                      for: indexPath) as! QuestionCollectionCell
        let question = model.questions[indexPath.row]
        cell.update(withModel: question)
        cell.onAnswerSelection = { self.handleAnswer(ofQuestion: $0, answerIndex: $1) }
        cell.onAddNote = { self.handleAddNote(toQuestion: $0) }
        return cell
    }
    
}

extension QuestionAnswerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.height -= collectionView.contentInset.top - collectionView.contentInset.bottom
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension QuestionAnswerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollTrackingIsDisabled {
            handleQuestionChanged()
        }
    }
}
