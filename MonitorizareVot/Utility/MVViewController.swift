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
        let settingsButton = UIButton(type: .custom)
        let icon = UIImage(named:"icon-menu-settings")?
            .withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(icon, for: .normal)
        settingsButton.tintColor = .defaultText
        settingsButton.addTarget(self, action: #selector(handleShowSettingsAction), for: .touchUpInside)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    // MARK: - Actions

    @objc private func handleShowSettingsAction() {
        let menu = MenuViewController()
        present(menu, animated: true, completion: nil)
    }
    
    fileprivate func handleChangeSectionButtonAction() {
        MVAnalytics.shared.log(event: .tapChangeStation(fromScreen: String(describing: type(of: self))))
        AppRouter.shared.goToChooseStation()
    }

}
