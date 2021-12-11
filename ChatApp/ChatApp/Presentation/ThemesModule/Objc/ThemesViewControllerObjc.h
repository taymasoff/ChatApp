//
//  ThemesViewController.h
//  ChatApp
//
//  Created by Тимур Таймасов on 13.10.2021.
//

#import <UIKit/UIKit.h>
#import "ThemeObjcModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ThemesViewControllerObjc;
@protocol ThemesViewControllerDelegate <NSObject>
- (void)themesViewController:(ThemesViewControllerObjc*)controller
              didSelectTheme:(UIColor *)selectedTheme;
@end

@interface ThemesViewControllerObjc : UIViewController {
    id <ThemesViewControllerDelegate> delegate;
    ThemeObjcModel* model;
}

- (void)setDelegate:(id <ThemesViewControllerDelegate>)passedDelegate;

@end

NS_ASSUME_NONNULL_END
