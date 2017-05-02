
//
//  VCMantleParserHelper.m
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "VCMantleParserHelper.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/MTLJSONAdapter.h>
#import "AbstractModel.h"
#import "NSDate+Iso8601.h"

@implementation VCMantleParserHelper


+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    return dateFormatter;
}

+ (NSValueTransformer *)dateTransformerForFormat:(NSString *)format {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatterWithFormat:format] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatterWithFormat:format] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)stringToBoolTransformer {
    
    return [MTLValueTransformer transformerUsingReversibleBlock:^ id (NSString *boolString, BOOL *success, NSError **error) {
        if (boolString == nil) {
            return false;
        }
        if ([boolString isKindOfClass:NSNumber.class]) {
            return (NSNumber *)(boolString.boolValue ? kCFBooleanTrue : kCFBooleanFalse);;
        }
        if ([boolString isKindOfClass:[NSString class]]) {
            return (NSNumber *)([@[@"on", @"true", @"1", @"TRUE"] containsObject:boolString] ? kCFBooleanTrue : kCFBooleanFalse);;
        }
        return (NSNumber *)(kCFBooleanFalse);
    }];
}


+ (NSValueTransformer *)objectTransformerForObjectOfClass:(Class)aClass {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:aClass];
}

+ (NSValueTransformer *)arrayTransformerForArrayOfObjectcOfClass:(Class)aClass {
    return [MTLJSONAdapter arrayTransformerWithModelClass:aClass];
}

+ (NSValueTransformer *)transformerForObjectOfType:(NSString *)aClassType withPropertyType:(NSString *)propertyType {
    
    // Check for Legacy Mappers
    if([aClassType isEqualToString:@"FPMIso8601DateMapper"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
            return [NSDate dateWithIso8601String:dateString];
        }];
    } else if([aClassType isEqualToString:@"FPMAPIDayDateMapper"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
            return [NSDate dateWithTimeIntervalSince1970:[dateString doubleValue]];
        }];
    } else if([aClassType isEqualToString:@"FPMAPIDayDateMapper"]) {
        return [self dateTransformerForFormat:@"yyyy-MM-dd"];
    }
    
    Class class = NSClassFromString(aClassType);
    if (class) {
        // Objective C Types doesn't need a transformers
        if ([class isSubclassOfClass:[AbstractModel class]]) {
            if ([propertyType rangeOfString:@"Array"].location != NSNotFound) {
                return [self arrayTransformerForArrayOfObjectcOfClass:class];
            } else {
                return [self objectTransformerForObjectOfClass:class];
            }
        }
    }
    return nil;
}

+ (NSDictionary *)dictionaryForPLISTFileNamed:(NSString *)name {
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKeyForClassName:(NSString *)className {
    
    NSDictionary *dict = [self dictionaryForPLISTFileNamed:className];
    NSMutableDictionary *attributesServerKeyMap = nil;
    if (dict) {
        attributesServerKeyMap = [NSMutableDictionary dictionary];
        
        for (NSString *key in dict.allKeys) {
            
            NSString *serverKey = [[dict objectForKey:key] objectForKey:@"key"];
            [attributesServerKeyMap setObject:serverKey forKey:key];
        }
    }
    return attributesServerKeyMap;
}

+ (NSDictionary *)keysDataTypesMapForClassName:(NSString *)className {
    
    NSMutableDictionary *attributesClassTypeMap = [NSMutableDictionary dictionary];
    NSDictionary *dict = [self dictionaryForPLISTFileNamed:className];
    if (dict) {
        for (NSString *key in dict.allKeys) {
            
            NSString *dataType = ([[dict objectForKey:key] objectForKey:@"array_subtype"])? : [[dict objectForKey:key] objectForKey:@"type"];
            if (!dataType) {
                dataType = [[dict objectForKey:key] objectForKey:@"mapper"];
            }
            if ([dataType isEqualToString:@"FPMAPIBoolMaper"]) {
                dataType = @"NSNumber";
            }

            [attributesClassTypeMap setObject:dataType forKey:key];
        }
    }
    return attributesClassTypeMap;
}

@end
