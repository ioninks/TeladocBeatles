//
//  AlbumsViewModel.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

struct AlbumsViewModelInput {
  
}

struct AlbumsViewModelOutput {
  let cellTitles: AnyPublisher<[String], Never>
}

protocol AlbumsViewModelProtocol {
  func bind(input: AlbumsViewModelInput) -> AlbumsViewModelOutput
}

final class AlbumsViewModel: AlbumsViewModelProtocol {
  
  struct Dependencies {
    let albumService: AlbumServiceProtocol
  }
  
  private let initialQuery: String
  private let dependencies: Dependencies
  
  init(initialQuery: String, dependencies: Dependencies) {
    self.initialQuery = initialQuery
    self.dependencies = dependencies
  }
  
  // MARK: WordFrequenciesListViewModelProtocol
  
  func bind(input: AlbumsViewModelInput) -> AlbumsViewModelOutput {
    let albums = dependencies.albumService.fetchAlbums(artistName: initialQuery)
    
    let titles = albums
      .map { list in
        list.map(\.collectionName)
      }
      .replaceError(with: [])
    
    return .init(cellTitles: titles.eraseToAnyPublisher())
  }
  
}
