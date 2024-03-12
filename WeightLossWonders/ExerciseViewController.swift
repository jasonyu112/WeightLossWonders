//
//  ExerciseViewController.swift
//  WeightLossWonders
//
//  Created by Iñaki Agustin on 2/25/24.
//

import UIKit
import HealthKit

class ExerciseViewController: UIViewController, DataDelegate {
    var userWeeklyGoal: String?
    var remainingCaloriesToBurn: Double?
    var activeEnergyBurned: Double?
    
    let healthStore = HKHealthStore()
    
    
    
    
    @IBOutlet weak var remainingCaloriesToBurnLabel: UILabel!
    
//    required init(coder decoder: NSCoder) {
//        print("test")
//        super.init(coder: decoder)!
//        print("test again")
//        
//        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "UserProfile") as? ViewController {
//            destinationVC.exerciseDelegate = self
//            print("im in here")
//        }
//        print("brah")
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "UserProfile") as? ViewController
//        print("PLEASE: \(storyboard)")
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "UserProfile") as? ViewController {
//                destinationVC.exerciseDelegate = self
//                print("im in here: \(destinationVC.exerciseDelegate)")
//        }
//        
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    //    if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "UserProfile") as? ViewController {
//        destinationVC.exerciseDelegate = self
//        print("im in here")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("exercise storyboard: \(storyboard)")
        // Do any additional setup after loading the view.
        loadHKstore()
        
        // Should display "Need to enter values for all entry fields before receiving exercise recommendations
        getActiveCaloriesBurned()
//        setNumCaloriesToBurn()
        
//        print("userWeeklyGoal: \(self.userWeeklyGoal)")
//        print("remainingCaloriesToBurn: \(self.remainingCaloriesToBurn)")
//        setRemainingCaloriesToBurn()
        
//        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "UserProfile") as? ViewController {
////            profileVC.exerciseDelegate = self
//            print("storyboard: \(storyboard)")
//            self.userWeeklyGoal = profileVC.userWeeklyGoal
//            print("here: \(self.userWeeklyGoal)")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getActiveCaloriesBurned()
//        print("userWeeklyGoal: \(self.userWeeklyGoal)")
//        print("remainingCaloriesToBurn: \(self.remainingCaloriesToBurn)")
    }
    
    
    // Receives data sent from Profile page
    func sendToExercise(data: String) {
        print("(Exercise View) User Weekly Goal: \(data)")
        self.userWeeklyGoal = data
        
//        getActiveCaloriesBurned()
        setNumCaloriesToBurn()
    }
    
    func loadHKstore() {
        let allTypes: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceWheelchair),
            HKQuantityType(.heartRate)
        ]
        
        // Checks that Health data is available on the device.
        if HKHealthStore.isHealthDataAvailable() {
            
            // Requests authorization to the data.
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) -> Void in
                if success == false{
                    NSLog("NOT ALLOWED")
                }
            }
        }
    }
    
    
    // Fetches number of active calories currently burned by user from healthkit api
    func getActiveCaloriesBurned() {
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let queryActiveEnergy = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, results, _) in
            guard results == nil else {
                return
            }
            
            if let sum = results!.sumQuantity() {
                self.activeEnergyBurned = sum.doubleValue(for: HKUnit.largeCalorie())
                print("active energy burned: \(self.activeEnergyBurned)")
            }
        }
        healthStore.execute(queryActiveEnergy)
    }
    
    func setNumCaloriesToBurn(){
        switch self.userWeeklyGoal! {
            case "Mild Weight Loss (0.5 lb/week)":
                self.remainingCaloriesToBurn = 250
            case "Weight Loss (1 lb/week)":
                self.remainingCaloriesToBurn = 500
            case "Extreme Weight Loss (2 lbs/week)":
                self.remainingCaloriesToBurn = 1000
            default:
                self.remainingCaloriesToBurn = 0
        }
        
        print("self.userWeeklyGoal: \(self.userWeeklyGoal!)")
        print("self.remainingCaloriesToBurn: \(self.remainingCaloriesToBurn!)")
        
//        self.remainingCaloriesToBurnLabel.text = self.userWeeklyGoal!
        // Uses the sedentary or lightly active factor as as my "base" TDEE
//        let baseTDEE = self.userBMR! * 1.2
        // Adds in the amount of calories you actually burned through exercise
//        let finalActivityBMR = baseActivityBMR + caloriesBurned
    }
    
    func setRemainingCaloriesToBurn() {
        self.remainingCaloriesToBurn = self.remainingCaloriesToBurn! - self.activeEnergyBurned!
        self.remainingCaloriesToBurnLabel.text = String(self.remainingCaloriesToBurn!)
    }
}
