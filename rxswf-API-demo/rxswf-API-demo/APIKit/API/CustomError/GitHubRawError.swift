//
//  GitHubRawError.swift
//  rxswf-API-demo
//
//  Created by Sho Emoto on 2018/11/19.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation

struct GitHubRawError: Decodable {
    //let statusCode: Int
    let message: String
    
    private enum CodingKeys: String, CodingKey {
        //case statusCode = "status_code"
        case message
    }
}
