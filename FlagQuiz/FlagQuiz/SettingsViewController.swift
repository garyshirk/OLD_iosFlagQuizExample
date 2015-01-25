//  SettingsViewController.swift
//  FlagQuiz

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var guessesSegmentedControl: UISegmentedControl!
    
    @IBOutlet var switches: [UISwitch]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func numberOfGuessesChanged(sender: UISegmentedControl) {
        
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        
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
