//  Model.swift
//  FlagQuiz
//
import Foundation

protocol ModelDelegate {
    func settingsChanged()
}

class Model {

    // keys for storing date in NSUserDefaults
    private let regionsKey = "FlagQuizKeyRegions"
    private let guessesKey = "FlagQuizGuesses"
    
    // delegate reference
    private var delegate: ModelDelegate! = nil
    
    var numberOfGuesses = 4
    
    private var enabledRegions = [
        "Africa" : false,
        "Asia" : false,
        "Europe" : false,
        "North_America" : false,
        "Oceania" : true,
        "South_America" : false
    ]
    
    var numberOfQuestions = 10
    private var allCountries: [String] = []
    private var countriesInEnabledRegions: [String] = []
    
    init(delegate: ModelDelegate) {
        
        self.delegate = delegate
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let tempGuesses = userDefaults.integerForKey(guessesKey)
        if tempGuesses != 0 {
            numberOfGuesses = tempGuesses
        }
        
        if let tempRegions = userDefaults.dictionaryForKey(regionsKey) {
            self.enabledRegions = tempRegions as [String : Bool]
        }
        
        let paths = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: nil) as [String]
        for path in paths {
            if !path.lastPathComponent.hasPrefix("AppIcon") {
                allCountries.append(path.lastPathComponent)
            }
        }
        
        regionsChanged()
    }
    
    func regionsChanged() {
        
        countriesInEnabledRegions.removeAll()
        
        for filename in allCountries {
            let region = filename.componentsSeparatedByString("-")[0]
        
            if (enabledRegions[region]!) {
                countriesInEnabledRegions.append(filename)
            }
        }
    }
    
    var regions: [String : Bool] {
        return enabledRegions
    }
    
    var enabledRegionCountries: [String] {
        return countriesInEnabledRegions
    }
    
    func changeNumberOfQuestions(number: Int) {
        numberOfQuestions = number
    }
    
    func toggleRegion(name: String) {
        enabledRegions[name] = !(enabledRegions[name]!)
        NSUserDefaults.standardUserDefaults().setObject(enabledRegions as NSDictionary, forKey: regionsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        regionsChanged()
    }
    
    func setNumberOfGuesses(guesses: Int) {
        numberOfGuesses = guesses
        NSUserDefaults.standardUserDefaults().setInteger(numberOfGuesses, forKey: guessesKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func notifyDelegate() {
        delegate.settingsChanged()
    }
    
    func newQuizCountries() -> [String] {
        var quizCountries: [String] = []
        
        var flagCounter = 0
        
        // add 10 random filenames (countries) to quizCountries
        while flagCounter < numberOfQuestions {
            let randomIndex = Int(arc4random_uniform(UInt32(enabledRegionCountries.count)))
            let filename = enabledRegionCountries[randomIndex]
            
            // if image's filename is not in quizCountries, add it
            if quizCountries.filter({$0 == filename}).count == 0 {
                quizCountries.append(filename)
                ++flagCounter
            }
        }
        return quizCountries
    }
}
