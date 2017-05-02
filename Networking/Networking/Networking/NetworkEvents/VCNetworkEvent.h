//
//  VCNetworkEvent.h
//  Volo
//
//  Created by Peter Mosaad on 1/31/17.
//  Copyright © 2017 Foodora. All rights reserved.
//

#import "VCNetworking.h"

@interface VCNetworkEvent : NSObject

@property (nonatomic, strong) NSString *URL;
@property (nonatomic, assign) HTTPRequestMethod httpMethod;
@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, assign) NSUInteger bytesSent;
@property (nonatomic, assign) NSUInteger bytesReceived;
/// @brief Time between request sent and response received
@property (nonatomic, assign) NSTimeInterval responseTime;
/// @brief Time between response received and parse completed
@property (nonatomic, assign) NSTimeInterval parsingTime;
/// @brief Time between request sent and response received and parsed --> responseTime + parsingTime
@property (nonatomic, readonly) NSTimeInterval requestTime;

@end
