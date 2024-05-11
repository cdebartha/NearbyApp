//
//  LocationManager.swift
//  NearbyApp
//
//  Created by Debartha Chakraborty on 11/05/24.
//

import CoreLocation

enum LocationError: Error {
    case denied
    case restricted
    case unknown
}

class LocationManager: NSObject {
    
    private var onError: ((LocationError) -> Void)?
    private var onUpdate: ((Double, Double) -> Void)?
    
    private let client: CLLocationManager
    
    override init() {
        client = CLLocationManager()
        client.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        client.delegate = self
    }
    
    
    func requestLocationIfNeeded(onUpdate: ((Double, Double) -> Void)?, onError: ((LocationError) -> Void)?) {
        
        self.onUpdate = onUpdate
        self.onError = onError
        
        handleAuthorizationStatus()
    }
    
    private func handleAuthorizationStatus() {
        switch client.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            client.startUpdatingLocation()
        case .denied:
            onError?(.denied)
        case .restricted:
            onError?(.restricted)
        case .notDetermined:
            client.requestWhenInUseAuthorization()
        default:
            onError?(.unknown)
            
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            onUpdate?(latitude, longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(.unknown)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus()
    }
}
