//
//  ViewController.swift
//  TextFieldSwiftDemo
//
//  Created by Rainer Drexler on 25.03.16.
//  Copyright © 2016 Rainer Drexler. All rights reserved.
//

import UIKit


class ViewController: UIViewController ,UITextFieldDelegate, CKTextFieldValidationDelegate {
    
    @IBOutlet var uITextField: UITextField!
    @IBOutlet var cKTextField: CKTextField!
    @IBOutlet var lastestEditLabel: UILabel!
    @IBOutlet var numericCkTextField: CKTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.cKTextField.validationDelegate = self;
        self.numericCkTextField.validationDelegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidEndEditing(textField: UITextField) {
        self.lastestEditLabel.text = textField.text;
    }
    
    func textField(aTextField: CKTextField!, validationResult aResult: CKTextFieldValidationResult, forText aText: String!) {

        switch aResult {
        case CKTextFieldValidationFailed:
            aTextField.shake()
        case CKTextFieldValidationPassed:
            aTextField.showAcceptButton()
        default:
            aTextField.hideAcceptButton()
        }
    }
    
    

}

