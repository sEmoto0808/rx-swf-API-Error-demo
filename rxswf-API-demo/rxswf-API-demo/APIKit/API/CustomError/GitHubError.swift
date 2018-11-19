//
//  GitHubError.swift
//  rxswf-API-demo
//
//  Created by Sho Emoto on 2018/11/19.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation

struct GitHubError: Error {
    //let status: Int
    let message: String
    
    init(object: GitHubRawError) {
        //status = object.statusCode
        message = object.message
    }
}
