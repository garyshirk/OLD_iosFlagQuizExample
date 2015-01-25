//  QuizViewController.swift
//  FlagQuiz
//
import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var flagImageView: UIImageView!
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet var segmentedControls: [UISegmentedControl]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func submitGuess(sender: AnyObject) {
        
    }


}

