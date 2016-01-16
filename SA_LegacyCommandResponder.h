//
//  SA_LegacyCommandResponder.h
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import <Foundation/Foundation.h>
#import "SA_CommandResponder.h"

@class SA_DiceParser;
@class SA_DiceEvaluator;
@class SA_DiceFormatter;
@class SA_SettingsManager;

/*********************/
#pragma mark Constants
/*********************/

extern NSString * const SA_LCR_COMMAND_ROLL;
extern NSString * const SA_LCR_COMMAND_TRY;
extern NSString * const SA_LCR_COMMAND_INIT;
extern NSString * const SA_LCR_COMMAND_CHAR;

/******************************/
#pragma mark - Type definitions
/******************************/

typedef NSMutableArray <NSDictionary *> * (^CommandEvaluator)(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error);

/*********************************************************/
#pragma mark - SA_LegacyCommandResponder class declaration
/*********************************************************/

@interface SA_LegacyCommandResponder : SA_CommandResponder

/************************/
#pragma mark - Properties
/************************/

@property (strong) SA_DiceParser *parser;
@property (strong) SA_DiceEvaluator *evaluator;
@property (strong) SA_DiceFormatter *resultsFormatter;
@property (strong) SA_DiceFormatter *initiativeResultsFormatter;
@property (strong) SA_DiceFormatter *characterResultsFormatter;

@property (strong) SA_SettingsManager *settings;

@property (readonly) NSDictionary <NSString *, CommandEvaluator> *commandEvaluators;

/****************************/
#pragma mark - Public methods
/****************************/

- (NSArray *)repliesForCommandString:(NSString *)commandString messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

/*********************************************************/
#pragma mark - Command evaluation methods & wrapper blocks
/*********************************************************/

- (CommandEvaluator)repliesForCommandRoll;
- (NSMutableArray <NSDictionary *> *)repliesForCommandRoll:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

- (CommandEvaluator)repliesForCommandTry;
- (NSMutableArray <NSDictionary *> *)repliesForCommandTry:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

- (CommandEvaluator)repliesForCommandInit;
- (NSMutableArray <NSDictionary *> *)repliesForCommandInit:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

- (CommandEvaluator)repliesForCommandChar;
- (NSMutableArray <NSDictionary *> *)repliesForCommandChar:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error;

/***************************/
#pragma mark - Other methods
/***************************/

- (NSDictionary *)getCommandEvaluators;

@end
