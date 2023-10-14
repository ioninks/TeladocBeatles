//
//  AlbumService.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

enum AlbumServiceError: Error {
  case networkFailure
  case badResponse
  case parsingError
}

protocol AlbumServiceProtocol {
  func fetchAlbums(artistName: String) -> AnyPublisher<[AlbumEntity], Error>
}

final class AlbumService: AlbumServiceProtocol {
  
  private let requestHandler: RequestHandlerProtocol
  
  init(requestHandler: RequestHandlerProtocol = URLSession.shared) {
    self.requestHandler = requestHandler
  }
  
  func fetchAlbums(artistName: String) -> AnyPublisher<[AlbumEntity], Error> {
    let request = AlbumsRequest(artistName: artistName)
    let decoder = JSONDecoder()
    return self.requestHandler.dataTaskPublisher(for: request.urlRequest)
      .mapError { _ in AlbumServiceError.networkFailure }
      .tryMap { data, response in
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
          throw AlbumServiceError.badResponse
        }
        do {
          return try decoder.decode(AlbumSearchResponse.self, from: data)
        } catch {
          throw AlbumServiceError.parsingError
        }
      }
      .map(\.results)
      .eraseToAnyPublisher()
  }
  
}
