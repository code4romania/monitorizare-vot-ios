//  Created by Code4Romania

import Foundation
import UIKit


class FormViewController: RootViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, QuestionViewControllerDelegate {
    
    var questions: [MVQuestion]?
    var sectionInfo: MVSectionInfo?
    var persistedSectionInfo: SectionInfo?
    var form: String?
    private let cellSpacer = 16
    private let numberOfCellsOnEachRow = 2
    private var configurator = QuestionCollectionViewCellConfigurator()
    @IBOutlet private weak var collectionView: UICollectionView!
    private var pushAnimated = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "QuestionCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "QuestionCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pushAnimated = true
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let questions = self.questions {
            return questions.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCollectionViewCell", for: indexPath) as! QuestionCollectionViewCell
        if let questions = self.questions, let form = self.form {
            let data = questions[indexPath.row]
            configurator.configure(form: form, cell: cell, with: data, row: indexPath.row)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGFloat(((Int(UIScreen.main.bounds.width) - 3 * cellSpacer) / numberOfCellsOnEachRow) - numberOfCellsOnEachRow)
        return CGSize(width: size, height: size)
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let questions = self.questions, let questionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController {
            questionViewController.question = questions[indexPath.row]
            questionViewController.sectionInfo = sectionInfo
            questionViewController.persistedSectionInfo = persistedSectionInfo
            questionViewController.delegate = self
            self.navigationController?.pushViewController(questionViewController, animated: pushAnimated)
        }
    }
    
    // MARK: - QuestionViewControllerDelegate
    func showNextQuestion(currentQuestion: MVQuestion) {
        if let index = questions?.firstIndex(where: { (aQuestion) -> Bool in
            return aQuestion.id == currentQuestion.id
        }) {
            if let questions = self.questions, index < questions.count - 1 {
                pushAnimated = false
                let _ = self.navigationController?.popViewController(animated: false)
                let indexPath = IndexPath(row: index + 1, section: 0)
                self.collectionView(self.collectionView, didSelectItemAt: indexPath)
            } else {
                let _ = self.navigationController?.popViewController(animated: true)
            }
            
            var currentQuestionUpdated = currentQuestion
            for aAnswer in currentQuestion.answers {
                if aAnswer.selected == true {
                    currentQuestionUpdated.answered = true
                    questions?[index] = currentQuestionUpdated
                    collectionView.reloadData()
                    break
                }
            }
            
        }
    }
}
