//
//  AlbumSearchResponse.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Foundation

struct AlbumSearchResponse: Codable {
  let results: [AlbumEntity]
}
