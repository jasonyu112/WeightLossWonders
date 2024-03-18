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

    @IBAction func logPressed(_ sender: Any) {
        if (totalCalories ?? 0>2250){
            var tempHealthScore = 100
            var tempx = totalCalories
            while(tempx! > 2250){
                tempHealthScore-=1
                tempx!-=20
            }
            self.healthScore = tempHealthScore
        }
        else{
            var tempHealthScore = 100
            var tempx = totalCalories
            while(tempx! < 2250){
                tempHealthScore-=1
                tempx!+=20
            }
            
            self.healthScore = tempHealthScore
        }
        NotificationCenter.default.post(name: NSNotification.Name("diet"), object: healthScore)
    }
    func setLabel(){
        totalCaloriesLabel.text = String(describing: totalCalories ?? 0)
    }
}
