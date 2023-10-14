//
//  RequestHandlerProtocol.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

protocol RequestHandlerProtocol {
  func fetchData(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: RequestHandlerProtocol {
  
  func fetchData(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    dataTaskPublisher(for: request).eraseToAnyPublisher()
  }
  
}
