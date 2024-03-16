//
//  DietViewController.swift
//  WeightLossWonders
//
//  Created by Jason Yu on 3/15/24.
//

import UIKit
import HealthKit

class DietViewController: UIViewController{
    var totalCalories: Int? = 0
    var healthScore: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()
    }
    
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    
    @IBAction func heavyPressed(_ sender: Any) {
        totalCalories!+=500
        setLabel()
    }
    
    @IBAction func normalPressed(_ sender: Any) {
        totalCalories!+=100
        setLabel()
    }
    
    @IBAction func lightPressed(_ sender: Any) {
        totalCalories!+=25
        setLabel()
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        totalCalories=0
        setLabel()
    }
/*
    @IBAction func logPressed(_ sender: Any){
        guard let weight = delegate?.userWeight,
                      let height = delegate?.userHeight,
                      height != 0 else { return }
        
        let BMI = 703 * (weight / (height * height))
        totalCalories = Int(BMI)
        setLabel()
    }
*/
    func setLabel(){
        totalCaloriesLabel.text = String(describing: totalCalories ?? 0)
    }
}
