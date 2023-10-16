//
//  AlbumsViewModel.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import Foundation

struct AlbumCellConfiguration: Hashable, Equatable {
  private let id: UInt
  let title: String
  
  init(id: UInt, title: String) {
    self.id = id
    self.title = title
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

struct AlbumsViewModelInput {
  let searchQueryDidChange: AnyPublisher<String, Never>
}

struct AlbumsViewModelOutput {
  let cellConfigurations: AnyPublisher<[AlbumCellConfiguration], Never>
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
    let trimmedQueries = input.searchQueryDidChange
      .map { $0.trimmingCharacters(in: .whitespaces) }
    
    let emptyQueries = trimmedQueries
      .filter { $0.isEmpty }
      // for empty queries let's just show the initial query (The Beatles)
      .map { [initialQuery] _ in initialQuery }
    
    let nonEmptyQueries = trimmedQueries
      .filter { $0.isEmpty == false }
    
    let searchQueries = emptyQueries
      .merge(with: nonEmptyQueries)
      .debounce(for: 0.5, scheduler: DispatchQueue.main)
    
    let queries = searchQueries
      .prepend(initialQuery)
      .removeDuplicates()
    
    let albums = queries
      .map { [dependencies] query in
        dependencies.albumService.fetchAlbums(artistName: query)
      }
      .switchToLatest()
    
    let cellConfigurations = albums
      .map { list in
        list.map { Self.makeCellConfiguration(for: $0) }
      }
      .replaceError(with: [])
    
    return .init(cellConfigurations: cellConfigurations.eraseToAnyPublisher())
  }
  
  private static func makeCellConfiguration(for album: AlbumEntity) -> AlbumCellConfiguration {
    return .init(id: album.collectionId, title: album.collectionName)
  }
  
}
