//
//  APIClient.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/09/30.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import APIKit
import UIKit

final class APIClient {
    
    func send<T: Request>(withRequest request: T) -> Observable<T.Response> {
        
        return Observable
            .create { observer in
                let task = Session.send(request) { result in
                    switch result {
                    case .success(let res):
                        observer.on(.next(res))
                        observer.on(.completed)
                    case .failure(.responseError(let err as GitHubError)):
                        observer.onError(err)
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
                return Disposables.create {
                    task?.cancel()
                }
        }
    }
}
