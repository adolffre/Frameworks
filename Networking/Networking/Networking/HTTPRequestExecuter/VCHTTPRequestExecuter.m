//
//  VCHTTPRequestExecuter.m
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "VCHTTPRequestExecuter.h"
#import <AFNetworking/AFNetworking.h>

typedef void (^DataTaskHEADSuccessBlock)(NSURLSessionDataTask * _Nonnull task);
typedef void (^DataTaskSuccessBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
typedef void (^DataTaskFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);


@interface VCHTTPRequestExecuter()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSMutableDictionary *runningDataTasks;

@end

@implementation VCHTTPRequestExecuter

+ (VCHTTPRequestExecuter *)defaultHTTPExecuter  {
    
    static VCHTTPRequestExecuter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[VCHTTPRequestExecuter alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *set = [NSMutableSet setWithSet:self.sessionManager.responseSerializer.acceptableContentTypes];
    [set addObject:@"text/plain"];
    self.sessionManager.responseSerializer.acceptableContentTypes = set;

    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    self.runningDataTasks = [NSMutableDictionary dictionary];
    return self;
}

#pragma mark - Private

- (void)setHttpHeaders:(NSDictionary *)headers {
    [self.sessionManager.requestSerializer clearAuthorizationHeader];
    for (NSString *headerKey in headers.allKeys) {
        [self.sessionManager.requestSerializer setValue:[headers valueForKey:headerKey] forHTTPHeaderField:headerKey];
    }
}

// This method is implemented to remove data tasks that have been cancelled by its request handlers
- (void)cleanupDataTasks {
    @synchronized(self) {
        if (!self.runningDataTasks.allKeys.count) {
            return;
        }
        NSMutableArray *taskKeysToBeRemoved = [NSMutableArray array];
        for (NSString *key in self.runningDataTasks.allKeys) {
            NSURLSessionDataTask *task = [self.runningDataTasks objectForKey:key];
            if (task.state != NSURLSessionTaskStateRunning) {
                [taskKeysToBeRemoved addObject:key];
            }
        }
        if (taskKeysToBeRemoved.count) {
            [self.runningDataTasks removeObjectsForKeys:taskKeysToBeRemoved];
        }
    }
}

- (NSURLSessionDataTask *)executeRequest:(NSString *)URLString
                              httpMethod:(HTTPRequestMethod)requestMethod
                  requestTimeOutInterval:(NSTimeInterval)timeOutInterval
                              parameters:(id)parameters
                          postBodyFormat:(HTTPPostBodyFormat)postBodyFormat
                             httpHeaders:(NSDictionary *)httpHeaders
                         completionQueue:(dispatch_queue_t)completionQueue
                                 success:(void (^)(id responseObject))success
                                 failure:(void (^)(NSError *error))failure {
    
    if (postBodyFormat == HTTPPostBodyFormatURLFormData) {
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else {
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }    
    [self setHttpHeaders:httpHeaders];
    
    self.sessionManager.completionQueue = completionQueue;
    
    self.sessionManager.requestSerializer.timeoutInterval = timeOutInterval;
    
    NSURLSessionDataTask *dataTask = nil;
    
    DataTaskHEADSuccessBlock headSuccessBlock  = ^(NSURLSessionDataTask * _Nonnull task) {
        NSHTTPURLResponse *response = ((NSHTTPURLResponse *)[task response]);
        success([response allHeaderFields]);
        [self.runningDataTasks removeObjectForKey:URLString];
        [self cleanupDataTasks];
    };
    
    DataTaskSuccessBlock successBlock  = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [self.runningDataTasks removeObjectForKey:URLString];
        [self cleanupDataTasks];
    };
    DataTaskFailureBlock failureBlock  = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [self.runningDataTasks removeObjectForKey:URLString];
        [self cleanupDataTasks];
    };

    switch (requestMethod) {
        case HTTPRequestMethodPOST:
            dataTask = [self.sessionManager POST:URLString parameters:parameters progress:nil success:successBlock failure:failureBlock];
            break;
        case HTTPRequestMethodPUT:
            dataTask = [self.sessionManager PUT:URLString parameters:parameters success:successBlock failure:failureBlock];
            break;
        case HTTPRequestMethodDELETE:
            dataTask = [self.sessionManager DELETE:URLString parameters:parameters success:successBlock failure:failureBlock];
            break;
        case HTTPRequestMethodHEAD:
            dataTask = [self.sessionManager HEAD:URLString parameters:parameters success:headSuccessBlock failure:failureBlock];
            break;
        default:
            dataTask = [self.sessionManager GET:URLString parameters:parameters progress:nil success:successBlock failure:failureBlock];
            break;
    }
    if (dataTask) {
        [self.runningDataTasks setObject:dataTask forKey:URLString];
    }
    return dataTask;
}


@end
