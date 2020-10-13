//
//  HelpVC.swift
//  HelloUniverse
//
//  Created by Tod Landis on 10/20/20.
//

import UIKit

class HelpVC: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel.text =
        """
        The Aladin Lite tab is a virtual telescope.  It shows the sky directly above you when the app starts.

        Move the scope using pan gestures and zoom in or out with pinch gestures.

        Target specific objects by entering their names or coordinates.  Try zooming in on "IC 239", "NGC 2626", "Baade's Window", and "M3".

        The Sky Map tab is a map of the constellations matching the telesope view.  Move the map around and the telescope will follow.  The orange dots on the map are  Messier objects.

        Enter "!" in the search box to point the telescope and sky map straight up again.  Back where you started.

        Enter "?" to see this Help screen.
        """
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func clickDone(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
