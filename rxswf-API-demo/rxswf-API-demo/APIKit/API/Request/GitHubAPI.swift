//
//  GitHubAPI.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/09/30.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation
import APIKit

final class GitHubAPI {
    
    struct SearchRepositories: GitHubBaseRequest {
        typealias Response = [RepositoryInfo]
        
        let method: HTTPMethod = .get
        var path: String {
            return "/users/\(self.text)/repos"
            
        }
        
        let text: String
        
        init(userName: String) {
            self.text = userName
        }
    }
}
