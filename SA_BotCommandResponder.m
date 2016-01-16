//
//  SA_BotCommandResponder.m
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import "SA_BotCommandResponder.h"

#import "SA_ErrorCatalog.h"
#import "NSString+SA_NSStringExtensions.h"

/*********************/
#pragma mark Constants
/*********************/

NSString * const SA_BCR_COMMAND_ECHO	=	@"echo";

/*********************************************************/
#pragma mark - SA_BotCommandResponder class implementation
/*********************************************************/

@implementation SA_BotCommandResponder
{
	NSDictionary <NSString *, CommandEvaluator> *_commandEvaluators;
}

/************************/
#pragma mark - Properties
/************************/

- (NSDictionary <NSString *, CommandEvaluator> *)commandEvaluators
{
	if(_commandEvaluators == nil)
	{
		_commandEvaluators = [self getCommandEvaluators];
	}
	
	return _commandEvaluators;
}

/****************************/
#pragma mark - Public methods
/****************************/

- (NSArray <NSDictionary*> *)repliesForCommandString:(NSString *)commandString messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{
	// Split the string into whitespace-delimited chunks. The first
	// chunk is the command; the other chunks are parameter strings.
	// We generally interpret multiple parameter strings as "execute 
	// this command several times, with each of these strings".
	// (Some commands are exceptions to this.)
	NSArray *commandStringComponents = [commandString componentsSplitByWhitespaceWithMaxSplits:1];
	
	// Separate out the command from the parameter strings.
	NSString *command = [commandStringComponents[0] lowercaseString];
	NSArray *params = [commandStringComponents subarrayWithRange:NSMakeRange(1, commandStringComponents.count - 1)];
	
	// Check if the command is one of the recognized ones.
	if(self.commandEvaluators[command] != nil)
	{
		// Get the appropriate evaluator block.
		CommandEvaluator repliesForCommand = self.commandEvaluators[command];
		
		return repliesForCommand(params, messageInfo, error);
	}
	else
	{
		if(error != nil)
		{
			*error = [SA_ErrorCatalog errorWithCode:SA_DiceBotErrorUnknownCommand
										   inDomain:SA_DiceBotErrorDomain];
		}
		
		return @[];
	}
}

/*********************************************************/
#pragma mark - Command evaluation methods & wrapper blocks
/*********************************************************/

/****** ECHO ***************************************/
/* The "echo" command repeats the provided string. */
/***************************************************/
- (CommandEvaluator)repliesForCommandEcho
{
	return ^(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error)
	{
		return [self repliesForCommandEcho:params messageInfo:messageInfo error:error];
	};
}

- (NSMutableArray <NSDictionary *> *)repliesForCommandEcho:(NSArray<NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{
	NSMutableArray <NSDictionary *> *replies = [NSMutableArray array];
	
	if(params.count != 0)
	{
		[replies addObject:@{ SA_DB_MESSAGE_BODY	: params[0],
							  SA_DB_MESSAGE_INFO	: messageInfo }];
	}
	else
	{
		*error = [SA_ErrorCatalog errorWithCode:SA_DiceBotErrorNoParameters 
									   inDomain:SA_DiceBotErrorDomain];
	}
	
	return replies;
}

/***************************/
#pragma mark - Other methods
/***************************/

- (NSDictionary *)getCommandEvaluators
{
	return @{ SA_BCR_COMMAND_ECHO	: [self repliesForCommandEcho]
			  };
}
@end
