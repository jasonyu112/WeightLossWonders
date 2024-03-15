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
    var initialCaloriesToBurn: Double?
    var remainingCaloriesToBurn: Double?
    var activeEnergyBurned: Double?
    
    let healthStore = HKHealthStore()
    
    @IBOutlet weak var remainingCaloriesToBurnLabel: UILabel!
    @IBOutlet weak var walkCaloriesToBurnLabel: UILabel!
    @IBOutlet weak var runCaloriesToBurnLabel: UILabel!
    @IBOutlet weak var strengthTrainingCaloriesToBurnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadHKstore()
        
        // Should display "Need to enter values for all entry fields before receiving exercise recommendations?
        getActiveCaloriesBurned()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getActiveCaloriesBurned()
        setRemainingCaloriesToBurn()
        setExerciseCaloriesToBurn()
    }
    
    
    // Receives data sent from Profile page
    func sendToExercise(data: String) {
//        print("(Exercise View) User Weekly Goal: \(data)")
        self.userWeeklyGoal = data
        
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
            guard results != nil else {
                return
            }
            if let sum = results!.sumQuantity() {
                self.activeEnergyBurned = sum.doubleValue(for: HKUnit.largeCalorie())
//                print("active energy burned: \(self.activeEnergyBurned)")
            }
        }
        healthStore.execute(queryActiveEnergy)
    }
    
    func setNumCaloriesToBurn(){
        switch self.userWeeklyGoal! {
            case "Mild Weight Loss (0.5 lb/week)":
                self.initialCaloriesToBurn = 250
            case "Weight Loss (1 lb/week)":
                self.initialCaloriesToBurn = 500
            case "Extreme Weight Loss (2 lbs/week)":
                self.initialCaloriesToBurn = 1000
            default:
                self.initialCaloriesToBurn = 0
        }
        
//        print("self.userWeeklyGoal: \(self.userWeeklyGoal!)")
//        print("self.initialCaloriesToBurn: \(self.initialCaloriesToBurn!)")
    }
    
    func setRemainingCaloriesToBurn() {
        self.remainingCaloriesToBurn = self.initialCaloriesToBurn! - self.activeEnergyBurned!
        if (self.remainingCaloriesToBurn! < 0) {
            self.remainingCaloriesToBurn = 0
        }
//        print("Remaining Calories To Burn: \(String(self.remainingCaloriesToBurn!))")
        self.remainingCaloriesToBurnLabel.text = String(roundUp(precision: 1, value: self.remainingCaloriesToBurn!))
    }
    
    func setExerciseCaloriesToBurn() {
        self.walkCaloriesToBurnLabel.text = String(roundUp(precision: 1,value: self.remainingCaloriesToBurn!/4.5)) // walking at brisk pace equals 3.5 calories per minute
        self.runCaloriesToBurnLabel.text = String(roundUp(precision: 1,value: self.remainingCaloriesToBurn!/11.1)) // running equals 13.2 calories per minute (happy medium factor that disregards weight)
        self.strengthTrainingCaloriesToBurnLabel.text = String(roundUp(precision: 1,value: self.remainingCaloriesToBurn!/6.1)) // strength training equals 6.1 calories per minute
    }
    
    func roundUp(precision: Int, value: Double) -> Double {
        let factor: Double = Double(precision * 10)
        let roundedUpValue = Double(round(Double(factor) * value)/factor)
        return roundedUpValue
    }
}
