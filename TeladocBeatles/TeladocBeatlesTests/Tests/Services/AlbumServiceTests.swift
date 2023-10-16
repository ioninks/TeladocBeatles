//
//  AlbumServiceTests.swift
//  TeladocBeatlesTests
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import XCTest

@testable import TeladocBeatles

private enum Constants {
  static let artistName = "thebeatles"
  static let album = AlbumEntity(collectionId: 1, collectionName: "1")
  static let url = URL(string: "apple.com")!
}

final class AlbumServiceTests: XCTestCase {
  
  // system under test
  private var service: AlbumService!
  
  // mocks
  private var requestHandlerMock: RequestHandlerMock!
  
  // cancellables
  private var fetchAlbumsCancellable: AnyCancellable!
  
  // result
  private var fetchAlbumsResult: [AlbumEntity]!
  
  // error
  private var fetchAlbumsError: AlbumServiceError!
  
  override func setUp() {
    super.setUp()
    
    requestHandlerMock = .init()
    service = .init(requestHandler: requestHandlerMock)
    
    fetchAlbumsCancellable = service.fetchAlbums(artistName: Constants.artistName)
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          self.fetchAlbumsError = error
        }
      }, receiveValue: { result in
        self.fetchAlbumsResult = result
      })
  }
  
  override func tearDown() {
    service = nil
    requestHandlerMock = nil
    fetchAlbumsCancellable = nil
    fetchAlbumsResult = nil
    fetchAlbumsError = nil
    
    super.tearDown()
  }
  
  // MARK: Tests
  
  func test_whenReceivedProperResponse_shouldReturnResult() {
    // given
    let data = makeSerializedResponseData(forAlbums: [Constants.album])
    let response = makeHTTPURLResponse(statusCode: 200)
    
    // when received correct data with 200 response code
    requestHandlerMock.stubbedDataTaskPublisherResult.send((data: data, response: response))
    
    // then
    XCTAssertEqual(
      fetchAlbumsResult, [Constants.album],
      "should return fetched album entities"
    )
  }
  
  func test_whenReceivedURLError_shouldThrowNetworkFailure() {
    // when request handler emits network error
    requestHandlerMock.stubbedDataTaskPublisherResult.send(completion: .failure(.init(.timedOut)))
    
    // then
    XCTAssertEqual(
      fetchAlbumsError, .networkFailure,
      "should throw networkFailure error"
    )
  }
  
  func test_whenStatusCodeIsNot200_shouldThrowBadResponse() {
    // given
    let data = makeSerializedResponseData(forAlbums: [Constants.album])
    let response = makeHTTPURLResponse(statusCode: 404)
    
    // when received 404 response code
    requestHandlerMock.stubbedDataTaskPublisherResult.send((data: data, response: response))
    
    // then
    XCTAssertEqual(
      fetchAlbumsError, .badResponse,
      "should throw badResponse error"
    )
  }
  
  func test_whenDataParsingFails_shouldThrowParsingError() {
    // given
    let data = Data()
    let response = makeHTTPURLResponse(statusCode: 200)
    
    // when failed to parse data
    requestHandlerMock.stubbedDataTaskPublisherResult.send((data: data, response: response))
    
    // then
    XCTAssertEqual(
      fetchAlbumsError, .parsingError,
      "should throw parsingError"
    )
  }
  
}

// MARK: - Helper Methods

private extension AlbumServiceTests {
  
  func makeHTTPURLResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: Constants.url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
  }
  
  func makeSerializedResponseData(forAlbums albums: [AlbumEntity]) -> Data {
    let encoder = JSONEncoder()
    let response = AlbumSearchResponse(results: albums)
    return try! encoder.encode(response)
  }
  
}
