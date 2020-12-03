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
           Search for deep sky objects by name:
               "NGC 2626",     "Baade's Window", "M3"

            Coordinates work too:
               "38.0 -10.0", "13 14 54.213 +33 10 6.136"

            Shortcuts:
               !    show your zenith

               1    Visible Light   (DSS)
               2    Near Infrared   (2MASS)
               3    Mid Infrared    (AllWISE)

               .    Swap surveys

            See Settings for more surveys.
        """
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
