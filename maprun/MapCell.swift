//
//  MapCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-05.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import MapKit

class MapCell: UITableViewCell, MKMapViewDelegate {
    
    // MARK : - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Action
    @IBAction func didTapOnMap(_ sender: Any) {
        mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                mapView.removeAnnotation($0)
            }
        }
        
        let location = (sender as AnyObject).location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        self.addAnnotation(coordinate)
        onLocationSelected!(coordinate)
    }
    
    
    // MARK : - Variables
    var onLocationSelected: ((CLLocationCoordinate2D) -> Void)?
    var location : CLLocationCoordinate2D = CLLocationCoordinate2D() {
        didSet {
            addAnnotation(location)
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    
    fileprivate func configure() {
        selectionStyle = .none
        mapView.delegate = self
        addAnnotation(location)
    }
    
    func addAnnotation(_ coordinate : CLLocationCoordinate2D) -> Void {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
}
