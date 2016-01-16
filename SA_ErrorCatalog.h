//
//  SA_ErrorCatalog.h
//  RPGBot
//
//  Created by Sandy Achmiz on 1/7/16.
//
//

#import <Foundation/Foundation.h>

/*********************/
#pragma mark Constants
/*********************/

extern NSString * const SA_DiceBotErrorDomain;

enum
{
	SA_DiceBotErrorUnknownSetting,
	SA_DiceBotErrorNoSettingInfo,
	SA_DiceBotErrorBadValueForSetting,
	SA_DiceBotErrorConfigurationError,
	
	SA_DiceBotErrorUnknownCommand,
	SA_DiceBotErrorNoParameters,
	SA_DiceBotErrorMissingLabel
};

/***********************************************/
#pragma mark - SA_ErrorCatalog class declaration
/***********************************************/

@interface SA_ErrorCatalog : NSObject

+ (NSError *)errorWithCode:(NSInteger)errorCode inDomain:(NSString *)domain;

@end
