//
//  ThemeObjcModel.m
//  ChatApp
//
//  Created by Тимур Таймасов on 13.10.2021.
//

#import "ThemeObjcModel.h"

@implementation ThemeObjcModel

@synthesize theme1 = _theme1;
@synthesize theme2 = _theme2;
@synthesize theme3 = _theme3;

#pragma mark Initializers
- (instancetype)initWithTheme1:(UIColor *)theme1
                        Theme2:(UIColor *)theme2
                        Theme3:(UIColor *)theme3 {
    self = [super init];
    if (self) {
        _theme1 = [theme1 copy];
        _theme2 = [theme2 copy];
        _theme3 = [theme3 copy];
    }
    return self;
}

#pragma mark Getters
- (UIColor *) theme1 {
    return _theme1;
}

- (UIColor *) theme2 {
    return _theme2;
}

- (UIColor *) theme3 {
    return _theme3;
}

#pragma mark Setters
- (void) setTheme1:(UIColor *)theme {
    if (_theme1 != theme) {
        UIColor *oldValue = _theme1;
        _theme1 = [theme retain];
        [oldValue release];
    }
}

- (void) setTheme2:(UIColor *)theme {
    if (_theme2 != theme) {
        UIColor *oldValue = _theme2;
        _theme2 = [theme retain];
        [oldValue release];
    }
}

- (void) setTheme3:(UIColor *)theme {
    if (_theme3 != theme) {
        UIColor *oldValue = _theme3;
        _theme3 = [theme retain];
        [oldValue release];
    }
}

#pragma mark Dealloc
- (void) dealloc {
    [_theme1 release];
    [_theme2 release];
    [_theme3 release];
    [super dealloc];
}

@end
