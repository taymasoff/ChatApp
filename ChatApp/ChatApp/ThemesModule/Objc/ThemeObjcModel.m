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

- (void) setTheme1:(UIColor *)theme {
    [theme retain];
    [_theme1 release];
    _theme1 = theme;
}

- (void) setTheme2:(UIColor *)theme {
    [theme retain];
    [_theme2 release];
    _theme2 = theme;
}

- (void) setTheme3:(UIColor *)theme {
    [theme retain];
    [_theme3 release];
    _theme3 = theme;
}

- (void) dealloc {
    [_theme1 release];
    [_theme2 release];
    [_theme3 release];
    [super dealloc];
}

@end
