//
//  CKExternalKeyboardSupportedTextField.h
//  CKTextField
//
//  Created by Christian Klaproth on 04.01.15.
//  Copyright (c) 2015 Christian Klaproth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKExternalKeyboardSupportedTextField;

@protocol CKExternalKeyboardSupportedTextFieldDelegate <NSObject>

@optional

- (void)escPressedInTextField:(CKExternalKeyboardSupportedTextField*)textField;
- (void)enterPressedInTextField:(CKExternalKeyboardSupportedTextField*)textField;

@end

@interface CKExternalKeyboardSupportedTextField : UITextField

@property (nonatomic, weak) id<CKExternalKeyboardSupportedTextFieldDelegate> keyboardDelegate;

- (void)internalEscPressed;
- (void)internalEnterPressed;

@end
