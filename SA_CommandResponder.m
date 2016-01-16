//
//  SA_CommandResponder.m
//  RPGBot
//
//  Created by Sandy Achmiz on 1/5/16.
//
//

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
