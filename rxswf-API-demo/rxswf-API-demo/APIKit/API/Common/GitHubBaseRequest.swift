//
//  GitHubBaseRequest.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/09/30.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation
import APIKit

protocol GitHubBaseRequest: Request {}

extension GitHubBaseRequest {
    
    // APIのベースURL
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}

// RequestのResponseがDecodableに準拠している場合
extension GitHubBaseRequest where Response: Decodable {
    
    var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        
        guard (200..<300).contains(urlResponse.statusCode) else {
            // ひとまず、Decodableな構造体に値を埋める
            let decoder = JSONDecoder()
            let obj_decoded = try decoder.decode(GitHubRawError.self, from: object as! Data)
            // それもとにMyErrorを生成して投げる
            throw GitHubError(object: obj_decoded)
        }
        
        return object
    }
}
