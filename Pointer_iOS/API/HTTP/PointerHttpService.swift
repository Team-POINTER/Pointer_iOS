//
//  LoginHttpService.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/06/24.
//

import Foundation
import Alamofire

class PointerHttpService: HttpService {
    var sessionManager: Alamofire.Session = Session.default
    
    func request(_ urlRequest: Alamofire.URLRequestConvertible) -> Alamofire.DataRequest {
        return sessionManager.request(urlRequest).validate(statusCode: 200..<500)
    }
    
    
}
