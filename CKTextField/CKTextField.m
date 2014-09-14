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

@end

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
                UIView* tLeftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width / 2 - 8, self.bounds.size.height)];
                tLeftView.backgroundColor = [UIColor clearColor];
                self.leftView = tLeftView;
                self.leftViewMode = UITextFieldViewModeWhileEditing;
            }

            if (self.text.length > 0) {
                self.placeholderLabel.hidden = YES;
            } else {
                self.placeholderLabel.hidden = NO;
            }
            
            self.placeholderHideInProgress = NO;
        }
    }
    return self;
}

- (void)setText:(NSString*)text
{
    [super setText:text];
    if (self.text.length == 0 && self.placeholderLabel.hidden) {
        if (self.textAlignment == NSTextAlignmentCenter) {
            self.leftView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width / 2 - 8, self.bounds.size.height);
        }
        self.placeholderLabel.alpha = 0.0;
        self.placeholderLabel.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.placeholderLabel.alpha = 1.0;
        }];
    } else if (self.text.length > 0 && !self.placeholderLabel.hidden) {
        if (self.textAlignment == NSTextAlignmentCenter) {
            self.leftView.frame = CGRectMake(0.0, 0.0, 0.0, self.bounds.size.height);
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

#pragma mark Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
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
