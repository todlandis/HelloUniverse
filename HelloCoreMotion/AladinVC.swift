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
// 2.0

import UIKit
import WebKit

class AladinVC: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var plusView: PlusView!
    @IBOutlet weak var whoIsThatBehindTheScreen: UIView!
    
    @IBOutlet weak var searchCompleteLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var raDecLabel: UILabel!
    
    @IBOutlet weak var fovLabel: UILabel!
    var aladin:Aladin? = nil
    var appDelegate:AppDelegate? = nil
    var latitude:Double = 0.0 {
        didSet {
            // LATER
            // latitude should tilt the view
            // but this hides the Aladin logo
//            webView.transform = CGAffineTransform(rotationAngle: CGFloat(Float(latitude) * Float.pi/180.0));
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
// hack
//        let catalog = BrightStarCatalog()
//        catalog.updateMessierRaDec()
//        print("done")
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.appDelegate = appDelegate
        }

        // this is where we would set the FOV
        whoIsThatBehindTheScreen.alpha = 1.0
        aladin = Aladin(webView)
        
        searchBar.delegate = self
        searchCompleteLabel.alpha = 0.0

        appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let appDelegate = appDelegate {
            appDelegate.aladinVC = self
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 1, delay: 3, options: [], animations: {self.whoIsThatBehindTheScreen.alpha = 0.0}, completion: {_ in
            self.updateLabels()
            
            if let skyViewVC = self.appDelegate?.skyViewVC {
                let (ra,dec) = skyViewVC.skyView.getRaDec()
                self.aladin?.gotoRaDec(ra: ra, dec: dec)
            }
            
            if let settings =  self.appDelegate?.settings {
                self.plusView.alpha = settings.drawPlusSigns ? 1.0 : 0.0
                if let previousSurvey = self.previousSurvey {
                    if previousSurvey != settings.survey {
                        self.aladin?.setImageSurvey(survey: settings.survey)
                    }
                }
                self.previousSurvey = settings.survey
            }

        })
    }
    
    
    @objc
    func tapped(_ recognizer: UIGestureRecognizer) {
     //   print("TAP")
        searchCompleteLabel.alpha = 0.0
    }

    var lastTranslation = CGPoint(x: 0,y: 0)
    @objc
    func pan(_ recognizer: UIPanGestureRecognizer) {
//        print("PAN!")
        searchCompleteLabel.alpha = 0.0
        updateLabels()
    }

    func updateLabels() {
        aladin?.getRaDec(completionHandler: {
            (ra,dec, error) in
            if error == nil {
                let (h,m,s) = Convert.decimalDegreesToHMS(ra)
                let (dd,mm,ss) = Convert.decimalDegreesToDMS(dec)
                self.raDecLabel.text = String(format:"%2.0fh%2.0fm%2.0f %2.0f°%2.0f'%2.0f\"",h,m,s,dd,mm,ss)
            }
        })
        aladin?.getFov(completionHandler: {
            (w, h, error) in
            if error == nil {
                let (dd,mm,ss) = Convert.decimalDegreesToDMS(w)
                var s:String
                if(dd != 0) {
                    s = String(format:"%2.0f°",w)  // rounds off
                }
                else if(mm > 0) {
                    s = String(format:"%2.0f'",mm)
                }
                else {
                    s = String(format:"%2.0f\"",ss)
                }
                self.fovLabel.text = s
            }
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

    var previousSurvey:String? = nil
    // as we leave set the sky map to match this ra,dec
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        aladin?.getRaDec(completionHandler: {
            (ra,dec,err) in
            
            if let appDelegate = self.appDelegate {
                self.previousSurvey = appDelegate.settings!.survey
                if let skyView = appDelegate.skyViewVC?.skyView {
                    skyView.gotoRaDec(ra: ra, dec: dec)
                    skyView.aladinPlus = (ra:ra,dec:dec)
                    skyView.latAngle = self.latitude
                    self.aladin?.getFovCorners(completionHandler: {
                        vals,err in
                        if let corners = vals as? [(ra:Double,dec:Double)] {
//                            print("leaving aladinVC upper left corner \(corners[0])")
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
        sb.resignFirstResponder()
        if let text = sb.text {
            aladin?.gotoObject(name: text, completionHandler: {
                (ra,dec,error) in
                self.searchCompleteLabel.alpha = 1.0
                if let error = error {
                    // dialog here
                    // needs thought
                    print(error.localizedDescription)
                }
            })
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
}
