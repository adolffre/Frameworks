//
//  VCHTTPRequestExecuter.h
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCNetworking.h"

@interface VCHTTPRequestExecuter : NSObject <HTTPRequestExecuter>

+ (VCHTTPRequestExecuter *_Nonnull)defaultHTTPExecuter;

@end
