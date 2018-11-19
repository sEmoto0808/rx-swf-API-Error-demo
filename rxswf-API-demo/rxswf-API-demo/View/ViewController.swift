//
//  ViewController.swift
//  rxswf-API-demo
//
//  Created by S.Emoto on 2018/09/30.
//  Copyright © 2018年 S.Emoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class ViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var rxSearchBar: UISearchBar!
    @IBOutlet weak var rxTableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reloadButton: UIButton!
    
    // MARK: - Properties
    
    private var repositoryViewModel: RepositoryViewModel!
    // 検索バーの値を監視対象にする
    private var rx_searchBarText: Observable<String> {
        return rxSearchBar.rx.text
            .filter { $0 != nil}
            .map { $0! }
            .filter { $0.count > 0}
            .debounce(0.5, scheduler: MainScheduler.instance) // 0.5秒バッファ
            .distinctUntilChanged()
    }
    private let disposeBag = DisposeBag()
    // rxTableViewのデータソース
    private let dataSource = RepositoryDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //RxSwiftでの処理に関する部分をまとめたメソッドを実行
        setupRx()
        
        //RxSwiftを使用しない処理に関する部分をまとめたメソッド実行
        setupUI()
    }
    
    //メモリ解放時にキーボードのイベント監視対象から除外する
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController {
    
    //ViewModelを経由してGithubの情報を取得してテーブルビューに検索結果を表示する
    private func setupRx() {
        
        // ViewModel生成
        // 検索バーでの入力値の更新をトリガーにしてViewModel側に設置した処理を行う
        let mergedObservable = Observable<String>
            .combineLatest(rx_searchBarText, reloadButton.rx.tap.asObservable())
            { text,_ in
                return text
        }
        
        let input = RepositoryViewModel.Input.init(repositoryName: rx_searchBarText)
        repositoryViewModel = RepositoryViewModel(trigger: input)
        
        // TableViewへのデータ表示
        repositoryViewModel.output().rx_repositories
            .drive(rxTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // エラーハンドリング
        repositoryViewModel.output().failed
            .drive(onNext: { err in
                let alert = UIAlertController(title: err.message, message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                //ポップアップを閉じる
                if self.navigationController?.visibleViewController is UIAlertController != true {
                    self.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        // インジケータ
        repositoryViewModel.output().isLoading
            .drive(onNext: { isLoading in
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            })
            .disposed(by: disposeBag)
    }
    
    //キーボードのイベント監視の設定 ＆ テーブルビューに付与したGestureRecognizerに関する処理
    private func setupUI() {
        
        // テーブルビューにGestureRecognizerを付与する(キーボード表示・非表示用)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped(_:)))
        rxTableView.addGestureRecognizer(tap)
        
        // MARK: - キーボードのイベントを監視対象にする
        // キーボード表示
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        // キーボード非表示
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    //テーブルビューのセルタップ時に発動されるメソッド
    @objc
    private func tableTapped(_ recognizer: UITapGestureRecognizer) {
        
        //どのセルがタップされたかを探知する
        let location = recognizer.location(in: rxTableView)
        let path = rxTableView.indexPathForRow(at: location)
        
        //キーボードが表示されているか否かで処理を分ける
        if rxSearchBar.isFirstResponder {
            
            //キーボードを閉じる
            rxSearchBar.resignFirstResponder()
            
        } else if let path = path {
            
            //タップされたセルを中央位置に持ってくる
            rxTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
    }
    
    //キーボード表示時に発動されるメソッド
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        
        //キーボードのサイズを取得する（英語のキーボードが基準になるので日本語のキーボードだと少し見切れてしまう）
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さをキーボード分だけ縮める
        tableViewBottomConstraint.constant = keyboardFrame.size.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }
    
    //キーボード非表示表示時に発動されるメソッド
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さを元に戻す
        tableViewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }
}
