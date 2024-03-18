//
//  SleepViewController.swift
//  WeightLossWonders
//
//  Created by Jason Yu on 3/15/24.
//

import UIKit
import HealthKit

class SleepViewController: UIViewController{
    var startTime: Date?
    var endTime: Date?
    var totalHours = 0
    var healthScore = 0
    
    @IBAction func startTimeChanged(_ sender: UIDatePicker) {
        endTime = sender.date
    }
    @IBAction func endTimeChanged(_ sender: UIDatePicker) {
        startTime = sender.date
    }
    
    @IBAction func updateHealthScore(_ sender: Any) {
        // Ensure both start time and end time are set
        guard let startTime = startTime, let endTime = endTime else {
            print("Start time or end time is not set.")
            return
        }
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        // Convert start time and end time to military time
        let endTimeString = dateFormatter.string(from: startTime)
        let startTimeString = dateFormatter.string(from: endTime)
        
        // Parse military time strings to Date objects
        guard let militaryStartTime = dateFormatter.date(from: startTimeString),
              let militaryEndTime = dateFormatter.date(from: endTimeString) else {

            return
        }
        
        // Check if the end time is before the start time (indicating sleep crossing midnight)
        var adjustedEndTime = militaryEndTime
        if militaryEndTime < militaryStartTime {
            adjustedEndTime = calendar.date(byAdding: .day, value: 1, to: militaryEndTime)!
        }
        
        // Calculate total time slept in minutes
        let components = calendar.dateComponents([.minute], from: militaryStartTime, to: adjustedEndTime)
        guard let totalMinutes = components.minute else {

            return
        }
        
        // Calculate total hours slept
        totalHours = totalMinutes / 60
        
        // Calculate health score based on total hours
        healthScore = calculateHealthScore(hours: totalHours)
        NotificationCenter.default.post(name: NSNotification.Name("sleep"), object: healthScore)
    }
    
    func calculateHealthScore(hours: Int) -> Int {
         if hours > 7 {
             return 100
         } else if hours > 6 {
             return 80
         } else {
             return 60
         }
    }
}

