//
//  Aladin.swift
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

import Foundation
import WebKit

// File info.plist must contain  "App Transport Security Settings":"Allow Arbitrary Loads" = "Yes"  (this hasn't been tested with other settings)
// Also add WebKit.framework to "Link Library With Binaries"
class Aladin {
    
    let webView: WKWebView
    
    var verbose:Bool = false
    
    var currentSurvey:String  // this will go away when I can do aladin.getImageSurvey()
    
    // This is the startup page which can be any HTML with the
    // Aladin snippet in it.  This version adds 'markerlayer' which is
    // a start on annotations, but not surfaced yet.
    //
    let defaultPage =
    """
    <!DOCTYPE html>
    <html>
        <head>
        </head>
        <body style="background-color:#000000;">
            <!-- include Aladin Lite CSS file in the head section of your page -->
            <link rel="stylesheet" href="https://aladin.u-strasbg.fr/AladinLite/api/v2/latest/aladin.min.css" />
             
            <!-- you can skip the following line if your page already integrates the jQuery library -->
            <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.1.min.js" charset="utf-8"></script>
             
            <!-- insert this snippet where you want Aladin Lite viewer to appear and after the loading of jQuery -->
            <div id="aladin-lite-div" style="width:400px;height:400px;"></div>
            <script type="text/javascript" src="https://aladin.u-strasbg.fr/AladinLite/api/v2/latest/aladin.min.js" charset="utf-8"></script>
            <script type="text/javascript">
                console.log('loading aladin');
        
                var aladin = A.aladin('#aladin-lite-div', {
                                      survey: 'SURVEY$$$',
                                      fov:FOV$$$,
                                      fullScreen:true,
                                      showZoomControl:false,
                                      showFullscreenControl:false,
                                      showLayersControl:false,
                                      showReticle:false,
                                      showFrame:false,
                                      showGotoControl:false,
                                      showShareControl:false,
                                    target: 'TARGET$$$', // initial target
                                                                            });
            document.documentElement.style.webkitUserSelect='none';

            var markerLayer = A.catalog();
            aladin.addCatalog(markerLayer);
    
                  function gotoObjectWithPromise(val) {
                      return new Promise(function(resolve, reject) {
                          aladin.gotoObject(val, {success: function(raDec) {resolve(raDec);}, error: function(error) {reject(error);} });
                      });
                      }

                  function gotoRaDecWithPromise(ra,dec) {
                      return new Promise(function(resolve, reject) {
            +              aladin.gotoRaDec(ra,dec, {success: function(raDec) {resolve(raDec);}, error: function(error) {reject(error);} });
                      });
                      }

            </script>
        </body>
    </html>
    """

    init(_ webView:  WKWebView, target:String = "M31", survey:String = "P/DSS2/color", fov:Double = 5.0) {
        self.webView = webView

        // webView could be loaded from a local file or web URL, e.g.
        //   let url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)
        //       let req = NSURLRequest(url: url as URL)
        // webView.load(req as URLRequest)
        
        let newHTML = defaultPage.replacingOccurrences(of: "TARGET$$$", with: target).replacingOccurrences(of: "SURVEY$$$", with: survey).replacingOccurrences(of: "FOV$$$", with: String(fov))
        currentSurvey = survey
        webView.loadHTMLString(newHTML, baseURL: nil)
    }

    
    func getFovCorners(completionHandler: @escaping (Any?, Error?) -> Void) {
        var ret = [(ra:Double,dec:Double)]()
        webView.evaluateJavaScript("aladin.getFovCorners()") {
            result,err in
            if err == nil, let val = result as? [[Double]] {
                for i in 0 ..< 4 {
                    ret.append((val[i][0],val[i][1]))
                }
                completionHandler(ret,nil)
            }
            else {
                completionHandler(nil,err)
            }
        }
    }
    
    // https://aladin.u-strasbg.fr/AladinLite/doc/API/
    // returns a ra, dec with the current equatorial coordinates of the Aladin Lite view center.
    func getRaDec(completionHandler: @escaping (Double,Double, Error?) -> Void) {
        webView.evaluateJavaScript("aladin.getRaDec()") {
            result,error in
            if error == nil {
                if let val = result as? [Double] {
                    completionHandler( val[0],val[1],nil)
                    return
                }
            }
            else {
                completionHandler( 0,0,error)
            }
        }
    }

    // returns an array with the current dimension on the sky (size in X, size in Y) of the view in decimal degrees
    func getFov(completionHandler:@escaping (Double,Double, Error?) -> Void) {
        webView.evaluateJavaScript("aladin.getFov()") {
            result,error in
            if error == nil {
                if let val = result as? [Double] {
                    completionHandler( val[0],val[1],nil)
                    return
                }
            }
            else {
                completionHandler( 0,0,error)
            }
        }
    }
    
    // get width and height in pixels
    func getSize(completionHandler:@escaping (Double,Double, Error?) -> Void) {
        webView.evaluateJavaScript("aladin.getSize()") {
            result,error in
            if error == nil {
                if let val = result as? [Double] {
                    completionHandler( val[0],val[1],nil)
                    return
                }
            }
            else {
                completionHandler( 0, 0,error)
            }
        }
    }

    // completionHandler changed 10/29/2020
    func pix2world(x:Int, y:Int, completionHandler: @escaping (Double,Double, Error?) -> Void) {
        // https://aladin.u-strasbg.fr/AladinLite/doc/API/
        webView.evaluateJavaScript(String(format:"aladin.pix2world(\(x),\(y))")){
            result,error in
            if error == nil {
                if let val = result as? [Double] {
                    // hack
                    print(val)
                    completionHandler( val[0],val[1],nil)
                    return
                }
            }
            else {
                completionHandler( 0, 0,error)
            }
        }
    }

    // trying callAsyncJavaScript
    @available(iOS 14.0, *)
    func world2pix(ra:Double, dec:Double, completionHandler: @escaping (Double,Double, Error?) -> Void) {
        let world2pixJavaScript = """
            aladin.world2pix(\(ra),\(dec))
        """
        webView.callAsyncJavaScript(world2pixJavaScript,
                                    arguments: [
                                        "ra":String(ra),
                                        "dec":String(dec)
                                    ],
                                    in:.none,
                                    in: .defaultClient,
                                    completionHandler: {
                                        result in
                                        switch(result) {
                                        case .success(let results):
                                            if let vals = results as? [Double] {
                                                print((vals as [Double]).count)
                                                completionHandler( vals[0],vals[1], nil)
                                            }
                                            break
                                        case .failure(let error):
                                            completionHandler( 0, 0,error)
                                        }
                                    })
    }
    
    func world2pixOLD(ra:Double, dec:Double, completionHandler: @escaping (Double,Double, Error?) -> Void) {
        // https://aladin.u-strasbg.fr/AladinLite/doc/API/
        webView.evaluateJavaScript(String(format:"aladin.world2pix(\(ra),\(dec))")) {
            (result,error) in
            if error == nil {
                if let val = result as? [Double] {
                    completionHandler( val[0],val[1], nil)
                    return
                }
            }
            else {
                completionHandler( 0, 0,error)
            }
        }
    }

    // requires markerlayer on the default page
    /*
     https://aladin.u-strasbg.fr/AladinLite/doc/tutorials/interactive-finding-chart/
     */
    func addMarker(ra:Double, dec:Double, title:String) {
        execute(cmd:"""
        var marker1 = A.marker(\(ra),\(dec), {popupTitle: '\(title)', popupDesc: 'Object type: Pulsar'});
        markerLayer.addSources([marker1]);
        """)
    }

    //  https://aladin.u-strasbg.fr/AladinLite/doc/API/
    func addRectangle(ra:Double, dec:Double, degrees:Double) {
        execute(cmd:"""
            var overlay = A.graphicOverlay({color: '#FFFFFF', lineWidth: 3});
            aladin.addOverlay(overlay);
            
            overlay.add(A.circle(\(ra), \(dec), \(degrees), {color: '#FF0000'})); // radius in degrees
            """)

    }

    // draw a box with center (ra,dec), width 'w', and height 'h'
    func addBox(ra:Double,dec:Double,w:Double,h:Double) {
        var points = [(ra:Double,dec:Double)]()
        let w2 = w/2.0
        let h2 = h/2.0
        
        points.append((ra:ra-w2,dec:dec-h2))
        points.append((ra:ra-w2,dec:dec+h2))
        points.append((ra:ra+w2,dec:dec+h2))
        points.append((ra:ra+w2,dec:dec-h2))
        points.append((ra:ra-w2,dec:dec-h2))
        addPolyline(points: points)
    }
    
    func addPolyline(points:[(ra:Double,dec:Double)]) {
        var s = "overlay.add(A.polyline(["
        for i in 0..<points.count {
            s = s.appending("[\(points[i].ra),\(points[i].dec)]")
            s = s.appending(",")
        }
        s = s.appending("]));")
        
        execute(cmd:"""
            var overlay = A.graphicOverlay({color: '#FF0000', lineWidth: 3});
            aladin.addOverlay(overlay);
            
            \(s)
        """)
    }
    
    func addCircle(ra:Double, dec:Double, degrees:Double) {
        execute(cmd:"""
        var overlay = A.graphicOverlay({color: '#FFFFFF', lineWidth: 3});
        aladin.addOverlay(overlay);

        overlay.add(A.circle(\(ra), \(dec), \(degrees), {color: '#FF0000'})); // radius in degrees
        """)
    }
    
    func setFov(_ fov:Double) {
        execute(cmd:"aladin.setFov(\(fov))")
    }

    func setFovRange(minFov:Double,maxFov:Double) {
        execute(cmd:"aladin.setFovRange(\(minFov), \(maxFov))")
    }
    
    func addCatalog() {
        execute(cmd:"""
        var cat = A.catalog({sourceSize: 20,displayLabel: true, labelColumn: 'name'});
        aladin.addCatalog(cat);
        cat.addSources([A.source(0.0, 0.0, {name: 'Hello!'})])
        """)
    }
    
    func getImageSurvey() -> String {
        return currentSurvey  // LATER make aladin the source of truth
    }
    
    func setImageSurvey(survey:String) {
        currentSurvey = survey
        execute(cmd:"aladin.setImageSurvey(\'\(survey)\')")
    }

    func gotoRaDec(ra:Double, dec:Double, completionHandler:  @escaping (Error?) -> Void)  {
        if #available(iOS 14.0, *) {
            gotoRaDecWithPromise(ra:ra, dec:dec, completionHandler:   completionHandler)
        }
        else {
            execute(cmd:"aladin.gotoRaDec(\(ra), \(dec))")
            completionHandler(nil) // never returns an error
        }
    }

    @available(iOS 14.0, *)
    func gotoRaDecWithPromise(ra:Double, dec:Double, completionHandler:  @escaping (Error?) -> Void)  {
        
        webView.callAsyncJavaScript("""
                return gotoRaDecWithPromise(ra,dec);
              """,
            arguments: [
                "ra":ra,
                "dec":dec
            ],
            in:.none,
            in: .page,
            completionHandler: {
                result in
                switch(result) {
                case .success:
                    completionHandler(nil)
                    break
                case .failure(let error):
                    completionHandler(error)
                    break
                }
            })
    }

    // showing a bug, see "uncomment this line" below
    func testErrorReturn() {

        // this prints error received
        webView.evaluateJavaScript(
            """
            aladin.gotoObject('verybad 1');
            """,
            completionHandler: {
                (result,err) in
                if err == nil {
                    print("NO ERROR???")
                }
                else {
                    print("ERROR received")
                }
        })
        
        // and so does this
        gotoObject(name:"verybad 1", completionHandler:{  (ra,dec, err) in
            if err == nil {
                print("NO ERROR???")
            }
            else {
                print("ERROR received")
            }
        })
    }

    
    // set the target, as a position or an object name resolved by Sesame
    // calls the completionHandler with ra,dec of the new position or
    // error
    func gotoObject(name:String, completionHandler: @escaping (Double,Double, Error?) -> Void) {
        if #available(iOS 14.0, *) {
            gotoObjectWithPromise(name:name, completionHandler:   completionHandler)
        }
        else {
            webView.evaluateJavaScript("aladin.gotoObject('\(name)')") {
                (any,error) in
                if let error = error {
                    print("ERROR received error:  \(error.localizedDescription))")
                    return
                }
                self.getRaDec(completionHandler:completionHandler)
            }
        }
    }

    @available(iOS 14.0, *)
    func gotoObjectWithPromise(name:String, completionHandler:  @escaping (Double,Double, Error?) -> Void) {
        webView.callAsyncJavaScript("""
                return gotoObjectWithPromise(name);
              """,
            arguments: [
                "name":name,
            ],
            in:.none,
            in: .page,
            completionHandler: {
                result in
                switch(result) {
                case .success(let results):
//                    print("gotoObjectWithPromise reports success")
                    if let vals = results as? [Double] {
                        completionHandler( vals[0],vals[1],nil)
                    }
                    break
                case .failure(let error):
//                    print("gotoObjectWithPromise reports failure")
                    completionHandler(0,0,error)
                    break
                }
            })
    }

//    // this shows a problem with iOS 14.0
//    //   rename this to gotoObject() and rename gotoObject() to something else
//    //   you will see a message on the console complaining about  a system bug
//    @available(iOS 14.0, *)
//    func gotoObjectX(object:String, completionHandler: @escaping (Error?) -> Void) {
//        let gotoJavaScript = "aladin.gotoObject(name)"
//        webView.callAsyncJavaScript(gotoJavaScript,
//                                    arguments: [
//                                        "name":object,
//                                    ],
//                                    in:.none,
//                                    in: .page,
//                                    completionHandler: {
//                                        result in
//                                        switch(result) {
//                                        case .success:
//                                            print("SUCCESS!")
//                                            completionHandler(nil)
//                                            break
//                                        case .failure(let error):
//                                            print("ERROR!")
//                                            print(error)
//                                            completionHandler(error)
//                                        }
//                                    })
//    }
    
    //https://aladin.u-strasbg.fr/AladinLite/doc/API/
    //aladin.createImageSurvey(<HiPS-ID>, <HiPS-name>, <HiPS-base-URL>, <HiPS frame ('equatorial' or 'galactic', usually 'equatorial')>, <HiPS max order>, {imgFormat: <tiles format ('jpg' or 'png')>}));
    func customImageSurvey() {
        execute(cmd:"""
            aladin.setImageSurvey(aladin.createImageSurvey("ISOPHOT", "ISOPHOT / ADASS tutorial", "http://0.0.0.0/TutorialHips", "equatorial", 10, {imgFormat: 'png'}));
            """)
    }
    
    func execute(cmd:String) {
        if(verbose) {print("execute:  \(cmd)")}
        webView.evaluateJavaScript(cmd) {
            (Any,Error) in
            if(Error != nil) {
                print("ERROR  \(String(describing: Error))")
            }
        }
    }
}
