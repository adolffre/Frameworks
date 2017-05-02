//
//  VCNetworking.h
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef VCNetworking_h
#define VCNetworking_h

typedef enum HTTPRequestMethod {
    HTTPRequestMethodGET,
    HTTPRequestMethodPOST,
    HTTPRequestMethodPUT,
    HTTPRequestMethodDELETE,
    HTTPRequestMethodHEAD,
} HTTPRequestMethod;

typedef enum HTTPPostBodyFormat {
    HTTPPostBodyFormatJSON,
    HTTPPostBodyFormatURLFormData
} HTTPPostBodyFormat;

@protocol HTTPRequestExecuter <NSObject>

/**
 Executes HTTP Request using provided parameters
 @param completionQueue completionQueue is The dispatch queue to be used for calling completion handlers. Pass nil to user the main queue.
 This is mainly used to avoid perform parsing on the main Thread. When passing a completionQueue Make sure that UI updates is perfomred ONLY on MainThread.
 @returns NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)executeRequest:(NSString *)URLString
                              httpMethod:(HTTPRequestMethod)requestMethod
                  requestTimeOutInterval:(NSTimeInterval)timeOutInterval
                              parameters:(id)parameters
                          postBodyFormat:(HTTPPostBodyFormat)postBodyFormat
                             httpHeaders:(NSDictionary *)httpHeaders
                         completionQueue:(dispatch_queue_t)completionQueue
                                 success:(void (^)(id responseObject))success
                                 failure:(void (^)(NSError *error))failure;

@end

@protocol JSONParser <NSObject>

- (id)parseObjectOfType:(Class)modelClass fromJSONResponse:(NSDictionary *)json error:(NSError **)error;

@optional
- (NSDictionary *)jsonDictionaryForObject:(id)object error:(NSError **)error;

@end


#endif /* VCNetworking_h */
