//
//  SA_BotCommandResponder.h
//  RPGBot
//
//  Created by Sandy Achmiz on 1/8/16.
//
//

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
