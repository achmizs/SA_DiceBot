//
//  SA_CommandResponder.m
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import "SA_CommandResponder.h"

#import "SA_ErrorCatalog.h"

/*****************************/
#pragma mark - Other constants
/*****************************/

NSString * const SA_DB_MESSAGE_BODY		=	@"SA_DB_MESSAGE_BODY";
NSString * const SA_DB_MESSAGE_INFO		=	@"SA_DB_MESSAGE_INFO";

/******************************************************/
#pragma mark - SA_CommandResponder class implementation
/******************************************************/

@implementation SA_CommandResponder

/**********************************************/
#pragma mark - Public methods (command replies)
/**********************************************/

- (NSArray *)repliesForCommandString:(NSString *)commandString messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{
	*error = [SA_ErrorCatalog errorWithCode:SA_DiceBotErrorUnknownCommand 
								   inDomain:SA_DiceBotErrorDomain];
	
	return nil;
}

@end
