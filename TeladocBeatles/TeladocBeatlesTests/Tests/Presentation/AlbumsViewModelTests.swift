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
  static let album = AlbumEntity(collectionId: 1, collectionName: "1")
}

final class AlbumsViewModelTests: XCTestCase {
  
  // system under test
  private var viewModel: AlbumsViewModel!
  
  // mocks
  private var albumServiceMock: AlbumServiceMock!
  
  // cancellables
  private var cellConfigurationsCancellable: AnyCancellable!
  
  // input subjects
  private var searchQueryDidChangeSubject: PassthroughSubject<String, Never>!
  
  // output accumulators
  private var cellConfigurationsAccumulator: [[AlbumCellConfiguration]]!
  
  override func tearDown() {
    viewModel = nil
    albumServiceMock = nil
    cellConfigurationsCancellable = nil
    cellConfigurationsAccumulator = nil
    
    super.tearDown()
  }
  
  // MARK: Tests
  
  func test_whenReceivedAlbumsFromService_shouldEmitConfigurations() {
    // given
    setUpViewModel(initialQuery: Constants.initialQuery)
    
    // when received albums for the initial query
    let album = AlbumEntity(collectionId: 1, collectionName: "1")
    albumServiceMock.stubbedFetchAlbumsResult.send([album])
    
    // then
    let expectedConfiguration = AlbumCellConfiguration(id: 1, title: "1")
    XCTAssertEqual(
      cellConfigurationsAccumulator, [[expectedConfiguration]],
      "should emit proper cell configurations"
    )
  }
  
}

// MARK: - Helper Methods

private extension AlbumsViewModelTests {
  
  func setUpViewModel(initialQuery: String) {
    albumServiceMock = .init()
    viewModel = .init(
      initialQuery: Constants.initialQuery,
      dependencies: .init(albumService: albumServiceMock)
    )
    
    searchQueryDidChangeSubject = .init()
    
    let output = viewModel.bind(
      input: .init(
        searchQueryDidChange: searchQueryDidChangeSubject.eraseToAnyPublisher()
      )
    )
    
    cellConfigurationsAccumulator = []
    cellConfigurationsCancellable = output.cellConfigurations
      .sink(receiveValue: { configurations in
        self.cellConfigurationsAccumulator.append(configurations)
      })
  }
  
}
