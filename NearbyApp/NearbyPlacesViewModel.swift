//
//  NearbyPlacesViewModel.swift
//  NearbyApp
//
//  Created by Debartha Chakraborty on 11/05/24.
//

import Foundation
import Combine

struct PlaceViewData: Codable {
    let name: String?
}

struct LocationData: Equatable {
    let lat: Double
    let lon: Double
}

protocol NearbyPlacesViewModel {
    var places: CurrentValueSubject<[PlaceViewData], Never> { get }
    var isFetching: CurrentValueSubject<Bool, Never> { get }
    func fetchMorePlaces()
}

class DefaultNearbyPlacesViewModel: NearbyPlacesViewModel {
    
    private let placesService: NearbyPlacesService
    private let locationManager: LocationManager
    
    private(set) var places: CurrentValueSubject<[PlaceViewData], Never> = CurrentValueSubject([])
    private(set) var isFetching: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    private var locationData: CurrentValueSubject<LocationData?, Never> = CurrentValueSubject(nil)
    
    private var currentPage = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(placesService: NearbyPlacesService,
         locationManager: LocationManager) {
        self.placesService = placesService
        self.locationManager = locationManager
        startFetchingLocationIfNeeded()
        addObservers()
    }
    
    private func startFetchingLocationIfNeeded() {
        guard locationData.value == nil else { return }
        locationManager.requestLocationIfNeeded { [weak self] lat, lon in
            print(lat, lon)
            self?.locationData.value = LocationData(lat: lat, lon: lon)
        } onError: { error in
            // TODO: Handle error
            print("error")
        }
    }
    
    private func addObservers() {
        locationData
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] data in
                self?.fetchMorePlaces()
            }
            .store(in: &cancellables)
    }
    
    func fetchMorePlaces() {
        guard let locationData = locationData.value, !isFetching.value else { return }
        isFetching.value = true
        placesService.fetchVenues(data: .init(count: 10, page: currentPage + 1, lat: locationData.lat, lon: locationData.lon)) { [weak self] result in
            guard let self else { return }
            self.isFetching.value = false
            switch result {
            case .success(let data):
                self.currentPage += 1
                self.places.value += data.map { $0.getViewData() }
            case .failure(let error):
                // TODO: Handle error
                print(error)
            }
        }
    }
    
}

extension PlacesData {
    func getViewData() -> PlaceViewData {
        PlaceViewData(name: name)
    }
}
