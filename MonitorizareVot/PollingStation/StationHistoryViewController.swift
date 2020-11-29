//
//  StationHistoryViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import SnapKit

class StationHistoryViewController: MVViewController {
    
    let model = StationHistoryViewModel()

    @IBOutlet weak var syncContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var tableHeader: UIView {
        let header = UIView(frame: .zero)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: .zero)
        label.textColor = .navigationBarTint
        label.alpha = 0.5
        label.font = .systemFont(ofSize: 12)
        label.text = "Text.StationHistory.Info".localized
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        header.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(header).inset(24)
        }
        return header
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureChildren()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
        updateLabelsTexts()
    }

    fileprivate func configureSubviews() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "StationInfoTableCell", bundle: nil),
                           forCellReuseIdentifier: StationInfoTableCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
    }
    
    private func configureChildren() {
        let syncStatus = SyncStatusViewController()
        addChild(syncStatus)
        syncStatus.didMove(toParent: self)
        syncContainer.addSubview(syncStatus.view)
        syncStatus.view.snp.makeConstraints { make in
            make.edges.equalTo(self.syncContainer)
        }
    }
    
    // MARK: - UI
    
    fileprivate func updateInterface() {
        tableView.reloadData()
    }
    
    fileprivate func updateLabelsTexts() {
        title = "Title.StationHistory".localized
        let tableHeader = self.tableHeader
        tableHeader.frame = tableView.bounds
        
        tableView.tableHeaderView = tableHeader
        tableView.tableHeaderView?.snp.makeConstraints({ make in
            make.width.equalTo(tableView)
        })
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView
    }
    
    // MARK: - Actions
    
    fileprivate func continueToStation(_ model: StationHistoryViewModel.StationRowModel) {
        DebugLog("Station picked from history: \(model)")
        MVAnalytics.shared.log(event: .pickedStationFromHistory)
        AppRouter.shared.goToChooseStation(stationId: model.stationId, countyCode: model.stationCountyCode)
    }
    
}

// MARK: - Table View Data Source + Delegate

extension StationHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.visitedStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StationInfoTableCell.reuseIdentifier,
                                                       for: indexPath) as? StationInfoTableCell else { fatalError("Wrong cell type") }
        let cellModel = model.visitedStations[indexPath.row]
        cell.update(with: cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: .zero)
        header.backgroundColor = .clear
        return header
    }
}

extension StationHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = model.visitedStations[indexPath.row]
        continueToStation(station)
    }
}
