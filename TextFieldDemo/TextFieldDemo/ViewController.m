//
//  ViewController.m
//  TextFieldDemo
//
//  Created by Christian Klaproth on 12.09.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import "ViewController.h"
#import "CkTextField.h"

@interface ViewController () <UITextFieldDelegate, CKTextFieldValidationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *latestEditLabel;
@property (weak, nonatomic) IBOutlet CKTextField *ckTextField;
@property (weak, nonatomic) IBOutlet CKTextField *numericCKTextField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.ckTextField.validationDelegate = self;
    self.numericCKTextField.validationDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.latestEditLabel.text = textField.text;
}

#pragma mark Validation Delegate

- (void)textField:(CKTextField*)aTextField validationResult:(enum CKTextFieldValidationResult)aResult forText:(NSString*)aText
{
    if (aResult == CKTextFieldValidationFailed) {
        [aTextField shake];
    } else if (aResult == CKTextFieldValidationPassed) {
        [aTextField showAcceptButton];
    } else {
        [aTextField hideAcceptButton];
    }
}

@end
