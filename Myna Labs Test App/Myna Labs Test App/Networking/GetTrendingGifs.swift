//
//  GetTrendingGifs.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import Foundation

struct GetTrendingGifsRequest {
    typealias Response = GetTrendingGifsResponse

    var url: String = "https://api.giphy.com/v1/gifs/trending"
    private let apiKey = NetworkService.apiKey
    let limit: Int
    let offset: Int

    var queryItems: [String : String] {
        [
            "api_key": apiKey,
            "limit": String(limit),
            "offset": String(offset)
        ]
    }

    func decode(_ data: Data) throws -> GetTrendingGifsResponse {
        let decoder = JSONDecoder()
        let response = try decoder.decode(GetTrendingGifsResponse.self, from: data)
        return response
    }
}

struct GetTrendingGifsResponse: Codable {
    let data: [Gif]
}
