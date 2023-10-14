//
//  AlbumsRequest.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Foundation

struct AlbumsRequest: BaseRequest {
  
  let artistName: String
  
  init(artistName: String) {
    self.artistName = artistName
  }
  
  var endpoint: String {
    "search"
  }
  
  var queryParameters: [String : String] {
    [
      "term": artistName,
      "media": "music",
      "entity": "album",
      "attribute": "artistTerm"
    ]
  }
  
}
