//
//  SA_LegacyCommandResponder.m
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import "SA_LegacyCommandResponder.h"

#import "SA_DiceParser.h"
#import "SA_DiceEvaluator.h"
#import "SA_DiceFormatter.h"
#import "SA_ErrorCatalog.h"
#import "SA_SettingsManager.h"
#import "NSString+SA_NSStringExtensions.h"

/*********************/
#pragma mark Constants
/*********************/

NSString * const SA_LCR_COMMAND_ROLL	=	@"roll";
NSString * const SA_LCR_COMMAND_TRY		=	@"try";
NSString * const SA_LCR_COMMAND_INIT	=	@"init";
NSString * const SA_LCR_COMMAND_CHAR	=	@"char";

static NSString * const settingsFileName	=	@"SA_LegacyCommandResponderSettings";

static NSString * const SA_LCR_SETTINGS_LABEL_DELIMITER					=	@"labelDelimiter";
static NSString * const SA_LCR_SETTINGS_INITIATIVE_FORMAT				=	@"initiativeFormat";
static NSString * const SA_LCR_SETTINGS_INITIATIVE_FORMAT_EXPANDED		=	@"EXPANDED";
static NSString * const SA_LCR_SETTINGS_INITIATIVE_FORMAT_COMPACT		=	@"COMPACT";

/************************************************************/
#pragma mark - SA_LegacyCommandResponder class implementation
/************************************************************/

@implementation SA_LegacyCommandResponder
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

/**************************/
#pragma mark - Initializers
/**************************/

- (instancetype)init
{
	if(self = [super init])
	{
		self.parser = [SA_DiceParser defaultParser];
		self.evaluator = [SA_DiceEvaluator new];
		self.resultsFormatter = [SA_DiceFormatter defaultFormatter];
		self.initiativeResultsFormatter = [SA_DiceFormatter formatterWithBehavior:SA_DiceFormatterBehaviorSimple];
		self.characterResultsFormatter = [SA_DiceFormatter defaultFormatter];
		
		NSString *settingsPath = [[NSBundle bundleForClass:[self class]] pathForResource:settingsFileName ofType:@"plist"];
		self.settings = [[SA_SettingsManager alloc] initWithPath:settingsPath];
		if(self.settings == nil)
		{
			NSLog(NSLocalizedString(@"Could not load settings!", nil));
		}
	}
	return self;
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
	NSArray *commandStringComponents = [commandString componentsSplitByWhitespace];
	
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
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorUnknownCommand 
						 inDomain:SA_DiceBotErrorDomain];
		return @[];
	}
}

/*********************************************************/
#pragma mark - Command evaluation methods & wrapper blocks
/*********************************************************/

/****** ROLL ***************************************************/
/* The "roll" command evaluates each provided die roll string. */
/***************************************************************/
- (CommandEvaluator)repliesForCommandRoll
{
	return ^(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error)
	{
		return [self repliesForCommandRoll:params messageInfo:messageInfo error:error];
	};
}

- (NSMutableArray <NSDictionary *> *)repliesForCommandRoll:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{	
	__block NSMutableArray <NSDictionary *> *replies = [NSMutableArray arrayWithCapacity:params.count];

	if(params.count == 0)
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorNoParameters 
						 inDomain:SA_DiceBotErrorDomain];
		return replies;
	}
	
	[params enumerateObjectsUsingBlock:^(NSString *rollString, NSUInteger idx, BOOL *stop) 
	 {
		 // Remove the label (if any).
		 NSRange labelDelimiterPosition = [rollString rangeOfString:[self.settings valueforSetting:SA_LCR_SETTINGS_LABEL_DELIMITER error:error]];
		 NSString *rollStringBody = (labelDelimiterPosition.location != NSNotFound) ? [rollString substringToIndex:labelDelimiterPosition.location] : rollString;
		 NSString *rollStringLabel = (labelDelimiterPosition.location != NSNotFound) ? [rollString substringFromIndex:labelDelimiterPosition.location + labelDelimiterPosition.length] : nil;
		 
		 // Parse, evaluate, and format.
		 NSDictionary *expression = [self.parser expressionForString:rollStringBody];
		 NSDictionary *results = [self.evaluator resultOfExpression:expression];
		 NSString *formattedResultString = [self.resultsFormatter stringFromExpression:results];
		 
		 // Attach the label (if any) to the result string.
		 NSString *replyMessageBody = (rollStringLabel != nil) ? [NSString stringWithFormat:@"(%@) %@", rollStringLabel, formattedResultString] : formattedResultString;

		 [replies addObject:@{ SA_DB_MESSAGE_BODY	: replyMessageBody,
							   SA_DB_MESSAGE_INFO	: messageInfo }];
	 }];
	
	return replies;	
}

/****** TRY ****************************************************************/
/* The "try" command prepends "1d20+" to each provided die roll string and */
/* evaluates it.                                                           */
/***************************************************************************/
- (CommandEvaluator)repliesForCommandTry
{
	return ^(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error)
	{
		return [self repliesForCommandTry:params messageInfo:messageInfo error:error];
	};
}

- (NSMutableArray <NSDictionary *> *)repliesForCommandTry:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{
	__block NSMutableArray <NSDictionary *> *replies = [NSMutableArray arrayWithCapacity:params.count];

	if(params.count == 0)
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorNoParameters 
						 inDomain:SA_DiceBotErrorDomain];
		return replies;
	}
	
	[params enumerateObjectsUsingBlock:^(NSString *tryString, NSUInteger idx, BOOL *stop) 
	 {
		 // Remove the label (if any).
		 NSRange labelDelimiterPosition = [tryString rangeOfString:[self.settings valueforSetting:SA_LCR_SETTINGS_LABEL_DELIMITER error:error]];
		 NSString *tryStringBody = (labelDelimiterPosition.location != NSNotFound) ? [tryString substringToIndex:labelDelimiterPosition.location] : tryString;
		 NSString *tryStringLabel = (labelDelimiterPosition.location != NSNotFound) ? [tryString substringFromIndex:labelDelimiterPosition.location + labelDelimiterPosition.length] : nil;
		 
		 // Make the "try string" a true roll string by prepending "1d20+".
		 NSString *rollString = [NSString stringWithFormat:@"1d20+%@", tryStringBody];
		 
		 // Parse, evaluate, and format.
		 NSDictionary *expression = [self.parser expressionForString:rollString];
		 NSDictionary *results = [self.evaluator resultOfExpression:expression];
		 NSString *formattedResultString = [self.resultsFormatter stringFromExpression:results];
		 
		 // Attach the label (if any) to the result string.
		 NSString *replyMessageBody = (tryStringLabel != nil) ? [NSString stringWithFormat:@"(%@) %@", tryStringLabel, formattedResultString] : formattedResultString;
		 
		 [replies addObject:@{ SA_DB_MESSAGE_BODY	: replyMessageBody,
							   SA_DB_MESSAGE_INFO	: messageInfo }];
	 }];
	
	return replies;	
}

/****** INIT ****************************************************************/
/* The "init" command is like the "try" command, but shows the results in a */
/* simplified output form and sorts them from highest to lowest.            */
/****************************************************************************/
- (CommandEvaluator)repliesForCommandInit
{
	return ^(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error)
	{
		return [self repliesForCommandInit:params messageInfo:messageInfo error:error];
	};
}

- (NSMutableArray <NSDictionary *> *)repliesForCommandInit:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{
	__block NSMutableArray <NSDictionary *> *replies = [NSMutableArray arrayWithCapacity:params.count];
	
	if(params.count == 0)
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorNoParameters 
						 inDomain:SA_DiceBotErrorDomain];
		return replies;
	}
	
	__block NSMutableArray <NSDictionary *> *replyComponents = [NSMutableArray arrayWithCapacity:params.count];
	__block NSError *errorWhileEnumerating;
	[params enumerateObjectsUsingBlock:^(NSString *initString, NSUInteger idx, BOOL *stop) 
	 {
		 // Remove the label (if any).
		 NSRange labelDelimiterPosition = [initString rangeOfString:[self.settings valueforSetting:SA_LCR_SETTINGS_LABEL_DELIMITER error:error]];
		 NSString *initStringBody = (labelDelimiterPosition.location != NSNotFound) ? [initString substringToIndex:labelDelimiterPosition.location] : initString;
		 NSString *initStringLabel = (labelDelimiterPosition.location != NSNotFound) ? [initString substringFromIndex:labelDelimiterPosition.location + labelDelimiterPosition.length] : nil;
		 
		 // Make the "init string" a true roll string by prepending "1d20+".
		 NSString *rollString = [NSString stringWithFormat:@"1d20+%@", initStringBody];
		 
		 // Parse, evaluate, and format.
		 // (We use a separate formatter for initiative results, as the format
		 // should be simple and concise, regardless of what the format settings
		 // are in general.)
		 NSDictionary *expression = [self.parser expressionForString:rollString];
		 NSDictionary *results = [self.evaluator resultOfExpression:expression];
		 NSString *formattedResultString = [self.initiativeResultsFormatter stringFromExpression:results];
		 
		 // Initiative strings MUST have a label. If even one label is missing,
		 // set an error and send no reply lines.
		 if(initStringLabel == nil || [initStringLabel isEqualToString:@""])
		 {
			 errorWhileEnumerating = [SA_ErrorCatalog errorWithCode:SA_DiceBotErrorMissingLabel
														   inDomain:SA_DiceBotErrorDomain];
			 *stop = YES;
		 }
		 else
		 {
			 [replyComponents addObject:@{@"result"	: formattedResultString,
										  @"label"	: initStringLabel
										  }];
		 }
	 }];
	
	// If generating the init results didn't go well, set the error.
	if(errorWhileEnumerating != nil && error != nil)
	{
		*error = errorWhileEnumerating;
	}
	// Otherwise, assemble the replies.
	else
	{
		[replies addObject:@{ SA_DB_MESSAGE_BODY	: NSLocalizedString(@"Initiative!", nil),
							  SA_DB_MESSAGE_INFO	: messageInfo }];
		
		// Sort the init results.
		[replyComponents sortUsingComparator:^NSComparisonResult(NSDictionary *result1, NSDictionary *result2) {
			if([result1[@"result"] integerValue] > [result2[@"result"] integerValue])
				return NSOrderedAscending;
			else if([result1[@"result"] integerValue] < [result2[@"result"] integerValue])
				return NSOrderedDescending;
			else
				return NSOrderedSame;
		}];
		
		// If EXPANDED format mode is set, add each reply.
		if([[self.settings valueforSetting:SA_LCR_SETTINGS_INITIATIVE_FORMAT error:error] isEqualToString:SA_LCR_SETTINGS_INITIATIVE_FORMAT_EXPANDED])
		{
			[replyComponents enumerateObjectsUsingBlock:^(NSDictionary *replyComponent, NSUInteger idx, BOOL *stop){
				NSString *replyMessageBody = [NSString stringWithFormat:@"%@ %@", replyComponent[@"label"], replyComponent[@"result"]];
				[replies addObject:@{ SA_DB_MESSAGE_BODY	: replyMessageBody,
									  SA_DB_MESSAGE_INFO	: messageInfo }];				
			}];
		}
		// If COMPACT format mode is set, collapse all initiative results into 
		// a single reply line.
		else if([[self.settings valueforSetting:SA_LCR_SETTINGS_INITIATIVE_FORMAT error:error] isEqualToString:SA_LCR_SETTINGS_INITIATIVE_FORMAT_COMPACT])
		{
			__block NSMutableString *replyLine = [NSMutableString string];
			[replyComponents enumerateObjectsUsingBlock:^(NSDictionary *replyComponent, NSUInteger idx, BOOL *stop){
				[replyLine appendFormat:@"%@ %@%@", 
				 replyComponent[@"label"], 
				 replyComponent[@"result"],
				 ((idx != replyComponents.count - 1) ? @"  " : @"")];
			}];
			[replies addObject:@{ SA_DB_MESSAGE_BODY	: replyLine,
								  SA_DB_MESSAGE_INFO	: messageInfo }];
		}
		// The format mode setting has become corrupted somehow.
		else
		{
			NSLog(@"%@", [self.settings allSettings]);
			
			[SA_ErrorCatalog setError:error 
							 withCode:SA_DiceBotErrorConfigurationError 
							 inDomain:SA_DiceBotErrorDomain];
		}
	}
	
	return replies;	
}

/****** CHAR ************************************************************/
/* The "char" command generates a set of D&D character stats, using the */
/* '4d6 drop lowest' rolling method. It takes no arguments.             */
/************************************************************************/
- (CommandEvaluator)repliesForCommandChar
{
	return ^(NSArray <NSString *> *params, NSDictionary *messageInfo, NSError **error)
	{
		return [self repliesForCommandChar:params messageInfo:messageInfo error:error];
	};
}

- (NSMutableArray <NSDictionary *> *)repliesForCommandChar:(NSArray <NSString *> *)params messageInfo:(NSDictionary *)messageInfo error:(NSError **)error
{
	return [NSMutableArray arrayWithCapacity:2];
}

/***************************/
#pragma mark - Other methods
/***************************/

- (NSDictionary *)getCommandEvaluators
{
	return @{ SA_LCR_COMMAND_ROLL	: [self repliesForCommandRoll],
			  SA_LCR_COMMAND_TRY	: [self repliesForCommandTry],
			  SA_LCR_COMMAND_INIT	: [self repliesForCommandInit]
			  };
}

@end
