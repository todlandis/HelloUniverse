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
// 3.0

import Foundation
import WebKit

// File info.plist must contain  "App Transport Security Settings":"Allow Arbitrary Loads" = "Yes"  (this hasn't been tested with other settings)
// Also add WebKit.framework to "Link Library With Binaries"
class Aladin {
    
    let webView: WKWebView
    
    var verbose:Bool = false
    
    // this is the startup page which can be any HTML with the
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
      
            </script>
        </body>
    </html>
    """

    init(_ webView:  WKWebView, target:String = "M31", survey:String = "P/DSS2/color", fov:Double = 5.0) {
        self.webView = webView

        // not supported by this version
        //   let url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)
        //       let req = NSURLRequest(url: url as URL)
        // webView.load(req as URLRequest)
        
        let newHTML = defaultPage.replacingOccurrences(of: "TARGET$$$", with: target).replacingOccurrences(of: "SURVEY$$$", with: survey).replacingOccurrences(of: "FOV$$$", with: String(fov))
        webView.loadHTMLString(newHTML, baseURL: nil)
    }

    //HACK
    func testErrorReturn() {
//        webView.evaluateJavaScript(
//            """
//            aladin.gotoObject('verybad 1', {success: function(raDec) { alert("it worked, position is: " + raDec);}, error: function() {alert('object not found');}});
//            """,
//            completionHandler: {
//                (result,err) in
//                if err == nil {
//                    print("NO ERROR???")
//                }
//                else {
//                    print("ERROR received:  \(String(describing: err))")
//                }
//
//        })

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
    
    func getFovCorners(completionHandler: @escaping (Any?, Error?) -> Void) {
        var ret = [(ra:Double,dec:Double)]()
        webView.evaluateJavaScript(
            String(format:"aladin.getFovCorners()"),
            completionHandler: {
                (result,err) in
                if err == nil, let val = result as? [[Double]] {
                    for i in 0 ..< 4 {
                        ret.append((val[i][0],val[i][1]))
                    }
                    
                        completionHandler(ret,nil)
                }
                if(err != nil) {
                    print("ERROR received:  \(String(describing: err))")
                        completionHandler(nil,err)
                }

        })
    }
    
    // https://aladin.u-strasbg.fr/AladinLite/doc/API/
    // returns a ra, dec with the current equatorial coordinates of the Aladin Lite view center.
    func getRaDec(completionHandler: @escaping (Double,Double, Error?) -> Void) {
        webView.evaluateJavaScript(
            String(format:"aladin.getRaDec()"),
            completionHandler: {
                (result,error) in
                if error == nil {
                    if let val = result as? [Double] {
                        completionHandler( val[0],val[1],nil)
                        return
                    }
                }
                completionHandler( 0,0,error)
            })
    }

    // returns an array with the current dimension on the sky (size in X, size in Y) of the view in decimal degrees.
    func getFov(completionHandler:@escaping (Double,Double, Error?) -> Void) {
        webView.evaluateJavaScript(
               String(format:"aladin.getFov()"),
            completionHandler: {
                (result,error) in
                if error == nil {
                    if let val = result as? [Double] {
                        completionHandler( val[0],val[1],nil)
                        return
                    }
                }
                completionHandler( 0,0,error)
            })
    }
    
    func pix2world(x:Int, y:Int, completionHandler: ((Any?, Error?) -> Void)?) {
        // https://aladin.u-strasbg.fr/AladinLite/doc/API/
        webView.evaluateJavaScript(
            String(format:"aladin.pix2world(\(x),\(y))"),
            completionHandler: completionHandler)
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
    
    /*
     <a href="P/DSS2/color" rel="tooltip" title="Toggle Digitized Sky Survey map">Optical</a>&nbsp;
     <a href="P/Mellinger/color" rel="tooltip" title="Toggle Mellinger color map">Mellinger</a>&nbsp;
     <a href="P/GALEXGR6/AIS/color" rel="tooltip" title="Toggle MAST Galex map">GALEX AIS</a>&nbsp;
     <a href="P/DSS2/red" rel="tooltip" title="Toggle Digitized Sky Survey 2 Red map">DSS2 Red</a>&nbsp;
     <a href="P/IRIS/color" rel="tooltip" title="Toggle Improved IRIS Infrared map">IRIS</a>&nbsp;
     <a href="P/2MASS/color" rel="tooltip" title="Toggle 2 Micron All-Sky Survey map">2MASS</a>&nbsp;
     <a data-step="9" data-intro="Now, how about comparing these heatmap with some actual sky images? Click on these surveys to toggle the last loaded heatmap with a base layer." href="P/Finkbeiner" rel="tooltip" title="Toggle Hydrogen Alpha map">Halpha</a>&nbsp;
     <a href="P/VTSS/Ha" rel="tooltip" title="Toggle Virginia Tech Spectral-Line Survey map">VTSS</a>&nbsp;
*/
     
    func setImageSurvey(survey:String) {
        execute(cmd:"aladin.setImageSurvey(\'\(survey)\')")

//      execute(cmd:"aladin.setImageSurvey('P/VTSS/Ha');")
// worked
    }

    func gotoRaDec(ra:Double, dec:Double) {
        execute(cmd:"aladin.gotoRaDec(\(ra), \(dec))")
    }

    
    // set the target, as a position or an object name resolved by Sesame
    // calls the completionHandler with ra,dec of the new position or
    // error
    func gotoObject(name:String, completionHandler: @escaping (Double,Double, Error?) -> Void) {
        webView.evaluateJavaScript(
            "aladin.gotoObject('\(name)')",
            completionHandler: {
                (any,error) in
// print("\(any) \(error)")
// always nil,nil
                if let error = error {
                    print("ERROR received error:  \(error.localizedDescription))")
                    return
                }
                self.getRaDec(completionHandler:completionHandler)
            })
    }
    
    
    func execute(cmd:String) {
        if(verbose) {print("execute:  \(cmd)")}
        webView.evaluateJavaScript(
            //                    String(format:"aladin.gotoObject('m31')"),
            cmd,
            completionHandler: {
            (Any,Error) in
            if(Error != nil) {
                print("ERROR  \(String(describing: Error))")
            }
        })
    }
}
