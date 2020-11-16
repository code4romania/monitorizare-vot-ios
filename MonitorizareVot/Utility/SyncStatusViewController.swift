//
//  SyncStatusViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 16/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class SyncStatusViewController: UIViewController {
    
    let model = SyncStatusViewModel()

    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var syncButton: ActionButton!
    @IBOutlet private var syncButtonContainer: UIView!
    @IBOutlet private var syncSpinner: UIActivityIndicatorView!
    
    private(set) var isSyncing = false {
        didSet {
            isSyncing ? syncSpinner.startAnimating()
                : syncSpinner.stopAnimating()
            syncButton.alpha = isSyncing ? 0 : 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    private func configureInterface() {
        view.backgroundColor = .bottomNoticeBackground
    }
    
    private func update() {
        switch model.state {
        case .synced:
            iconView.image = .syncedNoticeIcon
            textLabel.text = "Info.DataSyncronised".localized
            syncButtonContainer.isHidden = true
        case .unsynced:
            iconView.image = .savedNoticeIcon
            textLabel.text = "Info.DataNotSyncronised".localized
            syncButtonContainer.isHidden = false
        }
        syncButton.setTitle("Button_SyncData".localized, for: .normal)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error".localized,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func handleSyncButtonTap(_ sender: Any) {
        MVAnalytics.shared.log(event: .tapManualSync)
        isSyncing = true
        model.sync { [weak self] anyError in
            guard let self = self else { return }
            self.isSyncing = false
            self.update()
            if let error = anyError {
                self.showError(message: error.localizedDescription)
            }
        }
    }
}
