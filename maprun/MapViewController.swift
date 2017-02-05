//
//  MapViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-26.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import MapKit
import SideMenu
import DynamicButton
import CoreLocation

protocol SidebarDelegate {
    func didSubmitMission(_ : Bool, mission : Mission)
    func didCloseSidebar(mission : Mission)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SidebarDelegate, MissionDelegate {
    
    // MARK : - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sidebarButton: DynamicButton!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK : - Actions
    @IBAction func didTouchSubmit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func didTouchMenu(_ sender: Any) {
        self.showSpinner()
        
        if self.sidebar == nil {
        self.sidebar = UIStoryboard(name: "Mission", bundle: nil).instantiateViewController(withIdentifier: "SidebarController") as? UISideMenuNavigationController
        }
        
        let controller = sidebar?.viewControllers.first as! SidebarViewController
        controller.mission = self.mission
        controller.sidebarDelegate = self
        
        DispatchQueue.main.async {
            self.present(self.sidebar!, animated: true, completion: {
                self.menuButton.setStyle(DynamicButtonStyle.close, animated: true)
            })
            //self.performSegue(withIdentifier: "sidebarSegue", sender: self)
        }
    }
   
    
    // MARK : - Variables
    let regionRadius : Int = 10
    var locationManager : CLLocationManager!
    var missionDelegate : MissionDelegate?
    let transition = ExpandingCellTransition()
    var sidebar : UISideMenuNavigationController?
    var navigationBarSnapshot: UIView!
    var navigationBarHeight: CGFloat = 0
    var menuButton : DynamicButton = DynamicButton(style: DynamicButtonStyle.hamburger)
    var locationButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
    var user : User = User()
    var mission : Mission = Mission() {
        didSet {
            if self.mission.questions.count > 0 {
                // MARK : - Move progress
                if mission.id.characters.count > 0 {
                    for q in 0...mission.questions.count - 1 {
                        if oldValue.questions.count > 0 {
                            for o in 0...oldValue.questions.count - 1 {
                                if mission.questions[q].id == oldValue.questions[o].id  {
                                    
                                    // MARK : - Locked
                                    mission.questions[q].isLocked = oldValue.questions[o].isLocked
                                    
                                    
                                    
                                    // MARK : - Type progress
                                    if mission.questions[q].type == .choose {
                                        for a in 0...mission.questions[q].answers.count - 1 {
                                            for oa in 0...oldValue.questions[o].answers.count - 1 {
                                                if mission.questions[q].answers[a].id == oldValue.questions[o].answers[oa].id {
                                                    mission.questions[q].answers[a].isSelected = oldValue.questions[o].answers[oa].isSelected
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    if mission.questions[q].type == .image {
                                        mission.questions[q].image = oldValue.questions[o].image
                                        
                                    }
                                    
                                    if mission.questions[q].type == .text {
                                        mission.questions[q].answer = oldValue.questions[o].answer
                                        
                                    }
                                }
                            }
                        }

                    }
            }
            
            
            // MARK : - Create Annotation
            if self.mission.questions.count > 0 {
                for index in 0...(self.mission.questions.count - 1) {
                    let question = self.mission.questions[index]
                    
                    if mapView != nil && self.mission.questions[index].annotation != nil {
                        mapView.removeAnnotation(self.mission.questions[index].annotation!)
                        self.mission.questions[index].annotation = nil
                    }
                    
                    // MARK : - Create annotation if i doenst exists
                    if self.mission.questions[index].annotation == nil {
                        self.mission.questions[index].annotation = MKPointAnnotation()
                        self.mission.questions[index].annotation?.title = question.name
                        self.mission.questions[index].annotation?.coordinate = CLLocationCoordinate2D(latitude: question.lat, longitude: question.long)
                        
                        if mapView != nil {
                            mapView.add(MKCircle(center: (question.annotation?.coordinate)!, radius: CLLocationDistance(self.regionRadius)))
                            mapView.addAnnotation(question.annotation!)
                        }
                    }
                }
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = transition
        mapView.delegate = self
        navigationItem.title = mission.name
        location()
        
        if navigationBarSnapshot != nil {
            navigationBarSnapshot.frame.origin.y = -navigationBarHeight
            view.addSubview(navigationBarSnapshot)
        }
        
        
        // MARK : - Show Annotations
        for question in mission.questions {
            if question.annotation != nil {
                mapView.add(MKCircle(center: (question.annotation?.coordinate)!, radius: 1000))
                mapView.addAnnotation(question.annotation!)
            }
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.design()
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        
        // MARK : - Add user to mission
        if !self.mission.users.contains(self.user.id) {
            self.mission.users.append(self.user.id)
        }
        
        
        // MARK : - Cache sidebar
        if self.sidebar == nil {
            self.sidebar = UIStoryboard(name: "Mission", bundle: nil).instantiateViewController(withIdentifier: "SidebarController") as? UISideMenuNavigationController
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK : - Mission Delegate
    func didUpdateMission(mission: Mission) {
        self.mission = mission
        self.missionDelegate?.didUpdateMission(mission: mission)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UISideMenuNavigationController {
            let nav : UISideMenuNavigationController = segue.destination as! UISideMenuNavigationController
            let vc : SidebarViewController = nav.viewControllers.first as! SidebarViewController
            self.missionDelegate = vc
            menuButton.setStyle(DynamicButtonStyle.close, animated: true)
            
            for index in 0...self.mission.questions.count - 1 {
                self.mission.questions[index].isNew = false
            }
            self.updateBadge()
            
            vc.sidebarDelegate = self
            vc.mission = self.mission
            vc.user = self.user
        }
    }
    
    // MARK : - Sidebar
    func didCloseSidebar(mission : Mission) {
        self.menuButton.setStyle(DynamicButtonStyle.hamburger, animated: true)
        self.mission = mission
    }
    
    func didSubmitMission( _ completed: Bool, mission : Mission) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK : - UI
    var menuView : UIView = UIView()
    var locationView : UIView = UIView()
    
    func design() {
        
        // MARK : - Menu Button
        self.menuView = UIView(frame: CGRect(x: -72, y: 60, width: 72, height: 72))
        self.menuView.backgroundColor = .flatYellow
        
        menuButton.frame = CGRect(x: 0, y: 0, width: 72, height: 72)
        menuButton.tintColor = .black
        menuButton.lineWidth = 2
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        menuButton.addTarget(self, action: #selector(MapViewController.didTouchMenu(_:)), for: .touchUpInside)
        
        self.menuView.addSubview(menuButton)
        view.addSubview(self.menuView)

        // MARK : - Location Button
        self.locationView = UIView(frame: CGRect(x: -72, y: 132, width: 72, height: 72))
        self.locationView.backgroundColor = UIColor.flatBlackDark.withAlphaComponent(0.2)
        
        locationButton.tintColor = .black
        locationButton.setImage(UIImage.fontAwesomeIcon(.locationArrow, textColor: .flatYellow, size: CGSize(width: 36, height: 36)), for: .normal)
        locationButton.addTarget(self, action: #selector(MapViewController.didTouchFindMe(_:)), for: .touchUpInside)
        
        self.locationView.addSubview(locationButton)
        view.addSubview(self.locationView)
        
        UIView.animate(withDuration: 0.3) {
            self.locationView.frame.origin.x = 0
            self.menuView.frame.origin.x = 0
        }
    }
    
    // MARK : - Update Badge
    func updateBadge()  {
        self.menuView.badge("", color: UIColor.clear)
        
        for index in 0...self.mission.questions.count - 1 {
            if self.mission.questions[index].isNew {
                self.menuView.badge("Ny", color: UIColor.flatRed)
            }
        }
    }
    
    // MARK : - Location
    func didTouchFindMe(_ sender : Any) {
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    func location() {
        print("location")
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        checkMapPositionPremission()
        
        locationManager.startUpdatingLocation()
    }
    
    func checkMapPositionPremission() -> Void {
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("have location")
        
        // MARK : - Have position?
        if locations.last != nil {
            
            // MARK : - Show all on map
            mapView.showAnnotations(self.mapView.annotations, animated: false)
            for annotation in self.mapView.annotations {
                
                // MARK : - Check if annotation is in position
                if annotation is MKUserLocation {} else {
                    let dis = locations.last?.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
                    if Int(dis as Double!) < self.regionRadius {
                        
                        // MARK : - Find stop connected to annotation
                        if self.mission.questions.count > 0 {
                            for index : Int in 0...(self.mission.questions.count - 1)  {
                                if self.mission.questions[index].name == annotation.title! && self.mission.questions[index].isLocked {
                                    
                                    // MARK : - Unlock
                                    self.mission.questions[index].isNew = true
                                    self.mission.questions[index].isLocked = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK : - Map View
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circle = MKCircleRenderer(circle: overlay)
            circle.fillColor = UIColor.flatYellow.withAlphaComponent(0.4)
            return circle
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            let pin : MKPinAnnotationView = MKPinAnnotationView()
            pin.annotation = annotation
            pin.pinTintColor = .flatYellowDark
            pin.animatesDrop = true
            pin.canShowCallout = true
            return pin
        }
        
        return nil

    }
}


// MARK : - Badge
extension UIView {
    func badge(_ text : String, color : UIColor) {
        
        if text == "" || color == .clear {
            
            for view in self.subviews {
                if view is UILabel {
                    view.removeFromSuperview()
                }
            }
        
        } else {
            let label = UILabel(frame: CGRect(x: self.bounds.size.width, y: 0, width: 100, height: 16))
            label.clipsToBounds = true
            label.text = text
            label.textAlignment = .center
            label.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            label.backgroundColor = color
            label.sizeToFit()
            
            let badgeSize = label.frame.size
            let height = max(20, Double(badgeSize.height) + 5.0)
            let width = max(height, Double(badgeSize.width) + 10.0)
            let x = label.frame.origin.x - label.frame.size.width/2
            let y = label.frame.origin.y - label.frame.size.height/2
            
            label.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
            label.layer.cornerRadius = label.frame.size.height/2
            
            self.addSubview(label)
        }
    }
}

// MARK: ExpandingTransitionPresentedViewController
extension MapViewController: ExpandingTransitionPresentedViewController {
    
    func expandingTransition(_ transition: ExpandingCellTransition, navigationBarSnapshot: UIView) {
        self.navigationBarSnapshot = navigationBarSnapshot
        self.navigationBarHeight = navigationBarSnapshot.frame.height
    }
}
