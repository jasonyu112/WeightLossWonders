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
        loadHKstore()
        // add circle progress
        let cp = CircleProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 200.0))
        cp.trackColor = UIColor.gray
        cp.progressColor = UIColor.blue
        cp.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/4)
        cp.tag = 101
        self.view.addSubview(cp)
        // add healthscore
        let score = UILabel()
        score.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/1.9)
        score.textColor = .white
        score.text = "80"
        score.textAlignment = .center
        score.font = UIFont.systemFont(ofSize: 50)
        score.tag = 102
        self.view.addSubview(score)
        createHealthScoreLabel()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 1.0)
        
    }
    @objc func animateProgress(){
        let cP = self.view.viewWithTag(101) as! CircleProgressView
        let scoreLabel = self.view.viewWithTag(102) as! UILabel
        cP.setProgressWithAnimation(duration: 1.0, value: ((scoreLabel.text! as NSString).floatValue/100))
    }
    func loadHKstore(){
        if(HKHealthStore.isHealthDataAvailable()){
            let healthStore = HKHealthStore();
            let typestoRead = Set([HKSampleType.characteristicType(forIdentifier: .biologicalSex)!, HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!, HKSampleType.quantityType(forIdentifier: .height)!, HKSampleType.quantityType(forIdentifier: .bodyMass)!])
            let typestoShare = Set([HKObjectType.workoutType()])
            healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
                if success == false{
                    NSLog("NOT ALLOWED")
                }
            }
            readData(healthStore: healthStore)
        }
        
    }
    func readData(healthStore: HKHealthStore){
        var age: Int?
        var sex: HKBiologicalSex?
        var sexData: String = "Not set"
        
        do{
            let birthday = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
        }catch{}
        
        do{
            let getSex = try healthStore.biologicalSex()
            sex = getSex.biologicalSex
            if let data = sex{
                sexData = self.getReadableBiologicalSex(biologicalSex:data)
            }
        }catch{}
        
        print(sex as Any)
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
    

}
