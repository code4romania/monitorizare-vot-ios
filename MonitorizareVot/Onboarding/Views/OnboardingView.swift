//
//  VotingStationOnboardingView.swift
//  MonitorizareVot
//
//  Created by Geart Otten on 14/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class OnboardingView: View {
    
    // MARK: Private variables
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.89, alpha: 1)
        view.autoresizingMask = .flexibleHeight
        return view
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(red: 0.21, green: 0.13, blue: 0.27, alpha: 1.0)
        return view
    }()
    
    private lazy var imageInBackgroundView: UIImageView = {
        return UIImageView()
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
        return label
    }()
    
    private lazy var contextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
        return label
    }()
    
    internal var viewModel: OnboardingViewModel? {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            titleLabel.text = viewModel?.title
            guard let contextString = viewModel?.context else { return }
            contextLabel.attributedText = NSMutableAttributedString(string: contextString, attributes: [.paragraphStyle: paragraphStyle])
            guard let imageString = viewModel?.imageString else { return }
            imageInBackgroundView.image = UIImage(named: "Onboarding-\(imageString)")
        }
    }
    
    // MARK: Lifecycle
    
    override func addSubviews() {
        super.addSubviews()
        
        self.addSubview(contentView)
        self.addSubview(backgroundView)
        
        backgroundView.addSubview(imageInBackgroundView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(contextLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(self).dividedBy(2.3)
        }
        
        imageInBackgroundView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(195)
            make.height.lessThanOrEqualTo(200)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.lessThanOrEqualTo(25)
        }
        
        contextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
        }
    }
}
