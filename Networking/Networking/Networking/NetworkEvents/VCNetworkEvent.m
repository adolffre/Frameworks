//
//  VCNetworkEvent.m
//  Volo
//
//  Created by Peter Mosaad on 1/31/17.
//  Copyright © 2017 Foodora. All rights reserved.
//

#import "VCNetworkEvent.h"

@implementation VCNetworkEvent


- (instancetype)init {
    self = [super init];
    return self;
}

- (NSTimeInterval)requestTime {
    return self.responseTime + self.parsingTime;
}

@end
