//
//  WebServiceEndPoint.m
//  Volo
//
//  Created by Hany Nady on 8/11/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "WebServiceEndPoint.h"

#define kBaseServiceURL @"base-service-url"
#define kDefaultHttpHeaders @"default-http-headers"

@implementation WebServiceEndPoint

+ (instancetype)serviceEndPointForURL:(NSString * _Nonnull)url defaultHttpHeaders:(NSDictionary * _Nullable)headers {
	
	WebServiceEndPoint* endPoint = [[WebServiceEndPoint alloc] init];
	endPoint.baseServiceURL = url;
	endPoint.defaultHTTPHeadaers = headers;
	return endPoint;
}

#pragma mark - NSCoderMethods

- (void)encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeObject:self.baseServiceURL forKey:kBaseServiceURL];
	[aCoder encodeObject:self.defaultHTTPHeadaers forKey:kDefaultHttpHeaders];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super init];
	if (self) {
		
		self.baseServiceURL = [aDecoder decodeObjectForKey:kBaseServiceURL];
		self.defaultHTTPHeadaers = [aDecoder decodeObjectForKey:kDefaultHttpHeaders];
		
	}
	return self;
}

@end
