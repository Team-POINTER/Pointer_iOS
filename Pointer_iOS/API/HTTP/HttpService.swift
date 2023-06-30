//
//  HttpService.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/06/24.
//

import Foundation
import Alamofire

protocol HttpService {
    var sessionManager: Session { get set }
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest
}
