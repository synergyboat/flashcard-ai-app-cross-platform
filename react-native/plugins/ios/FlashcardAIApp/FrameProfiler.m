//
//  FrameProfiler.m
//  flashcardaiapp
//
//  Created by Aman Nirala on 15/08/25.
//

#import "FrameProfiler.h"
#import <React/RCTLog.h>

@interface FrameProfiler()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *frameTimings;
@property (nonatomic, assign) CFTimeInterval lastFrameTime;
@property (nonatomic, assign) BOOL isProfiling;
@end

@implementation FrameProfiler

RCT_EXPORT_MODULE();

- (instancetype)init {
  if (self = [super init]) {
    _frameTimings = [[NSMutableArray alloc] init];
    _isProfiling = NO;
  }
  return self;
}

// Start profiling frame times using CADisplayLink (most accurate on iOS)
RCT_EXPORT_METHOD(startProfiling)
{
  if (_isProfiling) {
    RCTLogWarn(@"Frame profiling already started");
    return;
  }
  
  _isProfiling = YES;
  [_frameTimings removeAllObjects];
  
  // Create display link to track actual refresh rate
  _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
  _displayLink.preferredFramesPerSecond = 0; // Use display's natural refresh rate
  
  _lastFrameTime = CACurrentMediaTime();
  [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  
  RCTLogInfo(@"Frame profiling started");
}

- (void)displayLinkCallback:(CADisplayLink *)displayLink {
  if (!_isProfiling) return;
  
  CFTimeInterval currentTime = CACurrentMediaTime();
  CFTimeInterval frameDuration = currentTime - _lastFrameTime;
  
  // Convert to milliseconds and store
  double frameTimeMs = frameDuration * 1000.0;
  [_frameTimings addObject:@(frameTimeMs)];
  
  _lastFrameTime = currentTime;
}

// Stop profiling and return frame timings
RCT_EXPORT_METHOD(stopProfiling:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (!_isProfiling) {
    reject(@"profiling_error", @"Frame profiling not started", nil);
    return;
  }
  
  _isProfiling = NO;
  [_displayLink invalidate];
  _displayLink = nil;
  
  // Return copy of frame timings
  NSArray *timings = [_frameTimings copy];
  resolve(timings);
  
  RCTLogInfo(@"Frame profiling stopped. Captured %lu frames", (unsigned long)[timings count]);
}

// Get current display refresh rate
RCT_EXPORT_METHOD(getDisplayRefreshRate:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  UIScreen *mainScreen = [UIScreen mainScreen];
  NSInteger maxFPS = mainScreen.maximumFramesPerSecond;
  
  resolve(@{
    @"refreshRate": @(maxFPS),
    @"targetFrameTime": @(1000.0 / maxFPS)
  });
}

// iOS 15+: report preferredFrameRateRange if available
RCT_EXPORT_METHOD(getDisplayCapabilities:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  UIScreen *screen = UIScreen.mainScreen;
  NSInteger maxFPS = screen.maximumFramesPerSecond;
  NSMutableDictionary *dict = [@{
    @"maxRefreshRate": @(maxFPS),
    @"supportsHighRefreshRate": @(maxFPS > 60)
  } mutableCopy];

  if (@available(iOS 15.0, *)) {
    // CADisplayLink's default range usually reflects current constraints
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(dummy:)];
    CAFrameRateRange range = link.preferredFrameRateRange;
    [link invalidate];
    dict[@"minPreferred"] = @(range.minimum);
    dict[@"maxPreferred"] = @(range.maximum);
    dict[@"preferred"]    = @(range.preferred);
  }

  resolve(dict);
}

- (void)dummy:(CADisplayLink *)link { /* no-op */ }

@end



