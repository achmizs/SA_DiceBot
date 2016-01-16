//
//  SA_ErrorCatalog.m
//  RPGBot
//
//  Created by Sandy Achmiz on 1/7/16.
//
//

#import "SA_ErrorCatalog.h"

/************************************/
#pragma mark Constants
/************************************/

NSString * const SA_DiceBotErrorDomain	=	@"SA_DiceBotErrorDomain";

/**************************************************/
#pragma mark - SA_ErrorCatalog class implementation
/**************************************************/

@implementation SA_ErrorCatalog

+ (NSError *)errorWithCode:(NSInteger)errorCode inDomain:(NSString *)domain
{
	return [NSError errorWithDomain:domain 
							   code:errorCode 
						   userInfo:[self userInfoForErrorCode:errorCode]];
}

+ (NSDictionary *)userInfoForErrorCode:(NSInteger)errorCode
{
	NSDictionary *userInfo;
	
	if(errorCode == SA_DiceBotErrorUnknownSetting)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown setting.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The current command responder does not support that setting.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check your spelling.", nil)
					  };
	}
	else if(errorCode == SA_DiceBotErrorNoSettingInfo)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"No setting info.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No information was provided about this setting.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ask the owner of this bot for help.", nil)
					  };
	}
	else if(errorCode == SA_DiceBotErrorBadValueForSetting)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Bad value for setting.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The provided value for this setting is not one of the permitted values. The setting was not changed.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Use the INFO command to see what values this setting may take.", nil)
					  };
	}
	else if(errorCode == SA_DiceBotErrorConfigurationError)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Configuration error.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The settings for this command are incorrect or missing, and the command could not be completed.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Use the INFO command to view the command responder's current settings.", nil)
					  };
	}
	else if(errorCode == SA_DiceBotErrorUnknownCommand)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Command not recognized.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The active command responder does not support that command.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check your spelling.", nil)
					  };
	}
	else if(errorCode == SA_DiceBotErrorNoParameters)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"No arguments found.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No arguments were provided in the command input.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"This command takes one or more arguments, separated by whitespace.", nil)
					  };
	}
	else if(errorCode == SA_DiceBotErrorMissingLabel)
	{
		userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Label missing.", nil), 
					  NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"One or more of the arguments lacked a label.", nil), 
					  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"This command requires that all arguments have labels.", nil)
					  };
	}

	
	return userInfo;
}
@end
