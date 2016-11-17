//
//  FormViewController.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit


class FormViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var questions: [Question]?
    var form: String?
    var topTitle: String?
    private let cellSpacer = 16
    private let numberOfCellsOnEachRow = 2
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var topLabel: UILabel!
    private var configurator = QuestionCollectionViewCellConfigurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "QuestionCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "QuestionCollectionViewCell")
        topLabel.text = topTitle
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
        
    }
}
