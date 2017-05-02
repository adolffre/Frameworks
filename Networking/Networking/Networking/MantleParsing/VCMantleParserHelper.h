//
//  VCMantleParserHelper.h
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCMantleParserHelper : NSObject

+ (NSValueTransformer *)dateTransformerForFormat:(NSString*)format;
+ (NSValueTransformer *)objectTransformerForObjectOfClass:(Class)aClass;
+ (NSValueTransformer *)arrayTransformerForArrayOfObjectcOfClass:(Class)aClass;
+ (NSValueTransformer *)stringToBoolTransformer;
+ (NSValueTransformer *)transformerForObjectOfType:(NSString*)aClassType withPropertyType:(NSString*)propertyType;


+ (NSDictionary*)JSONKeyPathsByPropertyKeyForClassName:(NSString*)className;
+ (NSDictionary*)keysDataTypesMapForClassName:(NSString*)className;

@end
