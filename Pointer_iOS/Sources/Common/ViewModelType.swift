//
//  File.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
