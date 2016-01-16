//
//  SA_SettingsManager.h
//  RPGBot
//
//  Created by Sandy Achmiz on 1/7/16.
//
//

#import <Foundation/Foundation.h>

/**************************************************/
#pragma mark - SA_SettingsManager class declaration
/**************************************************/

@interface SA_SettingsManager : NSObject

/**************************/
#pragma mark - Initializers
/**************************/

- (instancetype)initWithPath:(NSString *)settingsFilePath;
- (instancetype)init __attribute__((unavailable("Must use initWithPath: instead.")));
+ (instancetype)new __attribute__((unavailable("Must use initWithPath: instead.")));

/****************************/
#pragma mark - Public methods
/****************************/

- (BOOL)setValue:(NSString *)value forSetting:(NSString *)setting error:(NSError **)error;
- (NSString *)valueforSetting:(NSString *)setting error:(NSError **)error;

- (void)resetAllSettingsToDefault;

- (NSDictionary *)allSettings;

- (NSString *)infoForSetting:(NSString *)setting error:(NSError **)error;

@end
