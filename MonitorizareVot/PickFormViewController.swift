//  Created by Code4Romania

import Foundation
import UIKit

class PickFormViewController: RootViewController {
    
    // MARK: - iVars
    var sectionInfo: MVSectionInfo?
    var persistedSectionInfo: SectionInfo?
    var topLabelText: String?
    
    @IBOutlet weak var formsCollectionView: UICollectionView!
    
    @IBOutlet weak var syncButton: UIButton?
    
    private var localFormProvider = LocalFormProvider()
    private var localFormsPersistor = LocalFormsPersistor()

    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    private let dbSyncer = DBSyncer()

    // TODO: move this into an object or hash when we have more data to show
    var forms: [String] = []
    
    fileprivate let FormCellPadding: CGFloat = 5
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFormsIfNecessary()
        layout()
        setupOutlets()
        if let topLabelText = self.topLabelText {
            self.navigationItem.set(title: topLabelText, subtitle: "NavigationBar_SelectForm".localized)
        }
    }
    
    // MARK: - IBActions
    
    
    // MARK: - Handlers
    
    func handleAddNoteAction() {
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
        syncButton?.setTitle("Button_SyncData".localized, for: .normal)
        
        formsCollectionView.register(UINib(nibName: "FormPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: FormPickerCollectionViewCell.reuseIdentifier)
    }
    
    private func setupOutlets() {
        if let topLabelText = self.topLabelText {
            topLabel.text = topLabelText
        }
        topButton?.setTitle("Button_ChangeDepartemnt".localized, for: .normal)
    }
    
    fileprivate func pushFormViewController(type: String) {
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
    
    fileprivate func loadFormsIfNecessary() {
        if forms.count == 0 {
            forms = localFormsPersistor.getAllForms()
            formsCollectionView.reloadData()
        }
    }
}

extension PickFormViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // the number of forms + the add note cell
        return forms.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FormPickerCollectionViewCell.reuseIdentifier, for: indexPath) as? FormPickerCollectionViewCell else { fatalError("Couldn't find collection view cell") }
        
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            cell.isAddNote = true
        } else {
            cell.isAddNote = false
            let form = forms[indexPath.row]
            cell.idLabel.text = form.uppercased()
            cell.descriptionLabel.text = "Label_Form".localized
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            handleAddNoteAction()
        } else {
            self.pushFormViewController(type: forms[indexPath.row])
        }
    }
    
    
    
}


extension PickFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.size.width / 2 - FormCellPadding
        return CGSize(width: side, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return FormCellPadding * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return FormCellPadding
    }
}
