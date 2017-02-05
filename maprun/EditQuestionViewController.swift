//
//  EditQuestionViewController.swift
//  maprun
//
//  Created by Per Sonberg on 2017-01-28.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import MapKit
import SideMenu
import DynamicButton
import CoreLocation
import RKDropdownAlert
import DGRunkeeperSwitch
import MXParallaxHeader

class EditQuestionViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, MissionDelegate {
    
    // MARK : - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Variable
    let schoolId = "-KSg962QIiZbOxpG5lvg"
    
    let screen = UIScreen.main.bounds
    var locationManager : CLLocationManager!
    var questionDelegate : QuestionDelegate?
    var sidebarDelegate : SidebarDelegate?
    var delete : UIBarButtonItem?
    var save : UIBarButtonItem?
    var mission : Mission = Mission()
    var question : Question = Question()

    var mapTap : UITapGestureRecognizer?
    var mapView : MKMapView = MKMapView()
    
    var editButton : UIButton?
    
    // MARK : - Actions
    func didTouchSave(_ sender : Any) {
        self.showSpinner()
        
        // MARK : - Save location
        for annotation in self.mapView.annotations {
            if annotation is MKPointAnnotation {
                let point = annotation as! MKPointAnnotation
                if point.accessibilityHint == self.question.id {
                    print("saving new location")
                    self.question.lat = annotation.coordinate.latitude
                    self.question.long = annotation.coordinate.longitude
                }
            }
        }
        
        // MARK : - Fetch data from cells
        for cell in self.tableView.visibleCells {
            if let indexPath : IndexPath = self.tableView.indexPath(for: cell) {
                
                // MARK : - Section 1
                if indexPath.section == 0 {
                    if let current : TextFieldTableViewCell = cell as! TextFieldTableViewCell {
                        if indexPath.row == 0 {
                            self.question.name = current.textField.text!
                        }
                        
                        if indexPath.row == 1 {
                            self.question.text = current.textField.text!
                        }
                    }
                }
                
                // MARK : - Save answers
                if self.question.type == .choose && indexPath.section == 1 && indexPath.row > 0 {
                    if let current : EditAnswerTableViewCell = cell as? EditAnswerTableViewCell {
                        self.question.answers[indexPath.row - 1] = current.answer
                    }
                }
            }
        }
        
        
        // MARK : - Validate data
        if self.question.name.characters.count < 5 {
            RKDropdownAlert.title("Titel behövs", message: "Du måste ha en title (minst 5 tecken)", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
        } else if(self.question.lat == Double(0) && self.question.long == Double(0)) {
            RKDropdownAlert.title("Plats behövs", message: "Du måste välja plats (Det gör du genom att trycka på kartan)", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
        } else {
            
             // MARK : - Save
            self.question.save("-KSg962QIiZbOxpG5lvg", missionId: self.mission.id)
            
            
            // MARK : - Hide Spinner
            self.hideSpinner()
            
            // MARK : - Send back to view
            self.questionDelegate?.didUpdateQuestion(question: self.question)
            
            // MARK : - Dismiss
            self.navigationController?.popToRootViewController(animated: true)
           
        }
        
        self.hideSpinner()
    }
    
    func didTouchDelete(_ sender : Any) {
        self.question.delete(schoolId, missionId: self.mission.id)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didTouchClose(_ sender : Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK : - Did change map pin
    func didTouchMapView(_ sender: UITapGestureRecognizer) {
        self.mapView.annotations.forEach {
            if ($0 is MKPointAnnotation) {
                let annotation = $0 as! MKPointAnnotation
                if annotation.accessibilityHint == self.question.id {
                    self.mapView.removeAnnotation($0)
                }
            }
        }
        
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        self.addAnnotation(coordinate: coordinate)
    }
    
    
    // MARK : - Did change type
    func switchValueDidChange(_ sender : DGRunkeeperSwitch) {
        switch sender.selectedIndex {
        case 0:
            self.question.type = .choose
            break
            
        case 1:
            self.question.type = .image
            break

        default:
            self.question.type = .text
            break
        }
        
        self.tableView.reloadData()
    }
    
    // MARK : - Create new answer
    func didTouchNew(_ sender: Any) {
        self.question.answers.insert(Answer(), at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.bottom)
    }
    
    func didTouchEdit(_ sender: Any) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
           self.editButton?.setTitle("Redigera", for: .normal)
        } else {
            tableView.setEditing(true, animated: true)
            self.editButton?.setTitle("Klar", for: .normal)
        }
    }
    
    // MARK : - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.setupLocation()
        tableView.frame.origin = CGPoint(x: 0, y: 64)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        
        self.mapTap = UITapGestureRecognizer(target: self, action: #selector(EditQuestionViewController.didTouchMapView(_:)))
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 350))
        self.mapView.addGestureRecognizer(self.mapTap!)
        self.mapView.delegate = self
        
        // MARK : - Add all annotations to map
        for quest in self.mission.questions {
            let annotation = MKPointAnnotation()
            annotation.accessibilityHint = quest.id
            annotation.coordinate = CLLocationCoordinate2D(latitude: quest.lat, longitude: quest.long)
            self.mapView.addAnnotation(annotation)
            print("add annotaion")
        }
        
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
        
        let switchView = UIView(frame: CGRect(x: 0, y: 60, width: screen.size.width, height: 46))
        let selector = runkepperSwitch()
        
        switchView.backgroundColor = UIColor(red: 229.0/255.0, green: 163.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        
    
        
        switch self.question.type {
        case .choose:
            selector.setSelectedIndex(0, animated: true)
            break
            
        case .image:
            selector.setSelectedIndex(1, animated: true)
            break
            
        default:
            selector.setSelectedIndex(2, animated: true)
            break
         
         }
        
        switchView.addSubview(selector)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = switchView
        tableView.parallaxHeader.height = 350;
        tableView.parallaxHeader.minimumHeight = 62
        tableView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        tableView.parallaxHeader.view = self.mapView
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditQuestionViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditQuestionViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.parent is UISideMenuNavigationController {
            if let parent : UISideMenuNavigationController = self.parent as! UISideMenuNavigationController? {
                if parent.isBeingDismissed {
                    self.sidebarDelegate?.didCloseSidebar(mission: self.mission)
                }
            }
        }
    }
    
    
    // MARK : - UI
    func updateUI() {
        self.navigationItem.title = ""
        
        // Save Button
        self.save = UIBarButtonItem(title: "Spara", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchSave(_:)))
        self.save?.tintColor = UIColor(red: 0.1, green: 0.74, blue: 0.61, alpha: 1)
        
        // Delete Button
        self.delete = UIBarButtonItem(title: "Ta bort", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchDelete(_:)))
        self.delete?.tintColor = UIColor(red: 0.91, green: 0.29, blue: 0.21, alpha: 1)
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        space.width = 30
        
        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(EditQuestionViewController.didTouchClose(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
        
        if self.question.id.characters.count > 0 {
            self.navigationItem.rightBarButtonItems = [self.save!, space, self.delete!]
        } else {
            self.navigationItem.rightBarButtonItems = [self.save!]
        }
        
    }
    
    // MARK : - Mission Delegate
    func didUpdateMission(mission: Mission) {
        self.mission = mission
    }
    
    // MARK : - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.question.type == .choose {
            return 3
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        if section == 2 {
            return 1
        }
        
        return self.question.answers.count + 1
    }
    
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 2 {
            return true
        }
        
        
        return false
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "name", for: indexPath) as! TextFieldTableViewCell
                cell.textField.text = self.question.name
                cell.helpLabel.font = UIFont(name: "Futura", size: (cell.helpLabel?.font.pointSize)!)
                return cell
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "name", for: indexPath) as! TextFieldTableViewCell
                cell.helpLabel?.text = "Beskrivning"
                cell.helpLabel.font = UIFont(name: "Futura", size: (cell.helpLabel?.font.pointSize)!)
                cell.textField.text = self.question.text
                return cell
            }
            
        
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "alternativ", for: indexPath) as! SeperatorTableViewCell
                self.editButton = cell.editButton
                cell.editButton.addTarget(self, action: #selector(EditQuestionViewController.didTouchEdit(_:)), for: .touchUpInside)
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as! EditAnswerTableViewCell
            cell.answer = self.question.answers[indexPath.row - 1]
            return cell

        }
        
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Lägg till svaralternativ"
            cell.textLabel?.font = UIFont(name: "Futura", size: (cell.textLabel?.font.pointSize)!)
            cell.accessoryView = UIImageView(image: UIImage.fontAwesomeIcon(.plus, textColor: .darkGray, size: CGSize(width: 28, height: 28)))
            return cell
        }
        
        
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            print(indexPath)
            self.didTouchNew(indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row > 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 && indexPath.row > 0 {
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Ta bort", handler: { (button :UITableViewRowAction, indexPath : IndexPath) in
                self.question.answers.remove(at: indexPath.row - 1)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
            })
            
            return [delete]
        }
        
        return []
    }
    
    // MARK : - Location
    func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations.last! as CLLocation
        
        if self.question.lat != 0 {
            location = CLLocation(latitude: self.question.lat, longitude: self.question.long)
        }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        //self.MapRow?.cell.mapView.setRegion(region, animated: true)
    }
    
    
    // MARK : - Animated Switch
    func runkepperSwitch() -> DGRunkeeperSwitch {
        
        let runkeeperSwitch = DGRunkeeperSwitch(titles: ["Välj", "Bild", "Fritext"])
        runkeeperSwitch.backgroundColor = UIColor(red: 229.0/255.0, green: 163.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        runkeeperSwitch.selectedBackgroundColor = .white
        runkeeperSwitch.titleColor = .white
        runkeeperSwitch.selectedTitleColor = UIColor(red: 255.0/255.0, green: 196.0/255.0, blue: 92.0/255.0, alpha: 1.0)
        runkeeperSwitch.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
        runkeeperSwitch.frame = CGRect(x: self.tableView.bounds.width/2 - 220.0, y: 08.0, width: 300.0, height: 30.0)
        runkeeperSwitch.addTarget(self, action: #selector(EditQuestionViewController.switchValueDidChange(_:)), for: .valueChanged)
        
        return runkeeperSwitch
    
    }
    
    
    // MARK : - Map View
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin : MKPinAnnotationView = MKPinAnnotationView()
        
        pin.annotation = annotation
        pin.pinTintColor = .white
        
        if annotation is MKPointAnnotation {
            let point : MKPointAnnotation = annotation as! MKPointAnnotation
            if point.accessibilityHint == self.question.id {
                print("yellow")
                pin.pinTintColor = .flatYellowDark
            }
        }
        
        pin.animatesDrop = true
        pin.canShowCallout = true
        
        return pin
    }
    
    func goToLocation(_ location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotation(coordinate : CLLocationCoordinate2D) -> Void {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.accessibilityHint = self.question.id
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK : - Keyboard 
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
}


// MARK: - Cache Sidebar
extension UISideMenuNavigationController : NSDiscardableContent {
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}
