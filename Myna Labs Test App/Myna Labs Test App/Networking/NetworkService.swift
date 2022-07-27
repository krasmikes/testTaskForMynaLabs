//
//  NetworkService.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import Foundation
import UIKit

final class NetworkService {
    static let shared = NetworkService()
    static let apiKey: String = {
        if let path = Bundle.main.path(forResource: "Giphy-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let apiKey = dict["API_KEY"] as? String {
            return apiKey
        } else {
            return "your-api-key"
        }
    }()

    func getTrendingGifs(_ request: GetTrendingGifsRequest, completion: @escaping (Result<GetTrendingGifsRequest.Response, Error>) -> ()) {
        guard var urlComponent = URLComponents(string: request.url) else {
            return completion(
                .failure(
                    NSError(domain: "Error in creating base URL", code: 1)
                )
            )
        }

        var queryItems: [URLQueryItem] = []

        request.queryItems.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            queryItems.append(urlQueryItem)
        }

        urlComponent.queryItems = queryItems

        guard let url = urlComponent.url else {
            return completion(
                .failure(
                    NSError(domain: "Error in adding components", code: 2)
                )
            )
        }

        var urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                return completion(.failure(error))
            }

            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                return completion(.failure(NSError(domain: "Bad response: \(response)", code: 3)))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "Empty response", code: 4)))
            }

            do {
                try completion(.success(request.decode(data)))
            } catch let error as NSError {
                completion(.failure(error))
            }
        }
        .resume()
    }

    func loadImage(url: String, completion: @escaping (Result<Data, Error>) -> ()) -> URLSessionTask? {
        guard let url = URL(string: url) else { return nil }
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                return completion(.failure(error))
            }

            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                return completion(.failure(NSError(domain: "Bad response: \(response)", code: 5)))
            }

            if let data = data {
                return completion(.success(data))
            } else {
                return completion(.failure(NSError(domain: "Empty response", code: 6)))
            }

        }
        dataTask.resume()

        return dataTask
    }
}
