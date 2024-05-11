//
//  NearbyPlacesService.swift
//  NearbyApp
//
//  Created by Debartha Chakraborty on 11/05/24.
//

import Foundation

struct VenuesRequestData {
    let count: Int
    let page: Int
    let lat: Double
    let lon: Double
}

enum PlacesError: Error {
    case httpError
    case parsingError
}

protocol NearbyPlacesService {
    func fetchVenues(data: VenuesRequestData, completion: @escaping (Result<[PlacesData], PlacesError>) -> Void)
}

class DefaultNearbyPlacesService: NearbyPlacesService {
    
    private let httpClient: URLSession
    
    init(httpClient: URLSession = .shared) {
        self.httpClient = httpClient
    }
    
    func fetchVenues(data: VenuesRequestData, completion: @escaping (Result<[PlacesData], PlacesError>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.seatgeek.com"
        urlComponents.path = "/2/venues"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "Mzg0OTc0Njl8MTcwMDgxMTg5NC44MDk2NjY5"),
            URLQueryItem(name: "per_page", value: String(data.count)),
            URLQueryItem(name: "page", value: String(data.page)),
            URLQueryItem(name: "lat", value: String(data.lat)),
            URLQueryItem(name: "lon", value: String(data.lon)),
        ]
        
        guard let url = urlComponents.url else { return }
         
        httpClient.dataTask(with: url) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.httpError))
                return
            }
            
            guard let response = try? JSONDecoder().decode(PlacesResponse.self, from: data) else {
                completion(.failure(.parsingError))
                return
            }
            
            completion(.success(response.venues ?? []))
            
        }.resume()
    }
}

struct PlacesData: Codable {
    var name: String?
}

struct PlacesResponse: Codable {
    var venues: [PlacesData]?
}
