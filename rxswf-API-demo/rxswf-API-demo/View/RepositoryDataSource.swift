//
//  RepositoryDataSource.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/10/02.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class RepositoryDataSource: NSObject {
    // バインドされる型と一致する必要がある
    public typealias Element = [RepositoryInfo]
    
    var repositories = [RepositoryInfo]()
}

// MARK: - RxTableViewDataSourceType
extension RepositoryDataSource: RxTableViewDataSourceType {
    
    //RxTableViewDataSourceTypeのメソッドを拡張して設定する
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .next(let value):
            self.repositories = value
            tableView.reloadData()
        case .error(_):
            ()
        case .completed:
            ()
        }
    }
}

// MARK: - UITableViewDataSource
extension RepositoryDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell",
                                                 for: indexPath)
        cell.textLabel?.text = repositories[indexPath.row].name
        cell.detailTextLabel?.text = repositories[indexPath.row].url
        
        return cell
    }
}
