//
//  ExerciseViewController.swift
//  WeightLossWonders
//
//  Created by Iñaki Agustin on 2/25/24.
//

import UIKit

class ExerciseViewController: UIViewController, DataDelegate {
    var userWeeklyGoal: String?
    var userSex: String?
    var userAge: Int?
    var userWeight: Double?
    var userHeight: Double?
    var userBMR: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let profileController = storyboard?.instantiateViewController(identifier: "UserProfile") as? ViewController
//        self.userWeeklyGoal = profileController?.userWeeklyGoal
//        self.userSex = profileController?.userSex
//        self.userAge = profileController?.userAge
//        self.userWeight = profileController?.userWeight
//        self.userHeight = profileController?.userHeight
//        
//        print("(Exercise View) User Weekly Goal: \(self.userWeeklyGoal)")
//        print("(Exercise View) Sex: \(self.userSex)")
//        print("(Exercise View) Age: \(self.userAge)")
//        print("(Exercise View) Weight: \(self.userWeight)")
//        print("(Exercise View) Height: \(self.userHeight)")
        // Should display "Need to enter values for all entry fields before receiving exercise recommendations
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//    }
    
    // Delegate method
    func sendData(data: String) {
        self.userBMR = Double(data)
        print("(Exercise View) User BMR: \(self.userBMR)")
    }
    
    //load number of calories burned from healthkit apo
    
    
    func calculateBMR()->Double{
        //TO DO: convert weight and height to metric system
        
        
        //Uses Mifflin-St Jeor Equation to calculate basal metabolic rate (BMR)
        let BMR:Double
        if (self.userSex == "Male") {
            let firstHalfBMR:Double = (10*self.userWeight!) + (6.25*(self.userHeight!))
            let secondHalfBMR:Double = Double((5*self.userAge!) + 5)
            BMR = firstHalfBMR - secondHalfBMR
        }
        else {
            let firstHalfBMR:Double = (10*self.userWeight!) + (6.25*self.userHeight!)
            let secondHalfBMR:Double = Double((5*self.userAge!) - 161)
            BMR = firstHalfBMR - secondHalfBMR
        }
        return BMR
    }
    
    func calculateNumCaloriesToBurn(weightLossOption:String){
        let BMR:Double = calculateBMR()
        let baseActivityBMR = BMR * 1.2
//        let finalActivityBMR = baseActivityBMR + caloriesBurned
        
    }
}
