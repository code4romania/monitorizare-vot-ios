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
    let HorizontalSectionInset: CGFloat = 16
    
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
    
    // MARK: - Config
    
    fileprivate func configureCollectionView() {
        collectionView.register(UINib(nibName: "QuestionCollectionCell", bundle: nil),
                                forCellWithReuseIdentifier: QuestionCollectionCell.reuseIdentifier)
    }

    // MARK: - UI
    
    // MARK: - Actions
    
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
        // TODO: update
        return cell
    }
    
}

extension QuestionAnswerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.width -= 2 * HorizontalSectionInset
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: HorizontalSectionInset, bottom: 0, right: HorizontalSectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return HorizontalSpace
    }
}
