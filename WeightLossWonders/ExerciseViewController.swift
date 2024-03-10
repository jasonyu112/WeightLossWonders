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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadHKstore()
        
        // Should display "Need to enter values for all entry fields before receiving exercise recommendations
        getActiveCaloriesBurned()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//    }
    
    // Receives data sent from Profile page
    func sendToExercise(data: String) {
        print("received")
        self.userWeeklyGoal = data
//        print("(Exercise View) User BMR: \(self.userBMR)")
        getActiveCaloriesBurned()
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
//        print("now: \(now)")
//        print("startOfDay: \(startOfDay)")
        
        let queryActiveEnergy = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, results, _) in
            guard let statistics = results else {
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
            case "Maintain Weight":
                self.remainingCaloriesToBurn = 0
            case "Mild Weight Loss (0.5 lb/week)":
                self.remainingCaloriesToBurn = 250
            case "Weight Loss (1 lb/week)":
                self.remainingCaloriesToBurn = 500
            case "Extreme Weight Loss (2 lbs/week)":
                self.remainingCaloriesToBurn = 1000
            default:
                self.remainingCaloriesToBurn = 0
        }
        
        // Uses the sedentary or lightly active factor as as my "base" TDEE
//        let baseTDEE = self.userBMR! * 1.2
        // Adds in the amount of calories you actually burned through exercise
//        let finalActivityBMR = baseActivityBMR + caloriesBurned
    }
    
    func setRemainingCaloriesToBurn() {
        
    }
}
