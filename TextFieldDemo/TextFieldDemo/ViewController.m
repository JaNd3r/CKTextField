//
//  ViewController.m
//  TextFieldDemo
//
//  Created by Christian Klaproth on 12.09.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import "ViewController.h"
#import "CkTextField.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *latestEditLabel;
@property (weak, nonatomic) IBOutlet UITextField *normalTextField;
@property (weak, nonatomic) IBOutlet CKTextField *ckTextField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.latestEditLabel.text = textField.text;
}

@end
