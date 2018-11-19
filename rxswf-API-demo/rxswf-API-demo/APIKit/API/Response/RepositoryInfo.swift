//
//  RepositoryInfo.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/09/30.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation

struct RepositoryInfo: Decodable {
    
    let id: Int
    let url: String
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case url = "html_url"
        case name
    }
}
