//
//  VCRequestHandler.m
//  Volo
//
//  Created by Peter Mosaad on 3/17/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "VCRequestHandler.h"
#import "NSError+AFNetworkErrors.h"
#import "VCNetworkEvent.h"

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")


#define kVoloErrorCodesToBeRetried @[@(-1009), @(-1005), @(500), @(404)]

@interface VCRequestHandler ()

@property (nonatomic, strong) id<HTTPRequestExecuter> requestExecuter;
@property (nonatomic, strong) id<JSONParser> parser;

@property (nonatomic, strong) NSURLSessionDataTask *requestDataTask;
@property (nonatomic, strong) NSDate *requestStartDate;

@property (nonatomic, strong) RequestHandlerSuccessBlock successBlock;
@property (nonatomic, strong) RequestHandlerFailureBlock failureBlock;

@property (nonatomic, assign) NSInteger numberOfSilentRetries;

@end

@implementation VCRequestHandler

- (void)appendAuthenticationHeadersIfNeeded {
	/*if (self.requestParameters.isRequestNeedsAuthentication) {
		NSMutableDictionary *allHeaders = self.requestParameters.requestHttpHeaders.mutableCopy;
		// Add authentication headers if needed
		NSString *accessToken = [VCOAuthProvider authenticationToken];
		if (accessToken && accessToken.length) {
			NSString *tokenValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
			if (allHeaders) {
				[allHeaders setObject:tokenValue forKey:@"Authorization"];
			} else {
				allHeaders = [NSMutableDictionary dictionaryWithObject:tokenValue forKey:@"Authorization"];
			}
		}
		self.requestParameters.requestHttpHeaders = [NSDictionary dictionaryWithDictionary:allHeaders];
	}*/
}

- (instancetype _Nonnull)initWithHTTPRequestExecuter:(id<HTTPRequestExecuter> _Nonnull)requestExecuter
                                              parser:(id<JSONParser> _Nonnull)parser
                                   requestParameters:(VCRequestHandlerParameters * _Nonnull)parameters {
    self = [super init];
    
    if (self) {
        
        self.requestExecuter = requestExecuter;
        self.parser = parser;
        self.requestParameters = parameters;
		[self appendAuthenticationHeadersIfNeeded];
    }
    return self;
}

- (instancetype _Nonnull)initWithParameters:(VCRequestHandlerParameters * _Nonnull)parameters {
    
    return [self initWithHTTPRequestExecuter:[VCHTTPRequestExecuter defaultHTTPExecuter]
                                      parser:[VCJSONParser defaultParser]
                           requestParameters:parameters];
}

+ (instancetype _Nonnull)defaultRequestHandlerWithParameters:(VCRequestHandlerParameters * _Nonnull)parameters {
    
    return [[VCRequestHandler alloc] initWithHTTPRequestExecuter:[VCHTTPRequestExecuter defaultHTTPExecuter]
                                                          parser:[VCJSONParser defaultParser]
                                               requestParameters:parameters];
}

#pragma mark - HTTPRequest Attributes

- (void)retry {
    [self executeRequestSuccess:self.successBlock failure:self.failureBlock];
}

- (void)cancel {
    [self.requestDataTask cancel];
    self.requestDataTask = nil;
    [self removeFromRequestHandlersPool];
}


- (BOOL)errorCodeShouldBeRetried:(NSInteger)errorCode {
    return (errorCode == -1009 ||
            errorCode == -1005 ||
            errorCode ==   500 ||
            errorCode ==   400  );
}

- (void)callSuccessHanlderWithObject:(id)object {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.successBlock) {
            self.successBlock(object);
        }
    });
}

- (void)callFailureHanlderWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.failureBlock) {
            self.failureBlock(error);
        }
    });
}

- (void)fireNetworkEvent:(VCNetworkEvent *)event {
    ////****[[VCTrackingManager sharedManager] trackEvent:event];
}

- (void)logError:(NSError *)error withSerializedErrorData:(NSDictionary *)serializedErrorData {
    /********* Crittercism Logging ********/
    NSMutableDictionary *errorToBeLoggedInfo = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ request failed", NSStringFromClass([self class])] forKey:NSLocalizedDescriptionKey];
    NSDictionary *errorInfo = (serializedErrorData)? : error.userInfo;
    NSMutableString *failureReason = [NSMutableString string];
    [failureReason appendFormat:@"Request URL: %@\n", self.requestParameters.requestURL];
    if (self.requestParameters.requestBodyParameters) {
        [failureReason appendString:@"Body Params:\n"];
        for (NSString *key in self.requestParameters.requestBodyParameters.allKeys) {
            [failureReason appendFormat:@"%@ : %@\n", key, [errorInfo objectForKey:key]];
        }
    }
    for (NSString *key in errorInfo.allKeys) {
        [failureReason appendFormat:@"%@ : %@\n", key, [errorInfo objectForKey:key]];
    }
    [errorToBeLoggedInfo setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
    ////****[Crittercism logError:[NSError errorWithDomain:error.domain code:error.httpResponse.statusCode userInfo:errorToBeLoggedInfo]];
    /********* Crittercism Logging ********/
}

- (VCNetworkEvent *)createNetworkEventForCurrentRequestWithResponseTime:(NSTimeInterval)responseTime parseTime:(NSTimeInterval)parsingTime {
    VCNetworkEvent *event = [VCNetworkEvent new];
    event.URL = self.requestDataTask.originalRequest.URL.absoluteString;
    event.httpMethod = self.requestParameters.requestMethod;
    event.responseTime = [self.requestStartDate timeIntervalSinceNow];
    event.bytesSent = self.requestDataTask.countOfBytesSent;
    event.bytesReceived = self.requestDataTask.countOfBytesReceived;
    event.responseCode = ([self.requestDataTask.response isKindOfClass:[NSHTTPURLResponse class]])? ((NSHTTPURLResponse *)(self.requestDataTask.response)).statusCode : -1;
    return event;
}

- (void)executeRequestSuccess:(void (^)(id responseObject))success
                      failure:(void (^)(NSError *error))failure {
    self.successBlock = success;
    self.failureBlock = failure;
    
    [self addToRequestHandlersPool];
    self.requestStartDate = [NSDate date];
    weakify(self);
    self.requestDataTask = [self.requestExecuter executeRequest:self.requestParameters.requestURL
                                                     httpMethod:self.requestParameters.requestMethod
                                         requestTimeOutInterval:self.requestParameters.requestTimeOutInterval
                              parameters:self.requestParameters.requestBodyParameters
                            postBodyFormat:self.requestParameters.postBodyFormat
                             httpHeaders:self.requestParameters.requestHttpHeaders
                            completionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                 success:^(id responseObject) {
                                     
                                     NSTimeInterval responseTime = [[NSDate date] timeIntervalSinceDate:self.requestStartDate];
                                     NSTimeInterval parsingTime = 0;
                                     
                                     strongify(self);
                                     if (self.requestParameters.requestMethod == HTTPRequestMethodHEAD) {// Head Requests contains no response body, Only Response Headers
                                         [self callSuccessHanlderWithObject:responseObject];
                                     } else {
                                         if (self.requestParameters.expectedModelClass) {
                                             NSError *parseError = nil;
                                             id parsedObject = [self.parser parseObjectOfType:self.requestParameters.expectedModelClass fromJSONResponse:responseObject error:&parseError];
                                             if (parseError) {
                                                 [self callFailureHanlderWithError:parseError];
                                                 ////****[Crittercism logError:parseError];
                                             } else {
                                                 parsingTime = [[NSDate date] timeIntervalSinceDate:self.requestStartDate] - responseTime;
                                                 [self callSuccessHanlderWithObject:parsedObject];
                                             }
                                         } else{
                                             [self callSuccessHanlderWithObject:responseObject];
                                         }
                                     }
                                     ///********* Tracking ********
                                     VCNetworkEvent *event = [self createNetworkEventForCurrentRequestWithResponseTime:responseTime parseTime:parsingTime];
                                     [self fireNetworkEvent:event];
                                     ///********* ******** ********
                                     [self removeFromRequestHandlersPool];
                                     
                                 } failure:^(NSError *error) {
                                     strongify(self);
                                     if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                                         // So this request is cancelled and no need to notify with a failure handler
                                         // No Need to remvoe self (the RequestHandler) from Request handlers pool, coz cancelling a request already removing it from the pool
                                         return ;
                                     }
                                     
                                     /////********* Tracaking ********
                                     NSTimeInterval responseTime = [[NSDate date] timeIntervalSinceDate:self.requestStartDate];
                                     VCNetworkEvent *event = [self createNetworkEventForCurrentRequestWithResponseTime:responseTime parseTime:0];
                                     [self fireNetworkEvent:event];
                                      /////********* ******** ********
                                     
                                     // Check If API error then get API response
                                     NSData *errorData = [error urlFailureResponseData];
                                     NSDictionary *serializedErrorData = nil;
                                     if (errorData) {
                                         serializedErrorData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                                         ////****error = [NSError errorFromApiException:[serializedErrorData objectForKey:@"data"]];
                                     }
                                     
                                     // Log Error
                                     [self logError:error withSerializedErrorData:serializedErrorData];
                                     
                                     // To Handle Retry request, Attaching the Request Handler to the Error, So easily we could call [request retry]
                                     BOOL shouldRetryRequestSilently = [self canPerformRetrySilentlyForError:error];
                                     if (shouldRetryRequestSilently) {
                                         [self performSilentRetry];
                                     } else  if ([self shouldRetryRequestWithError:error]) {
                                         [self showRetryPromptForError:error];
                                     } else {
                                         [self handleRequestFailureWithError:error];
                                     }
                                 }];
}

- (void)handleRequestFailureWithError:(NSError *)error {
    NSData *errorData = [error urlFailureResponseData];
    if (errorData) {
        NSDictionary *serializedErrorData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        if (serializedErrorData) {
            ////****error = [NSError errorFromApiException:serializedErrorData];
        }
    }
    [self callFailureHanlderWithError:error];
    [self removeFromRequestHandlersPool];
}

#pragma mark - RetryPolicy

static const NSInteger kMaxNumberOfSilentRetries = 6;
static const NSTimeInterval kSilentRetryDelay = 0.5;

- (BOOL)shouldRetryRequestWithError:(NSError *)error {
    BOOL shouldRetryRequest = !self.preventRetry &&  ([self errorCodeShouldBeRetried:error.httpResponse.statusCode] || ([error.domain isEqualToString:NSURLErrorDomain]));
    return shouldRetryRequest;
}

- (BOOL)canPerformRetrySilentlyForError:(NSError *)error {
    BOOL shouldRetryRequest = [self shouldRetryRequestWithError:error];
    if (shouldRetryRequest) {
        return self.numberOfSilentRetries < kMaxNumberOfSilentRetries;
    }
    return NO;
}

- (void)showRetryPromptForError:(NSError *)error {
    weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        strongify(self)
        [self askUserIfShoulRetryRequest];
    });
}

- (void)performSilentRetry {
    weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSilentRetryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        strongify(self)
        self.numberOfSilentRetries ++;
        [self retry];
    });
}

- (void)askUserIfShoulRetryRequest {
    
    /*
    NSString *cancelButtonTitle = translate(@"Cancel", @"NEXTGEN_CANCEL");
    NSString *retryButtonTitle = translate(@"YES", @"NEXTGEN_YES");
    NSString *errorMessage = translate(@"Unexpected error occurred! Retry?",@"NEXTGEN_RETRY_MESSAGE");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self)
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        @strongify(self)
        [self handleRequestFailureWithError:nil];
    }];
    [alertController addAction:cancelAction];

    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:retryButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        @strongify(self)
        self.numberOfSilentRetries = 0;
        [self retry];
    }];
    [alertController addAction:retryAction];
    
    [[[UIApplication sharedApplication] actualRootViewConrtoller] presentViewController:alertController animated:YES completion:nil];
    */
}

#pragma mark - RequestHandlers Pool

+ (NSMutableArray *)requestHandlersPool {
    
    static NSMutableArray *requestHandlersPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        requestHandlersPool = [[NSMutableArray alloc] init];
    });
    return requestHandlersPool;
}

- (void)addToRequestHandlersPool {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *pool = [[self class] requestHandlersPool];
        if (self && ![pool containsObject:self]) {
            [pool addObject:self];
        }
    });
}

- (void)removeFromRequestHandlersPool {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *pool = [[self class] requestHandlersPool];
        if ([pool containsObject:self]) {
            [pool removeObject:self];
        }
    });
}

@end
