//
//  ThemeObjcModel.h
//  ChatApp
//
//  Created by Тимур Таймасов on 13.10.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThemeObjcModel : NSObject

@property (nonatomic, retain) UIColor *theme1;
@property (nonatomic, retain) UIColor *theme2;
@property (nonatomic, retain) UIColor *theme3;

- (instancetype)initWithTheme1:(UIColor *)theme1
                        Theme2:(UIColor *)theme2
                        Theme3:(UIColor *)theme3;

@end

NS_ASSUME_NONNULL_END
