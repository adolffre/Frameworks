//
//  AbstractModel+MantleSerialization.m
//  Volo
//
//  Created by Peter Mosaad on 3/18/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "AbstractModel+MantleSerialization.h"
#import "VCMantleParserHelper.h"
#import "NSObject+Properties.h"

@implementation AbstractModel (MantleSerialization)

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *map = [VCMantleParserHelper JSONKeyPathsByPropertyKeyForClassName:NSStringFromClass(self)];
    return map;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    NSDictionary *map = [VCMantleParserHelper keysDataTypesMapForClassName:NSStringFromClass(self)];
    NSString *classTypeFromPlistFile = [map valueForKey:key];
    NSString *classTypeFromObject = [NSString stringWithUTF8String:[self typeOfPropertyNamed:key]];
    
    NSValueTransformer *valueTransformer = [VCMantleParserHelper transformerForObjectOfType:classTypeFromPlistFile withPropertyType:classTypeFromObject];
    return valueTransformer;
}

/* 
 On Mantle Documentaion its mentioned for - (NSString *)description and - (BOOL)isEqual:(id)object :
    // Note that this may lead to infinite loops if the receiver holds a circular
    // reference to another MTLModel and both use the default behavior.
    // It is recommended to override -description in this scenario.
 So Below we override these methods to avoid infinite loops.
*/

- (NSString *)description {
    
    NSError *error;
    NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    return [NSString stringWithFormat:@"%@ \n %@", NSStringFromClass(self.class), dictionary];
}

- (BOOL)isEqual:(id)object {
    
    if ([object conformsToProtocol:@protocol(MTLJSONSerializing)]) {
        NSError *error;
        NSDictionary *selfDictionary = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
        NSDictionary *otherDictionary = [MTLJSONAdapter JSONDictionaryFromModel:object error:&error];
        return [selfDictionary isEqual:otherDictionary];
    }
    return NO;
}

@end
