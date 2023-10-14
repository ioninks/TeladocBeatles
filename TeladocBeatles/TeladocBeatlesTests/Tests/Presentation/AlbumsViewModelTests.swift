//
//  AlbumsViewModelTests.swift
//  TeladocBeatlesTests
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import XCTest

@testable import TeladocBeatles

private enum Constants {
  static let initialQuery = "query"
  static let album = AlbumEntity(collectionName: "1")
}

final class AlbumsViewModelTests: XCTestCase {
  
  // system under test
  private var viewModel: AlbumsViewModel!
  
  // mocks
  private var albumServiceMock: AlbumServiceMock!
  
  // cancellables
  private var cellTitlesCancellable: AnyCancellable!
  
  // accumulators
  private var cellTitlesAccumulator: [[String]]!
  
  override func setUp() {
    super.setUp()
    
    albumServiceMock = .init()
    viewModel = .init(
      initialQuery: Constants.initialQuery,
      dependencies: .init(albumService: albumServiceMock)
    )
    
    let output = viewModel.bind(input: .init())
    
    cellTitlesAccumulator = []
    cellTitlesCancellable = output.cellTitles
      .sink(receiveValue: { titles in
        self.cellTitlesAccumulator.append(titles)
      })
  }
  
  override func tearDown() {
    viewModel = nil
    albumServiceMock = nil
    cellTitlesCancellable = nil
    cellTitlesAccumulator = nil
    
    super.tearDown()
  }
  
  // MARK: Tests
  
  func test_whenReceivedAlbumsFromService_shouldEmitTitles() {
    // when
    albumServiceMock.stubbedFetchAlbumsResult.send([Constants.album])
    
    // then
    XCTAssertEqual(cellTitlesAccumulator, [[Constants.album.collectionName]])
  }
  
}
