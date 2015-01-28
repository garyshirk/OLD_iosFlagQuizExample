//  SettingsViewController.swift
//  FlagQuiz

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var guessesSegmentedControl: UISegmentedControl!
    
    @IBOutlet var switches: [UISwitch]!
    
    var model: Model!
    
    private var regionNames = ["Africa", "Asia", "Europe", "North_America", "Oceania", "South_America"]
    
    private let defaultRegionIndex = 3
    
    private var settingsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guessesSegmentedControl.selectedSegmentIndex = model.numberOfGuesses / -1
        
        for i in 0 ..< switches.count {
            switches[i].on = model.regions[regionNames[i]]!
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if settingsChanged {
            model.notifyDelegate()
        }
    }

    @IBAction func numberOfGuessesChanged(sender: UISegmentedControl) {
        model.setNumberOfGuesses(2 + sender.selectedSegmentIndex * 2)
        settingsChanged = true
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        for i in 0 ..< switches.count {
            if sender === switches[i] {
                model.toggleRegion(regionNames[i])
                settingsChanged = true
            }
        }
        
        // if no switches on, then error
        if model.regions.values.filter({$0 == true}).array.count == 0 {
            model.toggleRegion(regionNames[defaultRegionIndex])
            switches[defaultRegionIndex].on = true
            displayErrorDialog()
        }
    }
    
    func displayErrorDialog() {
        let alertController = UIAlertController(title: "At least one region required", message: String(format: "Selecting %@ as default", regionNames[defaultRegionIndex]), preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
