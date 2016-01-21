//
//  SA_ErrorCatalog.h
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

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

+ (BOOL)setError:(NSError **)error withCode:(NSInteger)errorCode inDomain:(NSString *)domain;
+ (NSError *)errorWithCode:(NSInteger)errorCode inDomain:(NSString *)domain;

@end
