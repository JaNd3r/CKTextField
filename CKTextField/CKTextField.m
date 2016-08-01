//
//  CKTextField.m
//  CKTextField
//
//  Created by Christian Klaproth on 12.09.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import "CKTextField.h"

@interface CKTextField() <UITextFieldDelegate>

@property (nonatomic) NSString* originalPlaceholder;
@property (nonatomic) UILabel* placeholderLabel;
@property (nonatomic) BOOL placeholderHideInProgress;
@property (nonatomic) BOOL readyForExternalDelegate;
@property (nonatomic, weak) id<UITextFieldDelegate> externalDelegate;
@property (nonatomic) UIButton* acceptButton;
@property (nonatomic) NSTextAlignment originalTextAlignment;

@end

static NSString* VALIDATION_TYPE_INTEGER = @"integer";
static NSString* VALIDATION_TYPE_TEXT = @"text";

@implementation CKTextField

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (self.placeholder) {
            self.originalPlaceholder = self.placeholder;
            self.readyForExternalDelegate = NO;
            self.delegate = self;
            self.readyForExternalDelegate = YES;
            self.placeholder = nil;
            
            self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, self.bounds.size.width - 14.0, self.bounds.size.height)];
            self.placeholderLabel.backgroundColor = [UIColor clearColor];
            self.placeholderLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
            self.placeholderLabel.textAlignment = self.textAlignment;
            self.placeholderLabel.text = self.originalPlaceholder;
            self.placeholderLabel.font = self.font;
            [self addSubview:self.placeholderLabel];
            
            if (self.textAlignment == NSTextAlignmentCenter) {
                self.originalTextAlignment = self.textAlignment;
                UIView* tLeftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width / 2 - 8, self.bounds.size.height)];
                tLeftView.backgroundColor = [UIColor clearColor];
                tLeftView.userInteractionEnabled = NO;
                self.leftView = tLeftView;
                self.leftViewMode = UITextFieldViewModeWhileEditing;
                self.textAlignment = NSTextAlignmentLeft;
            }

            if (self.text.length > 0) {
                self.placeholderLabel.hidden = YES;
            } else {
                self.placeholderLabel.hidden = NO;
            }
            
            self.placeholderHideInProgress = NO;
            
            self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
            self.acceptButton.frame = CGRectMake(self.bounds.size.width, 2.0, self.bounds.size.height - 4.0, self.bounds.size.height - 4.0);
            self.acceptButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.75 blue:0.5 alpha:1.0];
            self.acceptButton.layer.cornerRadius = (self.bounds.size.height - 4.0) / 2;
            self.acceptButton.userInteractionEnabled = YES;
            self.acceptButton.hidden = YES;
            [self.acceptButton addTarget:self action:@selector(acceptButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.acceptButton];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.placeholderLabel) {
        self.placeholderLabel.frame = CGRectMake(7.0, 0.0, self.bounds.size.width - 14.0, self.bounds.size.height);
    }
    if (self.originalTextAlignment == NSTextAlignmentCenter) {
        self.leftView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width / 2 - 8, self.bounds.size.height);
    }
}

- (void)setText:(NSString*)text
{
    if ([self performValidationOnInput:text]) {
        [super setText:text];
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
        if (self.text.length == 0 && self.placeholderLabel.hidden) {
            if (self.originalTextAlignment == NSTextAlignmentCenter) {
                self.leftView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width / 2 - 8, self.bounds.size.height);
                self.textAlignment = NSTextAlignmentLeft;
            }
            self.placeholderLabel.alpha = 0.0;
            self.placeholderLabel.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.placeholderLabel.alpha = 1.0;
            }];
        } else if (self.text.length > 0 && !self.placeholderLabel.hidden) {
            if (self.originalTextAlignment == NSTextAlignmentCenter) {
                self.leftView.frame = CGRectMake(0.0, 0.0, 0.0, self.bounds.size.height);
                self.textAlignment = NSTextAlignmentCenter;
            }
            if (!self.placeholderHideInProgress) {
                self.placeholderHideInProgress = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    self.placeholderLabel.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.placeholderLabel.hidden = YES;
                    self.placeholderHideInProgress = NO;
                }];
            }
        }
    }
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    if ([delegate isEqual:self.delegate]) {
        return;
    }
    if (self.readyForExternalDelegate) {
        self.externalDelegate = delegate;
    } else {
        if (self.delegate) {
            self.externalDelegate = delegate;
        }
        [super setDelegate:delegate];
    }
}
/**
 * @return YES, if the string should be set into the textfield
 */
- (BOOL)performValidationOnInput:(NSString*)aString
{
    if (self.validationType && self.validationType.length > 0) {
        // validation type is set
        if ([self.validationType isEqualToString:VALIDATION_TYPE_TEXT]) {
            int tMinLength;
            int tMaxLength;
            if (self.pattern && self.pattern.length > 0) {
                tMinLength = (int)self.pattern.length;
                tMaxLength = (int)self.pattern.length;
            } else {
                tMinLength = [self.minLength intValue];
                tMaxLength = [self.maxLength intValue];
            }
            
            // While aString.length is smaller than tMinLength, the
            // validation result is unknown. Give the user the chance
            // to enter a valid string. If aString.length is between
            // tMinLength and tMaxLength validation passes, if
            // aString.length exceeds tMaxLength, the validation
            // fails. Punish the user with shaking UIs or terrible
            // sounds. :)
            
            if (aString.length < tMinLength) {
                if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                    [self.validationDelegate textField:self validationResult:CKTextFieldValidationUnknown forText:aString];
                }
                return YES;
            }
            
            if (aString.length > tMaxLength) {
                if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                    [self.validationDelegate textField:self validationResult:CKTextFieldValidationFailed forText:aString];
                }
                return NO;
            }
            
            if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                [self.validationDelegate textField:self validationResult:CKTextFieldValidationPassed forText:aString];
            }
            return YES;
        }
        
        if ([self.validationType isEqualToString:VALIDATION_TYPE_INTEGER]) {
            NSString* tValidCharacters = @"0123456789";
            if (self.pattern && self.pattern.length > 0) {
                tValidCharacters = [NSString stringWithFormat:@"%@%@", tValidCharacters, [self.pattern stringByReplacingOccurrencesOfString:@"#" withString:@""]];
            }
            for (int i=0; i<aString.length; i++) {
                NSString* tCharacter = [aString substringWithRange:NSMakeRange(i, 1)];
                if ([tValidCharacters rangeOfString:tCharacter].location == NSNotFound) {
                    if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                        [self.validationDelegate textField:self validationResult:CKTextFieldValidationFailed forText:aString];
                        return NO;
                    }
                }
            }
            
            NSDecimalNumber* tMinValue = [NSDecimalNumber decimalNumberWithString:self.minValue];
            NSDecimalNumber* tMaxValue = [NSDecimalNumber decimalNumberWithString:self.maxValue];
            NSDecimalNumber* tCurrentValue = [NSDecimalNumber decimalNumberWithString:aString];
            
            if ([tCurrentValue compare:tMinValue] == NSOrderedAscending) {
                if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                    [self.validationDelegate textField:self validationResult:CKTextFieldValidationUnknown forText:aString];
                }
                return YES;
            }
            
            if ([tCurrentValue compare:tMaxValue] == NSOrderedDescending) {
                if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                    [self.validationDelegate textField:self validationResult:CKTextFieldValidationFailed forText:aString];
                }
                return NO;
            }

            if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(textField:validationResult:forText:)]) {
                [self.validationDelegate textField:self validationResult:CKTextFieldValidationPassed forText:aString];
            }
            return YES;
        }
    }
    
    return YES;
}

/**
 * Format string syntax: '#' means 'any character in the plain string'
 * Other characters will be moved as they are from the pattern into the formatted string.
 * Note: Currently only '#' is supported as the 'any character' placeholder.
 * Escaping or other meaningful placeholders are added later (eventually). :)
 */
- (NSString*)formatPlainString:(NSString*)aString withPattern:(NSString*)aPattern {
    NSString* tResultString = @"";
    int tPlainPointer = 0;
    for (int i=0; i<aPattern.length; i++) {
        
        // check if end of aString is reached
        if (tPlainPointer == aString.length) {
            return tResultString;
        }
        
        // determine current character at position i
        if ([[aPattern substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"#"]) {
            // content character
            tResultString = [NSString stringWithFormat:@"%@%@", tResultString, [aString substringWithRange:NSMakeRange(tPlainPointer, 1)]];
            tPlainPointer++;
        } else {
            tResultString = [NSString stringWithFormat:@"%@%@", tResultString, [aPattern substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    
    // if plain string contains more characters append them and let the
    // validation routine handle the limit checks
    if (aString.length > tPlainPointer) {
        tResultString = [NSString stringWithFormat:@"%@%@", tResultString, [aString substringFromIndex:tPlainPointer]];
    }
    
    return tResultString;
}

/**
 * Removes the pattern section characters from an already formatted string.
 * e.g. 1-100/20/30 => 11002030
 */
- (NSString*)stripPattern:(NSString*)aPattern fromFormattedString:(NSString*)aString {
    NSString* tSeparatorsString = [aPattern stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString* tResultString = aString;
    for (int i=0; i<tSeparatorsString.length; i++) {
        tResultString = [tResultString stringByReplacingOccurrencesOfString:[tSeparatorsString substringWithRange:NSMakeRange(i, 1)] withString:@""];
    }
    return tResultString;
}

- (void)shake
{
    self.layer.transform = CATransform3DMakeTranslation(10.0, 0.0, 0.0);
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        self.layer.transform = CATransform3DIdentity;        
    }];
}

- (void)flashBorderWithColor:(UIColor*)aColor
{
    __block CGColorRef tOldBorderColor = self.layer.borderColor;
    __block CGFloat tOldBorderWidth = self.layer.borderWidth;
    [UIView animateWithDuration:0.3 animations:^{
        self.layer.borderColor = [aColor CGColor];
        self.layer.borderWidth = 2.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.layer.borderColor = tOldBorderColor;
            self.layer.borderWidth = tOldBorderWidth;            
        }];
    }];
}

- (void)showAcceptButton
{
    if (self.acceptButton.hidden) {
        self.acceptButton.alpha = 0.0;
        self.acceptButton.hidden = NO;
        [self bringSubviewToFront:self.acceptButton];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.acceptButton.alpha = 1.0;
            self.acceptButton.transform = CGAffineTransformMakeTranslation(-self.bounds.size.height + 2.0, 0);
        } completion:^(BOOL finished) {
            self.acceptButton.alpha = 1.0;
        }];
    }
}

- (void)hideAcceptButton
{
    [UIView animateWithDuration:0.3 animations:^{
        self.acceptButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.acceptButton.hidden = YES;
        self.acceptButton.transform = CGAffineTransformIdentity;
    }];
}

- (void)acceptButtonTouchUpInside
{
    [self hideAcceptButton];
    [self resignFirstResponder];
}

- (void)internalEnterPressed
{
    [self acceptButtonTouchUpInside];
    [super internalEnterPressed];
}

#pragma mark Text Field Delegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    // If an 'external' delegate implements this method, it is responsible for allowing the
    // changed characters to be set as text of the text field.
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return ([self.externalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string]);
    }
    
    // Create the resulting new content of the text field.
    NSString* tNewString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // apply pattern if set
    if (self.pattern && self.pattern.length > 0) {
        
        // allow input of mask characters if they match with the pattern string
        if (![string isEqualToString:@"#"]) {
            if (self.pattern.length > textField.text.length && [[self.pattern substringWithRange:NSMakeRange(textField.text.length, 1)] isEqualToString:string]) {
                return YES;
            }
        }

        NSString* tPlainString = [self stripPattern:self.pattern fromFormattedString:tNewString];
        tNewString = [self formatPlainString:tPlainString withPattern:self.pattern];
    }
    
    self.text = tNewString;
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.externalDelegate textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.externalDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.externalDelegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.externalDelegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.externalDelegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.externalDelegate textFieldShouldReturn:textField];
    }
    return YES;
}

@end
