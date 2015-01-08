//
//  ExternalKeyboardSupportedTextField.m
//  CKTextField
//
//  Created by Christian Klaproth on 04.01.15.
//  Copyright (c) 2015 Christian Klaproth. All rights reserved.
//

#import "CKExternalKeyboardSupportedTextField.h"

@implementation CKExternalKeyboardSupportedTextField

- (NSArray *)keyCommands
{
    UIKeyCommand *tESCKey = [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(internalEscPressed)];
    UIKeyCommand *tEnterKey = [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:0 action:@selector(internalEnterPressed)];
    return @[tESCKey, tEnterKey];
}

- (void)internalEscPressed
{
    if ([self.keyboardDelegate respondsToSelector:@selector(escPressedInTextField:)]) {
        [self.keyboardDelegate escPressedInTextField:self];
    }
}

- (void)internalEnterPressed
{
    if ([self.keyboardDelegate respondsToSelector:@selector(enterPressedInTextField:)]) {
        [self.keyboardDelegate enterPressedInTextField:self];
    }
}

@end
