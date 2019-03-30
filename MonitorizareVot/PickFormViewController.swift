//  Created by Code4Romania

import Foundation
import UIKit

class PickFormViewController: RootViewController {
    
    // MARK: - iVars
    var sectionInfo: MVSectionInfo?
    var persistedSectionInfo: SectionInfo?
    var topLabelText: String?
    @IBOutlet weak var firstTitle: UILabel?
    @IBOutlet weak var secondTitle: UILabel?
    @IBOutlet weak var thirdTitle: UILabel?
    @IBOutlet weak var firstLabel: UILabel?
    @IBOutlet weak var secondLabel: UILabel?
    @IBOutlet weak var thirdLabel: UILabel?
    @IBOutlet weak var fourthLabel: UILabel?
    @IBOutlet weak var centerButton: UIButton?
    private var localFormProvider = LocalFormProvider()
    @IBOutlet private var buttonsBackgroundViews: [UIView]!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    private let dbSyncer = DBSyncer()
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupOutlets()
        if let topLabelText = self.topLabelText {
            self.navigationItem.set(title: topLabelText, subtitle: "NavigationBar_SelectForm".localized)
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
    
    @IBAction func syncData(_ button: UIButton) {
        dbSyncer.syncUnsyncedData()
    }
    
    @IBAction func topRightButtonPressed(_ sender: UIButton) {
        if let childs = self.navigationController?.children {
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
        firstLabel?.text = "Label_FormA".localized
        firstTitle?.text = "Label_FormAAbr".localized
        secondLabel?.text = "Label_FormB".localized
        secondTitle?.text = "Label_FormBAbr".localized
        thirdLabel?.text = "Label_FormC".localized
        thirdTitle?.text = "Label_FormCAbr".localized
        fourthLabel?.text = "Label_AddNote".localized
        centerButton?.setTitle("Button_SyncData".localized, for: .normal)
    }
    
    private func setupOutlets() {
        if let topLabelText = self.topLabelText {
            topLabel.text = topLabelText
        }
        topButton?.setTitle("Button_ChangeDepartemnt".localized, for: .normal)
    }
    
    private func pushFormViewController(type: String) {
        let formViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FormViewController") as! FormViewController
        if let form = localFormProvider.getForm(named: type) {
            var questions = [MVQuestion]()
            for aSection in form.sections {
                if let persistedQuestions = persistedSectionInfo?.questions as? Set<Question> {
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
            formViewController.form = type
            formViewController.sectionInfo = sectionInfo
            formViewController.persistedSectionInfo = persistedSectionInfo
            self.navigationController?.pushViewController(formViewController, animated: true)
        }
    }
}
