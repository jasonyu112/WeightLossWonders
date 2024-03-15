//
//  ViewController.swift
//  WeightLossWonders
//
//  Created by Jason Yu on 2/3/24.
//

import UIKit
import HealthKit

protocol DataDelegate: class {
    func sendToExercise(data: String)
}

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    // Sets up all the Text Fields
    @IBOutlet weak var weeklyGoalTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    let weeklyGoalOptions = ["Mild Weight Loss (0.5 lb/week)", "Weight Loss (1 lb/week)", "Extreme Weight Loss (2 lbs/week)"]
    let sexOptions = ["Male", "Female", "Other"]
    
    var weeklyGoalPickerView = UIPickerView()
    var sexPickerView = UIPickerView()
    
    var userWeeklyGoal: String?
    var userSex: String?
    var userAge: Int?
    var userWeight: Double?
    var userHeight: Double?
    var userBMR: Double?
    
    var exerciseDelegate: DataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadHKstore()
        
        // Calculates basal metabolic rate
        calculateBMR()
                
        // Adds circle progress
        addCircleProgress()
        
        // Adds healthscore
        addHealthScore()
        createHealthScoreLabel()
        
        // Animates circle progress
        self.perform(#selector(animateProgress), with: nil, afterDelay: 1.0)
        
        setUserDefaults()
        initializeTextFields()
        
        // Sets delegate for Exercise page
        let parentNav = self.tabBarController?.viewControllers?[1]
        if let nav = parentNav as? UINavigationController {
            if nav.visibleViewController is ExerciseViewController{
                let vc = nav.visibleViewController as? ExerciseViewController
                vc!.loadViewIfNeeded()
                self.exerciseDelegate = vc
            }
        }
        
        sendDataToOtherController()
        
        // Modifies view controller based on keyboard behavior
        configureKeyboard()
    }
    
    
    func addCircleProgress(){
        let cp = CircleProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 200.0))
        cp.trackColor = UIColor.gray
        cp.progressColor = UIColor.blue
        cp.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/4)
        cp.tag = 101
        self.view.addSubview(cp)
    }
    
    func addHealthScore(){
        let score = UILabel()
        score.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/1.9)
        score.textColor = .white
        score.text = "80"
        score.textAlignment = .center
        score.font = UIFont.systemFont(ofSize: 50)
        score.tag = 102
        self.view.addSubview(score)
    }
    
    func createHealthScoreLabel(){
        let cpScore = UILabel()
        cpScore.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/1.2)
        cpScore.text = "Health Score"
        //cpScore.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/4)
        cpScore.textColor = .white
        cpScore.textAlignment = .center
        cpScore.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(cpScore)
    }
    
    @objc func animateProgress(){
        let cP = self.view.viewWithTag(101) as! CircleProgressView
        let scoreLabel = self.view.viewWithTag(102) as! UILabel
        cP.setProgressWithAnimation(duration: 1.0, value: ((scoreLabel.text! as NSString).floatValue/100))
    }
    
    func loadHKstore(){
        if(HKHealthStore.isHealthDataAvailable()){
            let typestoRead = Set([HKSampleType.characteristicType(forIdentifier: .biologicalSex)!, HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!, HKSampleType.quantityType(forIdentifier: .height)!, HKSampleType.quantityType(forIdentifier: .bodyMass)!])
            let typestoShare = Set([HKObjectType.workoutType()])
            healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
                if success == false{
                    NSLog("NOT ALLOWED")
                }
            }
            
            readData()
            readMostRecentSample()
//            print("Age: \(self.userAge)")
//            print("Weight: \(self.userWeight)")
//            print("Height: \(self.userHeight)")
//            print("Gender: \(self.userSex)")
            
        }
    }
    
    func readData(){
        var age: Int?
        var sex: HKBiologicalSex?
        var sexData: String = "Not set"
        
        do{
            let birthday = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            age = currentYear - birthday.year!
        }catch{}
        
        do{
            let getSex = try healthStore.biologicalSex()
            sex = getSex.biologicalSex
            if let data = sex{
                sexData = self.getReadableBiologicalSex(biologicalSex:data)
            }
        }catch{}
        
        self.userAge = age
        self.userSex = sexData
    }
    
    func getReadableBiologicalSex(biologicalSex:HKBiologicalSex?)->String{
        var biologicalSexTest = "Not Retrieved"
        if biologicalSex != nil{
            switch biologicalSex!.rawValue{
            case 0:
                biologicalSexTest = ""
            case 1:
                biologicalSexTest = "Female"
            case 2:
                biologicalSexTest = "Male"
            case 3:
                biologicalSexTest = "Other"
            default:
                biologicalSexTest = ""
            }
        }
        return biologicalSexTest
    }
    
    func readMostRecentSample(){
        let group = DispatchGroup()
        let weightType = HKSampleType.quantityType (forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        
        let queryWeight = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            
            if let result = results?.last as? HKQuantitySample {
//                print("weight => \(result.quantity)")
                self.userWeight = result.quantity.doubleValue(for: HKUnit.pound())
            }
            group.leave()
        }
        
        
        let queryHeight = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            
            if let result = results?.last as? HKQuantitySample {
//                print("height => \(result.quantity)")
                self.userHeight = result.quantity.doubleValue(for: HKUnit.inch())
            }
            group.leave()
        }
        
        group.enter()
        healthStore.execute(queryWeight)
        group.enter()
        healthStore.execute(queryHeight)
        group.wait()
        /**
         *  NOTE: Priority inversion occurs when a high priority thread waits for a resource that a low priority has grabbed.
         * The high priority thread is blocked until the low priority thread releases the resource.
         */
    }
    
    func setUserDefaults(){
        // Checks if there were any values inputted by the user in any of the TextFields before app was restarted
        if let userDefaultWeeklyGoal = UserDefaults.standard.value(forKey: "WeeklyGoal") as? String {
            self.userWeeklyGoal = userDefaultWeeklyGoal
        }
        else {
            self.userWeeklyGoal = weeklyGoalOptions[0]
        }
        if let userDefaultSex = UserDefaults.standard.value(forKey: "Sex") as? String {
            self.userSex = userDefaultSex
        }
        if let userDefaultAge = UserDefaults.standard.value(forKey: "Age") as? Int {
            self.userAge = userDefaultAge
        }
        if let userDefaultWeight = UserDefaults.standard.value(forKey: "Weight") as? Double {
            self.userWeight = userDefaultWeight
        }
        if let userDefaultHeight = UserDefaults.standard.value(forKey: "Height") as? Double {
            self.userHeight = userDefaultHeight
        }
        
        // Sets the default values
        UserDefaults.standard.set(self.userWeeklyGoal, forKey: "WeekGoal")
        UserDefaults.standard.set(self.userSex, forKey: "Sex")
        UserDefaults.standard.set(self.userAge, forKey: "Age")
        UserDefaults.standard.set(self.userWeight, forKey: "Weight")
        UserDefaults.standard.set(self.userHeight, forKey: "Height")
    }
    
    func initializeTextFields(){
        weeklyGoalTextField.inputView = weeklyGoalPickerView
        sexTextField.inputView = sexPickerView
        
        weeklyGoalPickerView.delegate = self
        weeklyGoalPickerView.dataSource = self
        sexPickerView.delegate = self
        sexPickerView.dataSource = self
        
        weeklyGoalPickerView.tag = 1
        sexPickerView.tag = 2
        
        //        let userDefaultWeeklyGoal = UserDefaults.standard.value(forKey: "WeeklyGoal")
        //        let userDefaultSex = UserDefaults.standard.value(forKey: "Sex")
        //        let userDefaultAge = UserDefaults.standard.value(forKey: "Age")
        //        let userDefaultWeight = UserDefaults.standard.value(forKey: "Weight")
        //        let userDefaultHeight = UserDefaults.standard.value(forKey: "Height")
        
        //        print("Default Sex: \(String(describing: userDefaultSex))")
        //        print("Default Age: \(Int(userDefaultAge))")
        //        print("Default Weight: \(Double(userDefaultWeight))")
        //        print("Default Height: \(Double(userDefaultHeight))")
        
        // Sets the default values taken from Healthkit for the Text Fields
        if let userDefaultWeeklyGoal = UserDefaults.standard.value(forKey: "WeeklyGoal") as? String {
            weeklyGoalTextField.text = userDefaultWeeklyGoal
        }
        if let userDefaultSex = UserDefaults.standard.value(forKey: "Sex") as? String {
//            print("Default Sex: \(userDefaultSex)")
            sexTextField.text = userDefaultSex
        }
        if let userDefaultAge = UserDefaults.standard.value(forKey: "Age") as? Int {
//            print("Default Age: \(userDefaultAge)")
            ageTextField.text = String(userDefaultAge)
        }
        if let userDefaultWeight = UserDefaults.standard.value(forKey: "Weight") as? Double {
//            print("Default Weight: \(userDefaultWeight)")
            // Rounds to one decimal place
            weightTextField.text = String(round(userDefaultWeight * 10) / 10.0)
        }
        if let userDefaultHeight = UserDefaults.standard.value(forKey: "Height") as? Double {
//            print("Default Height: \(userDefaultHeight)")
            heightTextField.text = String(userDefaultHeight)
        }
        
        
        if let index = weeklyGoalOptions.firstIndex(where: { $0 == weeklyGoalTextField.text }) {
            weeklyGoalPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        if let index = sexOptions.firstIndex(where: { $0 == sexTextField.text }) {
            sexPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        ageTextField.keyboardType = .asciiCapableNumberPad // numeric keyboard without decimal point
        weightTextField.keyboardType = UIKeyboardType.decimalPad
        heightTextField.keyboardType = UIKeyboardType.decimalPad
    }
    
    func configureKeyboard() {
        // Dismisses keyboard if user taps outside of keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Adjusts view based on keyboard presence (avoids having Text Field(s) be hidden behind keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    // Dismisses keyboard if user taps outside of keyboard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Dismisses keyboard if user presses return/done
    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // Updates default data to hold current value manually inputted in respective Text Field
    @IBAction func textFieldEditingDidEnd(_ textField: UITextField) {
        if textField == weeklyGoalTextField {
            let editedWeeklyGoal = textField.text
            //            print("weeklyGoalTextField: \(editedWeeklyGoal)")
            self.userWeeklyGoal = editedWeeklyGoal
            UserDefaults.standard.set(editedWeeklyGoal, forKey: "WeeklyGoal")
        }
        else if textField == sexTextField {
            let editedSex = sexTextField.text
            //            print("sexTextField: \(editedSex)")
            self.userSex = editedSex
            UserDefaults.standard.set(editedSex, forKey: "Sex")
        }
        else if textField == ageTextField {
            let editedAge = Int(ageTextField.text!)
            //            print("ageTextField: \(editedAge)")
            self.userAge = editedAge
            UserDefaults.standard.set(editedAge, forKey: "Age")
        }
        else if textField == weightTextField {
            let editedWeight = Double(weightTextField.text!)
            //            print("weightTextField: \(editedWeight)")
            self.userWeight = editedWeight
            UserDefaults.standard.set(editedWeight, forKey: "Weight")
        }
        else if textField == heightTextField {
            let editedHeight = Double(heightTextField.text!)
            //            print("heightTextField: \(editedHeight)")
            self.userHeight = editedHeight
            UserDefaults.standard.set(editedHeight, forKey: "Height")
        }
        UserDefaults.standard.synchronize()
        
        // Re-calculates user BMR based on the updated stats of the user
        calculateBMR()
//        print("Updated BMR: \(self.userBMR)")
        
        // Sends updated BMR to Exercise View Controller
        sendDataToOtherController()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    func sendDataToOtherController() {
//        print("DELEGATE: \(self.bmrDelegate)")
        // Sends userWeeklyGoal to Exercise View Controller
        self.exerciseDelegate?.sendToExercise(data: self.userWeeklyGoal!)
    }
    
    func calculateBMR(){
        // Converts weight and height to metric system
        let userWeightMetric = self.userWeight! * 0.45359237
        let userHeightMetric = self.userHeight! * 2.54
        
        // Uses Mifflin-St Jeor Equation to calculate basal metabolic rate (BMR)
        let BMR:Double
        if (self.userSex == "Male") {
            let firstHalfBMR:Double = (10*userWeightMetric) + (6.25*(userHeightMetric))
            let secondHalfBMR:Double = Double((5*self.userAge!) + 5)
            BMR = firstHalfBMR - secondHalfBMR
        }
        else {
            let firstHalfBMR:Double = (10*userWeightMetric) + (6.25*userHeightMetric)
            let secondHalfBMR:Double = Double((5*self.userAge!) - 161)
            BMR = firstHalfBMR - secondHalfBMR
        }
        self.userBMR = BMR
    }
}
