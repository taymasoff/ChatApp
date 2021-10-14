//
//  ThemesViewController.m
//  ChatApp
//
//  Created by Тимур Таймасов on 13.10.2021.
//

#import "ThemesViewControllerObjc.h"
#import "ThemeObjcModel.h"
#import "ChatApp-Swift.h"

@interface ThemesViewControllerObjc () {
    IBOutlet UIButton *themeButton1;
    IBOutlet UIButton *themeButton2;
    IBOutlet UIButton *themeButton3;
}
@end

@implementation ThemesViewControllerObjc

#pragma mark DelegateSetter
- (void)setDelegate:(id <ThemesViewControllerDelegate>)passedDelegate {
    if (delegate != passedDelegate) {
        [passedDelegate retain];
        [delegate release];
        delegate = passedDelegate;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    model = [[ThemeObjcModel alloc] initWithTheme1:UIColor.grayColor
                                            Theme2:UIColor.blackColor
                                            Theme3:UIColor.yellowColor];
    
    themeButton1.layer.cornerRadius = 14;
    themeButton2.layer.cornerRadius = 14;
    themeButton3.layer.cornerRadius = 14;
}

#pragma mark ActionMethods
- (IBAction)themeButton1Pressed:(UIButton *)sender {
    self.view.backgroundColor = model.theme1;
    [self themeIsPicked:model.theme1];
}

- (IBAction)themeButton2Pressed:(UIButton *)sender {
    self.view.backgroundColor = model.theme2;
    [self themeIsPicked:model.theme2];
}

- (IBAction)themeButton3Pressed:(UIButton *)sender {
    self.view.backgroundColor = model.theme3;
    [self themeIsPicked:model.theme3];
}

- (IBAction)closeButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark Private Methods
- (void)themeIsPicked:(UIColor *)theme {
    [delegate themesViewController:self didSelectTheme:theme];
}


- (void)dealloc {
    themeButton1 = nil;
    themeButton2 = nil;
    themeButton3 = nil;
    [model release];
    model = nil;
    [delegate release];
    delegate = nil;

    [super dealloc];
}

@end
