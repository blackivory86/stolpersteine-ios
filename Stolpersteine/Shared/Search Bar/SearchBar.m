//
//  SearchBarView.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SearchBar.h"

#import "SearchTextField.h"
#import "SearchBarDelegate.h"

#define PADDING_LEFT 5

@interface SearchBar() <UITextFieldDelegate>

@property (nonatomic, strong) SearchTextField *searchTextField;

@end

@implementation SearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.backgroundColor = UIColor.clearColor;
    
    self.searchTextField = [[SearchTextField alloc] initWithFrame:CGRectZero];  // text field automatically resizes to fit
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchTextField.delegate = self;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    [self addSubview:self.searchTextField];
    
    [self.searchTextField addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchTextField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setText:(NSString *)text
{
    self.searchTextField.text = text;
}

- (NSString *)text
{
    return self.searchTextField.text;
}

- (void)setFrame:(CGRect)frame
{
    CGFloat y = (self.superview.frame.size.height - self.frame.size.height) * 0.5;
    [super setFrame:CGRectMake(PADDING_LEFT, y, self.superview.frame.size.width - self.paddingRight, frame.size.height)];
}

- (void)setPortraitModeEnabled:(BOOL)portraitModeEnabled
{
    self.searchTextField.portraitModeEnabled = portraitModeEnabled;
}

- (BOOL)isPortraitModeEnabled
{
    return self.searchTextField.isPortraitModeEnabled;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.rightViewMode = UITextFieldViewModeNever;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.rightViewMode = text.length > 0 ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(searchBarShouldReturn:)]) {
        result = [self.delegate searchBarShouldReturn:self];
    }
    
    return result;
}

- (void)editingDidBegin:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}

- (void)editingChanged:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.searchTextField resignFirstResponder];
}

@end
