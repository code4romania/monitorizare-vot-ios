//
//  OnboardingViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    let model = OnboardingViewModel()
    
    lazy var pages: [UIViewController] = {
        model.children.map { OnboardingChildViewController(withModel: $0) }
    }()
    
    @IBOutlet weak var pageControllerContainer: UIView!
    @IBOutlet weak var pager: UIPageControl!
    @IBOutlet weak var proceedButton: UIButton!
    
    var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        
        addChild(pageController)
        pageController.view.frame = pageControllerContainer.bounds
        pageControllerContainer.addSubview(pageController.view)
        
        pageController.delegate = self
        pageController.dataSource = self
        
        pageController.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MVAnalytics.shared.log(event: .screen(name: String(describing: type(of: self))))
    }
    
    func localize() {
        proceedButton.setTitle("Onboarding.Go".localized, for: .normal)
    }
    
    func updateInterface() {
        pager.currentPage = model.currentPage
        proceedButton.isHidden = model.currentPage != pages.count - 1
        MVAnalytics.shared.log(event: .onboardingPage(page: model.currentPage))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBAction func handleProceedAction(_ sender: Any) {
        PreferencesManager.shared.wasOnboardingShown = true
        AppRouter.shared.goToLogin()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
            index > 0 {
            return pages[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
            index < pages.count - 1 {
            return pages[index + 1]
        }
        return nil
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let first = pageViewController.viewControllers?.first,
            let index = pages.firstIndex(of: first),
            model.currentPage != index {
            model.currentPage = index
        }
        updateInterface()
    }
}
