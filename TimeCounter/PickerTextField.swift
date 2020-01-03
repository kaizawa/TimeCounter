//
//  PickerTextField.swift
//  TimeCounter
//
//  Created by Kazuyoshi Aizawa on 2020/01/02.
//  Copyright © 2020 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit

class PickerTextField: UITextField, UIPickerViewDataSource, UIPickerViewDelegate
{
    var list = [String]()
    var count:Int = 0
    var picker = UIPickerView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setup(count:Int, selectedRow:Int)
    {
        self.count = count

        self.list.reserveCapacity(count)
        for i:Int in 0...count
        {
            list.append(i.description)
        }

        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        picker.selectRow(selectedRow, inComponent:0, animated:true)
        
        let toolbar = UIToolbar(frame: CGRect(x:0, y:0, width:0, height:40))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PickerTextField.cancel))
        toolbar.setItems([cancelItem], animated: true)

        self.inputView = self.picker
        self.inputAccessoryView = toolbar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.endEditing(true)
        self.text = list[row].description
    }
    
    func getValue(_ index:Int) -> String
    {
        return list[index]
    }
    
    func getSelectedIntValue() -> Int
    {
        return Int(getSelectedStringValue())!
    }
    
    func getSelectedStringValue() -> String
    {
        return getValue(self.picker.selectedRow(inComponent: 0))
    }
    
    func cancel()
    {
        self.endEditing(true)
    }
}
