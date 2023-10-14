//
//  BaseRequest.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Foundation

protocol BaseRequest {
  
  var method: String { get }
  
  var baseUrl: URL { get }
  
  var endpoint: String { get }
  
  var queryParameters: [String: String] { get }
  
  var headers: [String: String] { get }
}

extension BaseRequest {
  
  var method: String {
    "GET"
  }
  
  var baseUrl: URL {
    guard let url = URL(string: "https://itunes.apple.com") else {
      fatalError("Bad base url")
    }
    return url
  }
  
  var queryParameters: [String: String] {
    [:]
  }
  
  var headers: [String: String] {
    [:]
  }
  
  var fullUrl: URL {
    let url = baseUrl.appendingPathComponent(endpoint)
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
    let queryItems = queryParameters.map { key, value in
      URLQueryItem(name: key, value: value)
    }
    urlComponents?.queryItems = queryItems
    return urlComponents?.url ?? url
  }
  
  var urlRequest: URLRequest {
    var request = URLRequest(url: fullUrl)
    request.httpMethod = method
    request.allHTTPHeaderFields = headers
    return request
  }
}
