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

- (void)setText:(NSString*)text
{
    if ([self performValidationOnInput:text]) {
        [super setText:text];
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
                    self.placeholderLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
                } completion:^(BOOL finished) {
                    self.placeholderLabel.hidden = YES;
                    self.placeholderLabel.transform = CGAffineTransformIdentity;
                    self.placeholderHideInProgress = NO;
                }];
            }
        }
    }
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
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
            int tMinLength = [self.minLength intValue];
            int tMaxLength = [self.maxLength intValue];
            
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
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if (![self.externalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            return NO;
        }
    }
    NSString* tNewString = [textField.text stringByReplacingCharactersInRange:range withString:string];
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
