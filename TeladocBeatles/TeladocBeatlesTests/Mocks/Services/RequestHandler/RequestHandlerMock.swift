//
//  RequestHandlerMock.swift
//  TeladocBeatlesTests
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

@testable import TeladocBeatles

final class RequestHandlerMock: RequestHandlerProtocol {
  
  private(set) var invokedDataTaskPublisherCount = 0
  let stubbedDataTaskPublisherResult = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
  
  func fetchData(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    self.stubbedDataTaskPublisherResult
      .handleEvents(receiveSubscription: { _ in
        self.invokedDataTaskPublisherCount += 1
      })
      .eraseToAnyPublisher()
  }
  
}
