//
//  ViewController+Extension.swift
//  WeightLossWonders
//
//  Created by Iñaki Agustin on 3/2/24.
//

import Foundation
import UIKit

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return self.weeklyGoalOptions.count
        case 2:
            return self.sexOptions.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return self.weeklyGoalOptions[row]
        case 2:
            return self.sexOptions[row]
        default:
            return "Data NOT found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            self.weeklyGoalTextField.text = self.weeklyGoalOptions[row]
            self.weeklyGoalTextField.resignFirstResponder()
        case 2:
            self.sexTextField.text = self.sexOptions[row]
            self.sexTextField.resignFirstResponder()
        default:
            return
        }
    }
    
}
