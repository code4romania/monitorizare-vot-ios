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

    /// Connect the view that will contain the section info controller
    @IBOutlet weak var headerContainer: UIView!
    weak var headerViewController: SectionHUDViewController?
    
    let TableSectionHeaderHeight: CGFloat = 52
    let TableSectionFooterHeight: CGFloat = 22
    
    /// Set this to false in your `viewDidLoad` method before calling super to skip adding the station info header
    var shouldDisplayHeaderContainer = true

    // MARK: - VC

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        configureView()
        configureHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MVAnalytics.shared.log(event: .screen(name: String(describing: type(of: self))))
    }
    
    fileprivate func configureBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func configureView() {
        view.backgroundColor = .appBackground
    }
    
    fileprivate func configureHeader() {
        guard shouldDisplayHeaderContainer else { return }
        guard let headerContainer = headerContainer else { return }
        let controller = SectionHUDViewController()
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        controller.willMove(toParent: self)
        addChild(controller)
        controller.view.frame = headerContainer.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerContainer.addSubview(controller.view)
        controller.didMove(toParent: self)
        headerViewController = controller
        controller.onChangeAction = { [weak self] in
            self?.handleChangeSectionButtonAction()
        }
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
        MVAnalytics.shared.log(event: .tapGuide)
        if let urlString = Bundle.main.infoDictionary?["GUIDE_URL"] as? String,
            let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            self.navigationController?.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "No guide available")
            present(error, animated: true, completion: nil)
        }
    }
    
    @objc func performCall() {
        MVAnalytics.shared.log(event: .tapCall)
        if let phone = Bundle.main.infoDictionary?["SUPPORT_PHONE"] as? String {
            let phoneCallPath = "telprompt://\(phone)"
            if let phoneCallURL = NSURL(string: phoneCallPath) {
                UIApplication.shared.openURL(phoneCallURL as URL)
            }
        } else {
            let error = UIAlertController.error(withMessage: "No phone support available")
            present(error, animated: true, completion: nil)
        }
    }

    fileprivate func handleChangeSectionButtonAction() {
        MVAnalytics.shared.log(event: .tapChangeStation(fromScreen: String(describing: type(of: self))))
        AppRouter.shared.goToChooseStation()
    }
    
}
