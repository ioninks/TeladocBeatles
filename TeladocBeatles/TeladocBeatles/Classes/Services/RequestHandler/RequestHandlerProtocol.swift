//
//  RequestHandlerProtocol.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

protocol RequestHandlerProtocol {
  func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: RequestHandlerProtocol {}
