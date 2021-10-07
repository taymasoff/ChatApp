//
//  ConversationsViewController+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit

extension ConversationsViewController {
    
    func makeGearBarButton() -> UIBarButtonItem {
        let barButton = UIBarButtonItem(
            image: AppAssets.image(.gear),
            style: .plain,
            target: self,
            action: #selector(gearBarButtonPressed))
        barButton.tintColor = AppAssets.colors(.barItemGray)
        return barButton
    }
    
    func makeConversationsTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        return tableView
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self.viewModel
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
}
