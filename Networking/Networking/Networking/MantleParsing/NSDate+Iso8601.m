#import "NSDate+Iso8601.h"

@implementation NSDate (Iso8601)

+(NSISO8601DateFormatter *)dateFormatter {
    static dispatch_once_t onceToken;
    static NSISO8601DateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSISO8601DateFormatter alloc] init];
        //dateFormatter.includeTime = YES;
    });
    return dateFormatter;
}

+ (NSDate *)dateWithIso8601String:(NSString *)str {
    return [[self dateFormatter] dateFromString:str];
}

- (NSString *)iso8601String {
    return [[self.class dateFormatter] stringFromDate:self];
}

@end
