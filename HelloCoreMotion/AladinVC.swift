//
//  AladinVC.swift
//  Copyright © 2020 Tod Landis. All rights reserved.
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import WebKit
import MapKit

class AladinVC: UIViewController, LatLonFinderDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var plusView: PlusView!
    @IBOutlet weak var whoIsThatBehindTheScreen: SkyViewOverlay!
    
    @IBOutlet weak var searchCompleteLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var raDecLabel: UILabel!
    
    @IBOutlet weak var fovLabel: UILabel!
    
    @IBOutlet weak var howToGetHelpLabel: UILabel!
        
    var aladin:Aladin? = nil
    var aladinPixelWidth:Int? = nil
    var aladinPixelHeight:Int? = nil
    
    var appDelegate:AppDelegate? = nil

    let latLonFinder = LatLonFinder()
    var latitude:Double = 0.0 {
        didSet {
            // LATER
            // latitude should tilt the view
            // but this hides the Aladin logo
//            webView.transform = CGAffineTransform(rotationAngle: CGFloat(Float(latitude) * Float.pi/180.0));
        }
    }
    var longitude:Double = 0.0
    
    var showStarted:Bool = false   // has startTheShow() been called?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Astro.test20()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("ERROR no appDelegate in AladinVC")
            return
        }
        
        self.appDelegate = appDelegate

        whoIsThatBehindTheScreen.backgroundColor = UIColor.black
        whoIsThatBehindTheScreen.alpha = 1.0
        whoIsThatBehindTheScreen.isUserInteractionEnabled = false
        webView.alpha = 0.0
        
        searchBar.delegate = self

        if appDelegate.targetIsFromUrl {
            searchBar.text = appDelegate.initialTarget
            aladin = Aladin(webView, target: appDelegate.initialTarget, survey: appDelegate.initialSurvey, fov:appDelegate.initialFOV)
        }
        else {
            latLonFinder.delegate = self
            // see locationChanged()
            latLonFinder.getLocationOnce()
        }
            
        searchCompleteLabel.alpha = 0.0
        appDelegate.aladinVC = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        pinch.delegate = self
        view.addGestureRecognizer(pinch)
        
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
//        swipe.delegate = self
//        view.addGestureRecognizer(swipe)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let settings =  self.appDelegate?.settings {
            self.plusView.alpha = settings.drawPlusSigns ? 1.0 : 0.0
            if !(self.aladin?.getImageSurvey() == settings.survey) {
                self.aladin?.setImageSurvey(survey: settings.survey)
            }
        }

        if let skyViewVC = self.appDelegate?.skyViewVC {
            // when SkyView sets the target, Aladin must have
            //   been initialized, because ALadinVC is the startup VC
            let (raMap,decMap) = skyViewVC.skyView.getRaDec()
            aladin?.getRaDec(completionHandler: {
                                ra,dec,err in
                // don't set the position unless needed, it triggers redraw
                if abs(ra - raMap) > 0.0001 || abs(dec - decMap) > 0.0001 {
                    self.aladin?.gotoRaDec(ra: raMap, dec: decMap)
                }
            })
            updateLabels()
            
        }
    }
    
    // the startup sequence:  hide whoIsThatBehindTheScreen,
    //   show the how to get help message
    func startTheShow() {
        if showStarted {
            return
        }
        showStarted = true

        UIView.animate(withDuration: 2, delay: 2, options: [], animations: {self.whoIsThatBehindTheScreen.backgroundColor = UIColor.clear;self.webView.alpha = 1.0}, completion: {_ in

            // assuming that was enough of a delay for aladin to be
            //   available...but look for a way for aladin to call
            //   back when it is ready
            self.aladin?.getSize(completionHandler: {
                w,h,error in
                self.aladinPixelWidth =  Int(w)
                self.aladinPixelHeight = Int(h)
            })
            self.updateLabels()

            UIView.animate(withDuration: 4, delay: 0, options: [], animations: {self.howToGetHelpLabel.alpha = 0.0}, completion: {_ in
            })
        })
    }
    
    @objc
    func tapped(_ recognizer: UIGestureRecognizer) {
        searchCompleteLabel.alpha = 0.0
    }

    var lastTranslation = CGPoint(x: 0,y: 0)
    @objc
    func pan(_ recognizer: UIPanGestureRecognizer) {
        searchCompleteLabel.alpha = 0.0
        updateLabels()
    }

    @objc
    func pinch(_ recognizer: UIPinchGestureRecognizer) {
        searchCompleteLabel.alpha = 0.0
        updateLabels()
    }

//    @objc
//    func swipe(_ recognizer: UISwipeGestureRecognizer) {
//        print("SWIPE!")
//        searchCompleteLabel.alpha = 0.0
//        updateLabels()
//    }

    func updateLabels() {
        func decimalDegreesToLabel(_ d:Double) -> String {
            let (dd,mm,ss) = Convert.decimalDegreesToDMS(d)
            if(dd != 0) {
                return String(format:"%2.0f°",dd)  // rounds off
            }
            else if(mm > 0) {
                return String(format:"%2.0f'",mm)
            }
            else {
                return String(format:"%2.0f\"",ss)
            }
        }

        aladin?.getRaDec(completionHandler: {
            (ra,dec, error) in
       //     print("getRaDec")
            if error == nil {
                // transform goes here
                self.whoIsThatBehindTheScreen.gotoRaDec(ra:ra,dec:dec)
                let (h,m,s) = Convert.decimalDegreesToHMS(ra)
                let (dd,mm,ss) = Convert.decimalDegreesToDMS(dec)
                self.raDecLabel.text = String(format:"%2.0fh%2.0fm%2.0f %2.0f°%2.0f'%2.0f\"",h,m,s,dd,mm,ss)
                
                self.whoIsThatBehindTheScreen.matchAladin(ra:ra,dec:dec, aladin:self.aladin!)
                self.whoIsThatBehindTheScreen.setNeedsDisplay()
            }
            self.aladin?.getFov(completionHandler: {
                (w, h, error) in
                if error == nil {
                    let ws = decimalDegreesToLabel(w)
                //    let hs = decimalDegreesToLabel(h)
                    self.fovLabel.text = "\(ws)"
                    
                    
                }

            })
        })
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // as we leave set the sky map to match this ra,dec
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        aladin?.getRaDec(completionHandler: {
            (ra,dec,err) in
            
            if let appDelegate = self.appDelegate {
                //                self.previousSurvey = appDelegate.settings!.survey
                if let skyView = appDelegate.skyViewVC?.skyView {
                    skyView.gotoRaDec(ra: ra, dec: dec)
                    self.aladin?.getFovCorners(completionHandler: {
                        vals,err in
                        if let corners = vals as? [(ra:Double,dec:Double)] {
                            skyView.setAladinCorners(corners)
                        }
                        skyView.setNeedsDisplay()
                    })
                    skyView.setNeedsDisplay()
                }
            }
        })
    }
    
    // MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        searchCompleteLabel.alpha = 0.0
    }
    
    func searchBarTextDidEndEditing(_ sb:UISearchBar) {
        sb.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ sb:UISearchBar) {
        func doSearch(_ text:String) {
            aladin?.gotoObject(name: text, completionHandler: {
                (ra,dec,error) in
                self.searchCompleteLabel.alpha = 1.0
                if let error = error {
                    // dialog here
                    // needs thought
                    print(error.localizedDescription)
                }
                // there is a bug causing error to be nil all the time
                self.updateLabels()
            })
        }
        sb.resignFirstResponder()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        // extensions to Aladin Lite search strings
        //    ?     help
        //    !     point at zenith
        //    :     macro
        //    0-24  set survey
        //    .     previous survey
        if let text = sb.text {
            let components = text.components(separatedBy: " ")
            
            let cmd = components[0]
            switch(cmd) {
            case "?":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let helpVC = storyboard.instantiateViewController(identifier: "HelpScreen")
                present(helpVC,animated: false,completion: nil)
                break
            case "!":
                gotoTheZenith()
                break
            case ".":
                self.aladin?.setImageSurvey(survey: appDelegate.settings.previousSurvey)
                let swap = appDelegate.settings.survey
                appDelegate.settings.survey = appDelegate.settings.previousSurvey
                appDelegate.settings.previousSurvey = swap
                break
            case "1","2","3","4","5","6","7","8","9",
                 "10","11","12","13","14","15","16","17","18","19",
                 "20","21","22","23","24":
                if components.count > 1 {
                    doSearch(text)
                }
                else if let k = Int(cmd) {
                    switchAladinToSurvey(k-1)
                }
                break
            default:
                if cmd.hasPrefix(":") {
                    let macro = appDelegate.macro
                    macro.process(text)
                }
                else {
                    doSearch(text)
                }
                whoIsThatBehindTheScreen.setNeedsDisplay()
                break
            }
        }
    }

    func searchBarCancelButtonClicked(_ sb:UISearchBar) {
        sb.text = ""
        searchCompleteLabel.alpha = 0.0
        sb.resignFirstResponder()
    }
    
    
    @IBAction func clickOverAladinIcon(_ sender: Any) {
        let alert = UIAlertController(title: "", message:"You are about to leave HelloUniverse to view the Aladin Lite web page in Safari.  Continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: UIAlertAction.Style.destructive) { (action) in
            
            if let url = URL(string:"https://aladin.u-strasbg.fr") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        )
        alert.addAction(UIAlertAction(
            title: "No",
            style: UIAlertAction.Style.destructive) { (action) in
        })
        present(alert, animated: true, completion: nil)
    }
    
    func updateLocation(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        locationChanged()
    }
    
    
    func locationIsNotAvailable() {
        // Boulder Creek, CA
        latitude = 37.1261
        longitude = -122.1222
        locationChanged()
    }
    
    // the user's observation location changed
    func locationChanged() {
        gotoTheZenith()
        startTheShow()
    }
    
    func gotoTheZenith() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // getting the zenith for the initial target
        let z = Astro.zenith(date: Date(), latitude: latitude, longitude: longitude)
//        print("z = \(z)")
        let text = Convert.raDecToIcrs(ra: z.ra, dec: z.dec, underscored: false)
        //       print("icrs = \(text)")
        if aladin == nil {
            appDelegate.initialTarget = text
            appDelegate.initialFOV = 60.0
            aladin = Aladin(webView, target: appDelegate.initialTarget, survey: appDelegate.initialSurvey, fov:appDelegate.initialFOV)
        }
        else {
            aladin?.gotoRaDec(ra: z.ra, dec: z.dec)
        }
    }
    
    func switchAladinToSurvey(_ k:Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let surveys = appDelegate.settings.surveys
        if k >= 0 && k < surveys.count {
            appDelegate.settings.survey = surveys[k].id
            self.aladin?.setImageSurvey(survey: surveys[k].id)
        }
    }
}
