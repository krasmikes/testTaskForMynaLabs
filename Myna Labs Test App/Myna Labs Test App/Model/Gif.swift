//
//  Gif.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import Foundation

class Gif: Codable, Hashable {
    let id: String
    let url: String
    let bitlyUrl: String
    let images: GifImages

    enum CodingKeys: String, CodingKey {
        case bitlyUrl = "bitly_url"
        case id, url, images
    }

    class GifImages: Codable {
        let original: GifImage
        let small: GifImage

        class GifImage: Codable {
            let height: String
            let width: String
            let url: String
            var data: Data?
        }

        enum CodingKeys: String, CodingKey {
            case small = "fixed_width"
            case original
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Gif, rhs: Gif) -> Bool {
        return lhs.id == rhs.id
    }
}
