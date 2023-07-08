//
//  HttpRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/06/24.
//

import Alamofire
import Foundation

protocol HttpRouter {
    var url: String { get }
    var baseUrlString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    func body() throws -> Data?
    
    func request(usingHttpService service: HttpService) throws -> DataRequest
}

// Default
extension HttpRouter {
    var headers: HTTPHeaders? { return nil }
    var parameters: Parameters? { return nil }
    func body() throws -> Data? { return nil }
    
    func asUrlRequest() throws -> URLRequest {
        var url = try baseUrlString.asURL()
        url.appendPathComponent(path)
        
        var request = try URLRequest(url: url, method: method, headers: headers)
        request.httpBody = try body()
        
        return request
    }
    
    func request(usingHttpService service: HttpService) throws -> DataRequest {
        return try service.request(asUrlRequest())
    }
    
}
