//
//  QuestionAnswerViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class QuestionAnswerViewController: MVViewController {
    
    var model: QuestionAnswerViewModel
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    // MARK: - Config
    
    fileprivate func configureCollectionView() {
        collectionView.register(UINib(nibName: "QuestionCollectionCell", bundle: nil),
                                forCellWithReuseIdentifier: QuestionCollectionCell.reuseIdentifier)
    }

    // MARK: - UI
    
    func updateInterface() {
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: model.currentQuestionIndex, section: 0),
                                    at: .centeredHorizontally, animated: false)
    }
    
    // MARK: - Actions
    
    func handleTextAnswer(ofQuestion question: inout QuestionAnswerCellModel, answerIndex: Int) {
        // first update the answer selection
        model.updateSelection(ofQuestion: question, answerIndex: answerIndex)
        
        // then, if it requires free text, ask for it
        if question.questionAnswers[answerIndex].isFreeText {
            askForText { text in
                self.model.updateUserText(ofQuestion: question, answerIndex: answerIndex, userText: text)
            }
        }
        
        // reset the state
        currentModel!.setIsSaved(false)
        currentModel!.setIsSynced(false)
        
        updateInterface()
    }
    
    func handleAddNote(toQuestion question: inout QuestionAnswerCellModel) {
        
    }
    
    func askForText(then completion: (String?) -> Void) {
        
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
        cell.onTextAnswerSelection = { self.handleTextAnswer(ofQuestion: &$0, answerIndex: $1) }
        cell.onAddNote = { self.handleAddNote(toQuestion: &$0) }
        return cell
    }
    
}

extension QuestionAnswerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: HorizontalSectionInset, bottom: 0, right: HorizontalSectionInset)
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
