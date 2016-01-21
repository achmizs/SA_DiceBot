//
//  SA_SettingsManager.m
//
//	Copyright (c) 2016 Said Achmiz.
//
//	This software is licensed under the MIT license.
//	See the file "LICENSE" for more information.

#import "SA_SettingsManager.h"

#import "SA_ErrorCatalog.h"

/*********************/
#pragma mark Constants
/*********************/

static NSString * const SA_CR_SETTING_VALUE					=	@"value";
static NSString * const SA_CR_SETTING_DEFAULT_VALUE			=	@"defaultValue";
static NSString * const SA_CR_SETTING_POSSIBLE_VALUES		=	@"possibleValues";
static NSString * const SA_CR_SETTING_INFO					=	@"info";

/************************************************/
#pragma mark - SA_SettingsManager class extension
/************************************************/

@interface SA_SettingsManager ()

@property (strong) NSMutableDictionary <NSString *, NSMutableDictionary *> *settings;

@end

/*****************************************************/
#pragma mark - SA_SettingsManager class implementation
/*****************************************************/

@implementation SA_SettingsManager

/**************************/
#pragma mark - Initializers
/**************************/

- (instancetype)initWithPath:(NSString *)settingsFilePath
{
	if(self = [super init])
	{
		self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsFilePath];
		if(self.settings)
		{
			[self.settings enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *setting, BOOL *stop) {
				if(setting[SA_CR_SETTING_VALUE] == nil && 
				   setting[SA_CR_SETTING_DEFAULT_VALUE] == nil && 
				   (setting[SA_CR_SETTING_POSSIBLE_VALUES] == nil || [setting[SA_CR_SETTING_POSSIBLE_VALUES] count] == 0))
				{
					// We have a problem!
					NSLog(NSLocalizedString(@"Setting \'%@\' has no initial value, default value, or list of possible values!", @"{setting name}"), key);
				}
				else 
				{
					self.settings[key] = [setting mutableCopy];
					
					// If we have a value and a default value, we're fine. If we 
					// have one of those but not the other, set the missing one to
					// the value of the other. If we have neither a value nor a
					// default value, set both of them to the first value in the 
					// "possible values" list.
					// (If we don't have a possible values list either, well, then
					//  we wouldn't be in this branch of the conditional.)
					
					if(setting[SA_CR_SETTING_VALUE] != nil && setting[SA_CR_SETTING_DEFAULT_VALUE] != nil)
					{
						// We're good to go; do nothing.
					}
					else if(setting[SA_CR_SETTING_VALUE] == nil && setting[SA_CR_SETTING_DEFAULT_VALUE] != nil)
					{
						self.settings[key][SA_CR_SETTING_VALUE] = setting[SA_CR_SETTING_DEFAULT_VALUE];
					}
					else if(setting[SA_CR_SETTING_VALUE] != nil && setting[SA_CR_SETTING_DEFAULT_VALUE] == nil)
					{
						self.settings[key][SA_CR_SETTING_DEFAULT_VALUE] = setting[SA_CR_SETTING_VALUE];
					}
					else // if(setting[SA_CR_SETTING_VALUE] != nil && setting[SA_CR_SETTING_DEFAULT_VALUE] != nil)
					{
						self.settings[key][SA_CR_SETTING_VALUE] = setting[SA_CR_SETTING_POSSIBLE_VALUES][0];
						self.settings[key][SA_CR_SETTING_DEFAULT_VALUE] = setting[SA_CR_SETTING_POSSIBLE_VALUES][0];
					}
				}
			}];
		}
		else
		{
			return nil;
		}
	}
	return self;
}

/****************************/
#pragma mark - Public methods
/****************************/

- (BOOL)setValue:(NSString *)value forSetting:(NSString *)setting error:(NSError **)error
{
	NSMutableDictionary *settingDict = self.settings[setting];
	
	if(settingDict == nil)
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorUnknownSetting 
						 inDomain:SA_DiceBotErrorDomain];
		return NO;
	}
	else
	{
		// If the provided value is nil or empty, reset the setting to its
		// default value.
		if(value == nil || [value isEqualToString:@""])
		{
			settingDict[SA_CR_SETTING_VALUE] = settingDict[SA_CR_SETTING_DEFAULT_VALUE];
			return YES;
		}
		// If the value is one of the permitted values for this setting, or the
		// setting offers no restrictions on possible values, set the new value.
		else if(settingDict[SA_CR_SETTING_POSSIBLE_VALUES] == nil || [settingDict[SA_CR_SETTING_POSSIBLE_VALUES] containsObject:value])
		{
			settingDict[SA_CR_SETTING_VALUE] = value;
			return YES;
		}
		// If it's not one of the permitted values, error.
		else
		{
			[SA_ErrorCatalog setError:error 
							 withCode:SA_DiceBotErrorBadValueForSetting 
							 inDomain:SA_DiceBotErrorDomain];
			return NO;
		}
	}
}

- (NSString *)valueforSetting:(NSString *)setting error:(NSError **)error
{
	if(self.settings[setting] == nil)
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorUnknownSetting 
						 inDomain:SA_DiceBotErrorDomain];
		return nil;
	}
	else
	{
		return self.settings[setting][SA_CR_SETTING_VALUE];
	}
}

- (void)resetAllSettingsToDefault
{
	[self.settings enumerateKeysAndObjectsUsingBlock:^(NSString *settingName, NSMutableDictionary *settingDict, BOOL *stop) {
		settingDict[SA_CR_SETTING_VALUE] = settingDict[SA_CR_SETTING_DEFAULT_VALUE];
	}];
}

- (NSDictionary *)allSettings
{
	return [self.settings copy];
}

- (NSString *)infoForSetting:(NSString *)setting error:(NSError **)error
{
	if(self.settings[setting] == nil)
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorUnknownSetting 
						 inDomain:SA_DiceBotErrorDomain];
		return nil;
	}
	else if(self.settings[setting][SA_CR_SETTING_INFO] == nil || [self.settings[setting][SA_CR_SETTING_INFO] isEqualToString:@""])
	{
		[SA_ErrorCatalog setError:error 
						 withCode:SA_DiceBotErrorNoSettingInfo 
						 inDomain:SA_DiceBotErrorDomain];
		return nil;
	}
	else
	{
		NSString *valueInfoString = [NSString stringWithFormat:NSLocalizedString(@" / VALUE: %@", @"{the current value of the setting}"), self.settings[setting][SA_CR_SETTING_VALUE]];
		NSString *defaultValueInfoString = [NSString stringWithFormat:NSLocalizedString(@" / DEFAULT: %@", @"{the default value of the setting}"), self.settings[setting][SA_CR_SETTING_DEFAULT_VALUE]];
		
		__block NSMutableString *possibleValuesInfoString = [NSMutableString string];
		if(self.settings[setting][SA_CR_SETTING_POSSIBLE_VALUES] != nil)
		{
			[possibleValuesInfoString appendFormat:NSLocalizedString(@" / POSSIBLE VALUES: ", nil)];
			[self.settings[setting][SA_CR_SETTING_POSSIBLE_VALUES] enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop)
			 {
				 [possibleValuesInfoString appendFormat:@"%@%@", 
				  value, 
				  ((idx != [self.settings[setting][SA_CR_SETTING_POSSIBLE_VALUES] count] - 1) ? @", " : @"")];
			 }];
		}
		
		NSString *fullInfoString = [NSString stringWithFormat:@"%@%@%@%@", 
									self.settings[setting][SA_CR_SETTING_INFO], 
									valueInfoString, 
									defaultValueInfoString, 
									possibleValuesInfoString];
		
		return fullInfoString;
	}
}

@end
