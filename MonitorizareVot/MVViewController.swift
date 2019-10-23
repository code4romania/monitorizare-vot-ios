//
//  MVViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 23/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SafariServices


/// Use this class as the base class for view controllers that need to have things like the contact info on the nav bar,
/// a default title
class MVViewController: UIViewController {

    // MARK: - VC

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        configureView()
    }
    
    fileprivate func configureBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func configureView() {
        view.backgroundColor = .appBackground
    }
    
    // MARK: - Public

    /// Call this method to add contact details to the navigation bar - the right item
    func addContactDetailsToNavBar() {
        let guideButton = UIButton(type: .custom)
        guideButton.setImage(UIImage(named:"button-guide"), for: .normal)
        guideButton.addTarget(self, action: #selector(pushGuideViewController), for: .touchUpInside)

        let callButton = UIButton(type: .custom)
        callButton.setImage(UIImage(named:"button-call"), for: .normal)
        callButton.addTarget(self, action: #selector(performCall), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [callButton, guideButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    // MARK: - Actions

    @objc func pushGuideViewController() {
        // TODO: extract this into a config
        if let url = URL(string: "http://monitorizare-vot-ghid.azurewebsites.net/") {
            let safariViewController = SFSafariViewController(url: url)
            self.navigationController?.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @objc func performCall() {
        // TODO: extract this into a config
        let phoneCallPath = "telprompt://0800080200"
        if let phoneCallURL = NSURL(string: phoneCallPath) {
            UIApplication.shared.openURL(phoneCallURL as URL)
        }
    }
}
