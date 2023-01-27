//
//  ViewController.swift
//  CoreLocationStack
//
//  Created by Александр Коробицын on 25.01.2023.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private var annotations: [MKPointAnnotation] = []
    
    private let routeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setBackgroundImage(.add, for: .normal)
        button.alpha = 0.9
        return button
    }()

    private let userLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "location.north.circle.fill"), for: .normal)
        button.tintColor = UIColor.systemBlue
        button.alpha = 0.9
        return button
    }()

    private let resetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(.remove, for: .normal)
        button.alpha = 0.9
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceConstraints()
        instanceTargets()
        instanceLocationManager()
    }
    
//MARK: - funcRoute
    
    @objc private func route() {
        presentAddAlert(title: "Адрес назначения") { [self] text in
            geocoder.geocodeAddressString(text) { [self] placemarks, error in
                
                if let error = error {
                    presentErrorAlert(title: error.localizedDescription)
                }
                
                guard let placemarks = placemarks else {return}
                guard let placemark = placemarks.first else {return}
                guard let location = placemark.location else {return}
                
                let annotation = MKPointAnnotation()
                annotation.title = placemark.name
                annotation.coordinate = location.coordinate
                
                annotations.append(annotation)
                
                mapView.showAnnotations(annotations, animated: true)
                
                if annotations.count > 1  {
                    for index in 0...annotations.count - 2 {
                        setDirection(sourse: annotations[index].coordinate,
                                     destination: annotations[index + 1].coordinate)
                    }
                }
            }
        }
    }
    
    //MARK: - funcShowUserLocation

    @objc private func showUserLocation() {
        guard let location = locationManager.location else {return}
        mapView.setCenter(location.coordinate, animated: true)
    }

    //MARK: - funcReset
    
    @objc private func reset() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotations = []
        resetButton.isEnabled = false
        userLocationUpdate() 
    }
    
    //MARK: - Location&Direction
    
    private func instanceLocationManager() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func userLocationUpdate() {
        guard let location = locationManager.location else {return}
        let coordinate: CLLocationCoordinate2D = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    private func setDirection(sourse: CLLocationCoordinate2D,
                              destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourse))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let direction = MKDirections(request: request)
         
        direction.calculate { [self] respounce, error in
            if let error = error {
                presentErrorAlert(title: error.localizedDescription)
            }
            
            guard let respounce = respounce else {return}
            
            var minRoute = respounce.routes[0]
            for route in respounce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            mapView.addOverlay(minRoute.polyline)
            resetButton.isEnabled = true
        }
    }
}

//MARK: -  MapViewDelegate

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.systemBlue
        return renderer
    }
}

//MARK: - CLManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationUpdate()
    }
}

//MARK: - SetConstraints & Targets

extension MainViewController {
    private func instanceTargets() {
        routeButton.addTarget(self, action: #selector(route), for: .touchUpInside)
        userLocationButton.addTarget(self, action: #selector(showUserLocation), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
    }
    
    private func instanceConstraints() {
        view.addSubview(mapView)
        mapView.addSubview(routeButton)
        mapView.addSubview(userLocationButton)
        mapView.addSubview(resetButton)
        
        resetButton.isEnabled = false
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            userLocationButton.widthAnchor.constraint(equalToConstant: 50),
            userLocationButton.heightAnchor.constraint(equalToConstant: 50),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -25),
            userLocationButton.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),

            routeButton.widthAnchor.constraint(equalToConstant: 50),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -25),
            routeButton.bottomAnchor.constraint(equalTo: userLocationButton.topAnchor, constant: -50),

            resetButton.widthAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -25),
            resetButton.topAnchor.constraint(equalTo: userLocationButton.bottomAnchor, constant: 50)
            
        ])
        
    }
}



