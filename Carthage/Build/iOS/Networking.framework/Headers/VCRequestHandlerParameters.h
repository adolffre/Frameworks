//
//  VCRequestHandlerParameters.h
//  Volo
//
//  Created by Peter Mosaad on 3/21/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "VCNetworking.h"
#import "WebServiceEndPoint.h"

static const NSTimeInterval kDefaultTimeOutInterval = 15;

@interface VCRequestHandlerParameters : NSObject <NSCoding>

@property(nonatomic, strong) WebServiceEndPoint * _Nonnull serviceEndPoint;
@property(nonatomic, strong) NSString * _Nonnull servicePath;
@property(nonatomic, assign) HTTPRequestMethod requestMethod;
@property(nonatomic, assign) HTTPPostBodyFormat postBodyFormat;
@property(nonatomic, strong) NSDictionary * _Nullable requestBodyParameters;
@property(nonatomic, assign) NSTimeInterval requestTimeOutInterval;
@property(nonatomic, assign) BOOL isRequestNeedsAuthentication;
@property(nonatomic, strong) Class _Nonnull expectedModelClass;
@property(nonatomic, readonly) NSString * _Nonnull requestURL;
@property(nonatomic, strong) NSDictionary * _Nullable requestHttpHeaders;

+ (instancetype _Nonnull)requestHandlerParametersForServiceEndPoint:(WebServiceEndPoint * _Nonnull)serviceEndPoint servicePath:(NSString * _Nonnull)servicePath forClassType:(Class _Nullable)classType;

+ (NSString * _Nullable)encodedURLForURL:(NSString * _Nullable)url;
+ (NSString *)appendLanguageAndSerializationAttributesToURL:(NSString * _Nonnull)url langID:(NSNumber * _Nonnull)langID;

@end
