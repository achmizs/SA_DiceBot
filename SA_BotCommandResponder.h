//
//  SA_BotCommandResponder.h
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import <Foundation/Foundation.h>
#import "SA_CommandResponder.h"

/*********************/
#pragma mark Constants
/*********************/

extern NSString * const SA_BCR_COMMAND_ECHO;

/******************************/
#pragma mark - Type definitions
/******************************/

typedef NSMutableArray <NSDictionary *> * (^CommandEvaluator)(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error);

/******************************************************/
#pragma mark - SA_BotCommandResponder class declaration
/******************************************************/

@interface SA_BotCommandResponder : SA_CommandResponder

/************************/
#pragma mark - Properties
/************************/

@property (readonly) NSDictionary <NSString *, CommandEvaluator> *commandEvaluators;

/****************************/
#pragma mark - Public methods
/****************************/

- (NSArray *)repliesForCommandString:(NSString *)commandString messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

/*********************************************************/
#pragma mark - Command evaluation methods & wrapper blocks
/*********************************************************/

- (CommandEvaluator)repliesForCommandEcho;
- (NSMutableArray <NSDictionary *> *)repliesForCommandEcho:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

/***************************/
#pragma mark - Other methods
/***************************/

- (NSDictionary *)getCommandEvaluators;

@end
