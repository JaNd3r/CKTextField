//
//  CKTextField.h
//  CKTextField
//
//  Created by Christian Klaproth on 12.09.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKTextField;

enum CKTextFieldValidationResult {
    CKTextFieldValidationUnknown,
    CKTextFieldValidationPassed,
    CKTextFieldValidationFailed
};

/**
 * Adds optional methods that are sent to the UITextFieldDelegate.
 */
@protocol CKTextFieldValidationDelegate <NSObject>

@optional

- (void)textField:(CKTextField*)aTextField validationResult:(enum CKTextFieldValidationResult)aResult forText:(NSString*)aText;

@end

@interface CKTextField : UITextField

//
// User Defined Runtime Attributes (--> Storyboard!)
//
// *******************************************************
//                                                       *
//                                                       *

@property (nonatomic) NSString* validationType;
@property (nonatomic) NSString* minLength;
@property (nonatomic) NSString* maxLength;
@property (nonatomic) NSString* minValue;
@property (nonatomic) NSString* maxValue;

//                                                       *
//                                                       *
// *******************************************************

@property (nonatomic, weak) id<CKTextFieldValidationDelegate> validationDelegate;

- (void)shake;
- (void)showAcceptButton;
- (void)hideAcceptButton;

@end
