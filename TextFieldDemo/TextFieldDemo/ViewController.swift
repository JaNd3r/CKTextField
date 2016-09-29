//
//  ViewController.swift
//  TextFieldDemo
//
//  Created by Christian Klaproth on 29.09.16.
//  Copyright © 2016 Christian Klaproth. All rights reserved.
//

import UIKit
import CKTextField

class ViewController: UIViewController, CKTextFieldValidationDelegate {

    @IBOutlet weak var demoTextField: CKTextField!
    @IBOutlet weak var integerTextField: CKTextField!
    @IBOutlet weak var latestEditLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.demoTextField.validationDelegate = self
        self.integerTextField.validationDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func demoTextFieldEditingDidEnd(_ sender: CKTextField) {
        self.latestEditLabel.text = sender.text
    }

    // MARK: - Validation Delegate
    
    func textField(_ aTextField: CKTextField!, validationResult aResult: CKTextFieldValidationResult, forText aText: String!) {
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

