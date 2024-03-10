//
//  ExerciseViewController.swift
//  WeightLossWonders
//
//  Created by Iñaki Agustin on 2/25/24.
//

import UIKit

class ExerciseViewController: UIViewController, DataDelegate {
    var userBMR: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    //load number of calories burned from healthkit api
    
    
    func calculateNumCaloriesToBurn(weightLossOption:String){
        let baseActivityBMR = self.userBMR! * 1.2
//        let finalActivityBMR = baseActivityBMR + caloriesBurned
    }
}
