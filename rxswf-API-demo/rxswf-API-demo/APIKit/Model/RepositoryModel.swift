//
//  RepositoryModel.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/10/01.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class RepositoryModel {
    
    struct Status {
        var isLoading = PublishSubject<Bool>()
        var success = BehaviorSubject<[RepositoryInfo]>(value: [])
        var failed = PublishSubject<GitHubError>()
    }
    
    private var _status = RepositoryModel.Status.init()
    private let disposeBag = DisposeBag()
    
    func status() -> RepositoryModel.Status {
        return _status
    }
    
    func rx_get(from UI: Observable<String>) {
        
        UI
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest({ [weak self] text -> Observable<GitHubAPI.SearchRepositories.Response> in
                guard let weakSelf = self else { return Observable.just([]) }
                weakSelf._status.isLoading.onNext(true)
                // APIからデータを取得する
                return APIClient().send(withRequest: GitHubAPI.SearchRepositories(userName: text))
                    .catchError({ [weak self] error in
                        // Failure
                        guard let weakSelf = self, let error = error as? GitHubError else {
                            self?._status.failed.onNext(GitHubError(object: GitHubRawError.init(message: "default failed")))
                            return Observable.just([])
                        }
                        weakSelf._status.failed.onNext(error)
                        weakSelf._status.isLoading.onNext(false)
                        return Observable.just([])
                    })
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                // Success
                print("success")
                guard let weakSelf = self else { return }
                weakSelf._status.success.onNext(response)
                weakSelf._status.isLoading.onNext(false)
            })
            .disposed(by: disposeBag)
    }
}
