//
//  DataVC.swift
//  HelloUniverse
//
//  Created by Tod Landis on 4/17/22.
//

import Foundation
import UIKit

//struct item {
//    var label:String = ""
//}

class SurveyCell : UITableViewCell {
    var controller:DataVC? = nil

    @IBOutlet weak var surveyLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBAction func tapRight(_ sender: Any) {
        guard let settings = controller?.appDelegate?.settings else {
            print("can't happen")
            return
        }
        settings.currentSurvey = settings.currentSurvey + 1
        if settings.currentSurvey > settings.surveys.count - 1 {
            settings.currentSurvey = settings.surveys.count - 1
        }
        let cur = settings.currentSurvey
        surveyLabel.text = settings.surveys[cur].desc
        typeLabel.text = settings.surveys[cur].type
        
//        settings.survey = settings.surveys[cur].id
        controller?.appDelegate?.initialSurvey = settings.surveys[cur].id
    }
    
    @IBAction func tapLeft(_ sender: Any) {
        guard let settings = controller?.appDelegate?.settings else {
            print("can't happen")
            return
        }
        settings.currentSurvey = settings.currentSurvey - 1
        if settings.currentSurvey < 0 {
            settings.currentSurvey = 0
        }
        let cur = settings.currentSurvey
        surveyLabel.text = settings.surveys[cur].desc
        typeLabel.text = settings.surveys[cur].type
        
//        settings.survey = settings.surveys[cur].id
        controller?.appDelegate?.initialSurvey = settings.surveys[cur].id
    }
}

class SettingCell : UITableViewCell {
    var controller:DataVC? = nil
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBAction func click(_ sender: Any) {
        print("click \(self.tag)")
        
        guard let settings = controller?.appDelegate?.settings else {
            print("can't happen")
            return
        }
        
        if self.tag < settings.list.count {
            let setting = settings.list[self.tag]
            switch(setting.type) {
            case .boolType:
                setting.isOn = !setting.isOn
                break
            }
            print("toggled \(setting.name) to \(setting.isOn)")
        }
    }
}

class DataVC : UITableViewController {
    var appDelegate:AppDelegate? = nil
//    var labels:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
       
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "ALADIN LITE SURVEY"
        default:
            return "SKY MAP"
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        if let appDelegate = appDelegate {
            switch(section) {
            case 0:
                return 1
            default:
//                print("count is \(appDelegate.settings.list.count)")
                return appDelegate.settings.list.count
            }
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60.0
        }
        else {
            return 40.0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .darkGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let appDelegate = appDelegate else {
            print("can't happen")
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "SurveyCell", for: indexPath) as? SurveyCell {
                cell.controller =      self
                let cur = appDelegate.settings.currentSurvey
                cell.surveyLabel.text = appDelegate.settings.surveys[cur].desc
                cell.typeLabel.text = appDelegate.settings.surveys[cur].type
                cell.typeLabel.textColor = .white
                return cell
            }
            else {
                return UITableViewCell()
            }
        }
        else {
            if indexPath.row > appDelegate.settings.list.count {
                print("ERROR row is too big...expect a crash!")
            }
            let item = appDelegate.settings.list[indexPath.row]
            switch(item.type) {
            case .boolType:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingCell else {
                    return UITableViewCell()
                }
                cell.tag = indexPath.row
                cell.controller =      self
                cell.textLabel!.text = item.name
                cell.textLabel?.textColor = .white
                cell.switch.isOn =     item.isOn
                cell.switch.layer.cornerRadius = 16;
                return cell
            }
        }
    }

}
