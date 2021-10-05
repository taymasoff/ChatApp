//
//  ChatViewController+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit

extension ChatViewController {
    
    func makeGearBarButton() -> UIBarButtonItem {
        let barButton = UIBarButtonItem(
            image: AppAssets.image(.gear),
            style: .plain,
            target: self,
            action: #selector(gearBarButtonPressed))
        barButton.tintColor = AppAssets.colors(.barItemGray)
        return barButton
    }
    
    func makeSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search"
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(0)
            make.left.right.equalToSuperview().inset(10)
        }
        return searchBar
    }
    
    func makeChatTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        return tableView
    }
}
