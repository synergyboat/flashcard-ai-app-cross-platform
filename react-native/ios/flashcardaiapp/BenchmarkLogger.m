//
//  BenchmarkLogger.m
//  flashcardaiapp
//
//  Created by Aman Nirala on 16/08/25.
//
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(BenchmarkLogger, NSObject)
RCT_EXTERN_METHOD(log:(NSString *)level message:(NSString *)message)
@end

