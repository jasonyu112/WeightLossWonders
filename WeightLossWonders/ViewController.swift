//
//  ViewController.swift
//  WeightLossWonders
//
//  Created by Jason Yu on 2/3/24.
//

import UIKit
import HealthKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if(HKHealthStore.isHealthDataAvailable()){
            let healthStore = HKHealthStore();
            let typestoRead = Set([HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!])
            let typestoShare = Set([HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!])
            healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
                if success == false{
                    NSLog("NOT ALLOWED")
                }
            }
            
        }
    }
}

