//
//  SA_CommandResponder.h
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import <Foundation/Foundation.h>

/*********************/
#pragma mark Constants
/*********************/

extern NSString * const SA_DB_MESSAGE_BODY;
extern NSString * const SA_DB_MESSAGE_INFO;

/***************************************************/
#pragma mark - SA_CommandResponder class declaration
/***************************************************/

@interface SA_CommandResponder : NSObject

/**********************************************/
#pragma mark - Public methods (command replies)
/**********************************************/

- (NSArray *)repliesForCommandString:(NSString *)commandString messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

@end
