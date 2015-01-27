//  QuizViewController.swift
//  FlagQuiz
//
import UIKit

class QuizViewController: UIViewController, ModelDelegate {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    
    private var model: Model!
    private let correctColor = UIColor(red:0.0, green: 0.75, blue: 0.0, alpha:1.0)
    private let incorrectColor = UIColor.redColor()
    private var quizCountries: [String]! = nil // countries in quiz
    private var enabledCountries: [String]! = nil // countries for guesses
    private var correctAnswer: String! = nil
    private var correctGuesses = 0
    private var totalGuesses = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create model
        model = Model(delegate: self)
        settingsChanged()
    }
    
    // reconfigure quiz when user changes settings
    func settingsChanged() {
        enabledCountries = model.enabledRegionCountries
        resetQuiz()
    }
    
    // start a new quiz
    func resetQuiz() {
        quizCountries = model.newQuizCountries()
        correctGuesses = 0
        totalGuesses = 0
        
        model.numberOfQuestions = quizCountries.count
        
//        if quizCountries.count < model.numberOfQuestions {
//            model.changeNumberOfQuestions(quizCountries.count)
//        }
        
        // display appropriate number of UISegmentedControls
        for i in 0 ..< segmentedControls.count {
            segmentedControls[i].hidden = (i < model.numberOfGuesses / 2) ? false : true
        }
        nextQuestion()
    }
    
    func nextQuestion() {
        questionNumberLabel.text = String(format: "Question %1d of %2d", (correctGuesses + 1), model.numberOfQuestions)
        answerLabel.text = "<temp>"
        correctAnswer = quizCountries.removeAtIndex(0)
        flagImageView.image = UIImage(named: correctAnswer) // next flag
        
        // re-enable segment controls and delete prior segments
        for segmentedControl in segmentedControls {
            segmentedControl.enabled = true
            segmentedControl.removeAllSegments()
        }
        
        // place guesses on displayed segmented controls
        enabledCountries.shuffle() // use Array extension method
        var i = 0
        
        for segmentedControl in segmentedControls {
            if !segmentedControl.hidden {
                var segmentIndex = 0
                
                while segmentIndex < 2 {
                    if i < enabledCountries.count && correctAnswer != enabledCountries[i] {
                        segmentedControl.insertSegmentWithTitle(countryFromFilename(enabledCountries[i]), atIndex: segmentIndex, animated: false)
                        ++segmentIndex
                    }
                    ++i
                }
            }
        }
        
        // pick random segment and replace with correct answer
        let randomRow = Int(arc4random_uniform(UInt32(model.numberOfGuesses / 2)))
        let randomIndexInRow = Int(arc4random_uniform(UInt32(2)))
        segmentedControls[randomRow].removeSegmentAtIndex(randomIndexInRow, animated: false)
        segmentedControls[randomRow].insertSegmentWithTitle(countryFromFilename(correctAnswer), atIndex: randomIndexInRow, animated: false)
    }
    
    // converts image filename to displayable guess string
    func countryFromFilename(filename: String) -> String {
        var name = filename.componentsSeparatedByString("-")[1]
        let length: Int = countElements(name)
        name = (name as NSString).substringToIndex(length - 4) // remove .png
        let components = name.componentsSeparatedByString("_")
        return join(" ", components)
    }
    
    @IBAction func submitGuess(sender: UISegmentedControl) {
        let guess = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!
        let correct = countryFromFilename(correctAnswer)
        ++totalGuesses
        
        if guess != correct { //incorrect guess
            // disable incorrect guess
            sender.setEnabled(false, forSegmentAtIndex: sender.selectedSegmentIndex)
            answerLabel.textColor = incorrectColor
            answerLabel.text = "Incorrect"
            answerLabel.alpha = 1.0
            UIView.animateWithDuration(1.0, animations: {self.answerLabel.alpha = 0.0})
            shakeFlag()
        
        } else { // correct guess
            answerLabel.textColor = correctColor
            answerLabel.text = guess + "!"
            answerLabel.alpha = 1.0
            ++correctGuesses
            
            // disable segmented controls
            for segmentedControl in segmentedControls {
                segmentedControl.enabled = false
            }
            
            if correctGuesses == model.numberOfQuestions { // quiz over
                displayQuizResults()
            } else { // GCD to show next question after 2 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                    {self.nextQuestion()})
            }
        }
    }
    
    // shakes the flag to visually indicate incorrect response
    func shakeFlag() {
        UIView.animateWithDuration(0.1,
            animations: {self.flagImageView.frame.origin.x += 16})
        UIView.animateWithDuration(0.1, delay: 0.1, options: nil,
            animations: {self.flagImageView.frame.origin.x -= 32},
            completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.2, options: nil,
            animations: {self.flagImageView.frame.origin.x += 32},
            completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.3, options: nil,
            animations: {self.flagImageView.frame.origin.x -= 32},
            completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.4, options: nil,
            animations: {self.flagImageView.frame.origin.x += 16},
            completion: nil)
    }
    
    func displayQuizResults() {
        let percentString = NSNumberFormatter.localizedStringFromNumber(Double(correctGuesses) / Double(totalGuesses), numberStyle: NSNumberFormatterStyle.PercentStyle)
        
        // UIAlertController for user input
        let alertController = UIAlertController(title: "Quiz Results", message: String(format: "%1$i guesses, %2$@ correct", totalGuesses, percentString), preferredStyle: UIAlertControllerStyle.Alert)
        let newQuizAction = UIAlertAction(title: "New Quiz", style: UIAlertActionStyle.Default, handler: {(action) in self.resetQuiz()})
        alertController.addAction(newQuizAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}

    extension Array {
        mutating func shuffle() {
            for first in stride(from: self.count - 1, through: 1, by: -1) {
                let second = Int(arc4random_uniform(UInt32(first + 1)))
                swap(&self[first], &self[second])
            }
        }
    }



