
#import <UIKit/UIKit.h>

/**
 Provides extensions to `NSDate` for converting ISO 8601 dates string into NSDate and vice versa
 */
@interface NSDate (Iso8601)

/**
 Returns a new date represented by an ISO8601 string.
 @param iso8601String An ISO8601 string
 @return Date represented by the ISO8601 string
 */
+ (NSDate *)dateWithIso8601String:(NSString *)iso8601String;

- (NSString *)iso8601String;

@end
