//
//  VCRequestHandler.h
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCNetworking.h"
#import "VCHTTPRequestExecuter.h"
#import "VCJSONParser.h"
#import "VCRequestHandlerParameters.h"

typedef void(^RequestHandlerSuccessBlock)(id _Nullable responseObject);
typedef void(^RequestHandlerFailureBlock)(NSError  * _Nullable error);

@interface VCRequestHandler : NSObject

- (instancetype _Nonnull)initWithHTTPRequestExecuter:(id<HTTPRequestExecuter> _Nonnull)requestExecuter
                                              parser:(id<JSONParser> _Nonnull)parser
                                   requestParameters:(VCRequestHandlerParameters * _Nonnull)parameters;

- (instancetype _Nonnull)initWithParameters:(VCRequestHandlerParameters * _Nonnull)parameters;
+ (instancetype _Nonnull)defaultRequestHandlerWithParameters:(VCRequestHandlerParameters * _Nonnull)parameters;

@property (nonatomic, strong) VCRequestHandlerParameters * _Nonnull requestParameters;
@property (nonatomic, assign) BOOL preventRetry;

- (void)executeRequestSuccess:(RequestHandlerSuccessBlock _Nullable)success
                      failure:(RequestHandlerFailureBlock _Nullable)failure;

- (void)retry;
/// Cancel the currently executing request
- (void)cancel;
@end
