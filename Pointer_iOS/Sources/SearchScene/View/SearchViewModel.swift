//
//  SearchViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/09.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
//MARK: - Properties
    let disposeBag = DisposeBag()
    let searchRoomResult = PublishRelay<PointerRoomListModel>()
//    let searchaccountResult = PublishRelay<>()
 
//MARK: - In/Out
    struct Input {
        let searchBarTextEditEvent: Observable<String>
    }
    
    struct Output {
        
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.searchBarTextEditEvent
            .subscribe { [weak self] text in
                guard let text = text.element,
                      let self = self else { return }
                self.requestRoomList("\(text)")
            }
            .disposed(by: disposeBag)
        
        searchRoomResult.subscribe { data in
            print("DEBUG: 들어간 데이터 \(data)")
        }
        .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Functions
 
    
    
//MARK: - Network
    func requestRoomList(_ word: String) {
        HomeNetworkManager.shared.requestRoomList(word) { [weak self] model, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            if let data = model?.data {
                print(data)
                self.searchRoomResult.accept(data)
            }
        }
    }
    
    func requestAccountList(_ word: String) {
        
    }
    
}

