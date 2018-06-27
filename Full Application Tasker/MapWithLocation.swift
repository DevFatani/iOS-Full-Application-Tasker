//
//  MapWithLocation.swift
//  Full Application Tasker
//
//  Created by Muhammad Fatani on 25/06/2018.
//  Copyright © 2018 Muhammad Fatani. All rights reserved.
//
import UIKit
import GoogleMaps
import CoreLocation

class MapWithLocation: UIViewController {
    fileprivate let TAG = "MapWithLocation"
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var btnItemSave: UIBarButtonItem!
    
    var marker:GMSMarker? = nil
    fileprivate var isSetLocation = false
    fileprivate lazy var locationManager: CLLocationManager = CLLocationManager()
    
    fileprivate var userLocation: CLLocation!{
        didSet{
            let coordinate = userLocation.coordinate
            Logger.normal(tag: TAG, message: "\(#function) \(coordinate.latitude) \(coordinate.longitude)")
            let lat = coordinate.latitude
            let lng = coordinate.longitude
            self.addSingleMarker((lat, lng))
        }
    }


    private func addSingleMarker(_ location: (lat: Double, lng: Double)){
        let coordinate =  CLLocationCoordinate2DMake(location.lat, location.lng)
        if self.marker == nil {
            self.marker = GMSMarker(position: coordinate)
            self.marker?.map  = self.googleMapsView
        }else {
            self.marker?.position = coordinate
        }
        
        self.googleMapsView.animate(to: GMSCameraPosition.camera( withTarget:coordinate, zoom: 17.0))
    }
    
    @IBAction func saveLocation(_ sender: UIBarButtonItem) {
        //        if let save = self.onSave, let marker = self.marker{
        //            save(marker.position.latitude, marker.position.longitude)
        //            self.dismiss(animated: true, completion: nil)
        //        }
        
        if let marker = self.marker{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnItemSave.setTitleTextAttributes(fontItems as [NSAttributedStringKey : Any], for: .normal)
        
        self.locationManager.delegate = self
        self.googleMapsView.delegate = self
        self.googleMapsView.settings.compassButton = true
        
//        if let styleURL =  Bundle.main.url(forResource: "map_style", withExtension: "json") {
//            if let style = try? GMSMapStyle(contentsOfFileURL: styleURL){
//                self.googleMapsView.mapStyle = style
//            }
//        }
    }
    
    let fontItems  = [ kCTFontAttributeName: UIFont(name: "Futura", size: 17)!]

}

extension MapWithLocation: CLLocationManagerDelegate {
 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.isSetLocation {
            self.isSetLocation = true
            self.userLocation = locations.last
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            // If authorized when in use
            manager.startUpdatingLocation()
            break
        case .restricted, .denied:
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            break
        }
    }
    
}

extension MapWithLocation: GMSMapViewDelegate {
    func mapViewSnapshotReady(_ mapView: GMSMapView) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        Logger.normal(tag: TAG, message: "\(#function)")
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        Logger.normal(tag: TAG, message: "\(#function) \(coordinate.latitude) \(coordinate.longitude)")
        
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        destinationMarker.position = position.target
        self.marker?.position = position.target
//        print(destinationMarker.position)
//        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//
//    }
//
//    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
//
//    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
         self.googleMapsView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        Logger.normal(tag: TAG, message: "\(#function)")
//        self.addSingleMarker((coordinate.latitude, coordinate.longitude))
    }
    
    func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        Logger.normal(tag: TAG, message: "\(#function)")
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        Logger.normal(tag: TAG, message: "\(#function)")
        Logger.normal(tag: TAG, message: "placeID: \(placeID), name: \(name), location: \(location.latitude), \(location.longitude)")
        
    }
    
    
}

