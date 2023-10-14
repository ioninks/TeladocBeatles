//
//  AlbumService.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

enum AlbumServiceError: Error, Equatable {
  case networkFailure
  case badResponse
  case parsingError
}

protocol AlbumServiceProtocol {
  func fetchAlbums(artistName: String) -> AnyPublisher<[AlbumEntity], AlbumServiceError>
}

final class AlbumService: AlbumServiceProtocol {
  
  private let requestHandler: RequestHandlerProtocol
  
  init(requestHandler: RequestHandlerProtocol = URLSession.shared) {
    self.requestHandler = requestHandler
  }
  
  func fetchAlbums(artistName: String) -> AnyPublisher<[AlbumEntity], AlbumServiceError> {
    let request = AlbumsRequest(artistName: artistName)
    let decoder = JSONDecoder()
    return self.requestHandler.fetchData(for: request.urlRequest)
      .mapError { _ in AlbumServiceError.networkFailure }
      .tryMap { data, response in
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
          throw AlbumServiceError.badResponse
        }
        return data
      }
      .decode(type: AlbumSearchResponse.self, decoder: decoder)
      .mapError { $0 as? AlbumServiceError ?? .parsingError }
      .map(\.results)
      .eraseToAnyPublisher()
  }
  
}
