//
//  VCJSONParser.m
//  Volo
//
//  Created by Peter Mosaad on 3/18/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "VCJSONParser.h"
#import <Mantle/MTLJSONAdapter.h>

@implementation VCJSONParser

#pragma mark - APIObjectsParser

+ (id<JSONParser>)defaultParser {
    return [[self alloc] init];
}

- (id)parseObjectOfType:(Class)modelClass fromJSONResponse:(NSDictionary *)json error:(NSError **)error {

    if ([json isKindOfClass:[NSDictionary class]]) {
        if ([json objectForKey:@"data"]) {
            json = [json objectForKey:@"data"];
            return [self parseObjectOfType:modelClass fromJSONResponse:json error:error];
        }

        if ([json objectForKey:@"items"]) {
            json = [json objectForKey:@"items"];
            return [self parseObjectOfType:modelClass fromJSONResponse:json error:error];
        }
    }

    if ([json isEqual:[NSNull null]]) {
        return nil;
    }
    
    id parsedObject;
    if ([json isKindOfClass:[NSArray class]]) {
        parsedObject = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:(NSArray *)json error:error];
    } else {
        parsedObject = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:json error:error];
    }
    
    if(error) {
        NSLog(@"%@", *error);
    }
    return parsedObject;
}

- (NSDictionary *)jsonDictionaryForObject:(id)object error:(NSError **)error {
    
    NSDictionary *jsonDic = [MTLJSONAdapter JSONDictionaryFromModel:object error:error];
    if(error) {
        NSLog(@"%@", *error);
    }
    return jsonDic;
}


@end
