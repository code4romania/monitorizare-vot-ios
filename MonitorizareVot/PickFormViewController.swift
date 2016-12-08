//  Created by Code4Romania

import Foundation
import UIKit

class PickFormViewController: RootViewController {
    
    // MARK: - iVars
    var sectionInfo: MVSectionInfo?
    var persistedSectionInfo: SectionInfo?
    var topLabelText: String?
    private var localFormProvider = LocalFormProvider()
    @IBOutlet private var buttonsBackgroundViews: [UIView]!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupOutlets()
        if let topLabelText = self.topLabelText {
            self.navigationItem.set(title: topLabelText, subtitle: "Alege formular")
        }
    }
    
    // MARK: - IBActions
    @IBAction func firstButtonPressed(_ sender: UIButton) {
        pushFormViewController(type: "A")
    }
    
    @IBAction func secondButtonPressed(_ sender: UIButton) {
        pushFormViewController(type: "B")
    }
    
    @IBAction func thirdButtonPressed(_ sender: UIButton) {
        pushFormViewController(type: "C")
    }
    
    @IBAction func fourthButtonPressed(_ sender: UIButton) {
        let addNoteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNoteViewController") as! AddNoteViewController
        addNoteViewController.sectionInfo = sectionInfo
        addNoteViewController.noteContainer = persistedSectionInfo
        self.navigationController?.pushViewController(addNoteViewController, animated: true)
    }
    
    @IBAction func topRightButtonPressed(_ sender: UIButton) {
        if let childs = self.navigationController?.childViewControllers {
            for aChild in childs {
                if aChild is SectieViewController {
                    let _ = self.navigationController?.popToViewController(aChild, animated: true)
                }
            }
        }
    }
    
    // MARK: - Utils
    private func layout() {
        for aView in buttonsBackgroundViews {
            aView.layer.dropDefaultShadow()
        }
        topButton.layer.defaultCornerRadius(borderColor: MVColors.gray.cgColor)
    }
    
    private func setupOutlets() {
        if let topLabelText = self.topLabelText {
            topLabel.text = topLabelText
        }
    }
    
    private func pushFormViewController(type: String) {
        let formViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FormViewController") as! FormViewController
        if let form = localFormProvider.getForm(named: type) {
            var questions = [MVQuestion]()
            for aSection in form.sections {
                if let persistedQuestions = persistedSectionInfo?.questions as? Set<Question> {
                    let persistedQuestionsArray = Array(persistedQuestions)
                    for questionToAdd in aSection.questions {
                        let indexOfPersistedQuestionInSection = persistedQuestionsArray.index { (persistedQuestion: Question) -> Bool in
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
            formViewController.form = type
            formViewController.sectionInfo = sectionInfo
            formViewController.persistedSectionInfo = persistedSectionInfo
            self.navigationController?.pushViewController(formViewController, animated: true)
        }
    }
}
