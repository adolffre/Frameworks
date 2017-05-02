//
//  VCJSONParser.h
//  Volo
//
//  Created by Peter Mosaad on 3/18/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCNetworking.h"

@interface VCJSONParser : NSObject <JSONParser>

+ (id<JSONParser>)defaultParser;

@end
