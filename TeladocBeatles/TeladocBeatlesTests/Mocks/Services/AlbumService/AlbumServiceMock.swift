//
//  AlbumServiceMock.swift
//  TeladocBeatlesTests
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

@testable import TeladocBeatles

final class AlbumServiceMock: AlbumServiceProtocol {
  
  private(set) var invokedFetchAlbumsCount = 0
  let stubbedFetchAlbumsResult = PassthroughSubject<[AlbumEntity], AlbumServiceError>()
  
  func fetchAlbums(artistName: String) -> AnyPublisher<[AlbumEntity], AlbumServiceError> {
    stubbedFetchAlbumsResult
      .handleEvents(receiveSubscription:  { _ in
        self.invokedFetchAlbumsCount += 1
      })
      .eraseToAnyPublisher()
  }
  
}
