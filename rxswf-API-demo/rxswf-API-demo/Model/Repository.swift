//
//  UserInfo.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/09/30.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation
import ObjectMapper

struct Repository: Mappable {
    
    var id = 0
    var html_url = ""
    var name = ""
    
    //イニシャライザ
    init?(map: Map) {}
    
    //ObjectMapperを利用したデータのマッピング
    mutating func mapping(map: Map) {
        id <- map["id"]
        html_url <- map["html_url"]
        name <- map["name"]
    }
}
