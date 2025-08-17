//
//  MemoryProfiler.m
//  flashcardaiapp
//
//  Created by Aman Nirala on 15/08/25.
//
#import "MemoryProfiler.h"
#import <React/RCTLog.h>
#import <mach/mach.h>
#import <mach/task_info.h>

@implementation MemoryProfiler

RCT_EXPORT_MODULE();

// Primary method - return RSS (resident_size) for Flutter parity
RCT_EXPORT_METHOD(getCurrentMemoryUsage:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  // Get RSS via MACH_TASK_BASIC_INFO (equivalent to Flutter's ProcessInfo.currentRss)
  mach_task_basic_info_data_t basicInfo;
  mach_msg_type_number_t basicCount = MACH_TASK_BASIC_INFO_COUNT;
  kern_return_t kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO,
                               (task_info_t)&basicInfo, &basicCount);
  
  if (kr != KERN_SUCCESS) {
    reject(@"MEMORY_ERROR", @"Failed to get RSS memory info", nil);
    return;
  }

  uint64_t residentSizeBytes = basicInfo.resident_size;
  double residentSizeMB = residentSizeBytes / (1024.0 * 1024.0);

  resolve(@{
    // Primary metric for benchmarking (matches Flutter's RSS)
    @"totalAppMemoryBytes": @(residentSizeBytes),
    @"totalAppMemoryMB": @(residentSizeMB),
    
    // Raw metrics for debugging
    @"residentSize": @(residentSizeBytes),
    @"timestamp": @((long long)([[NSDate date] timeIntervalSince1970] * 1000.0))
  });
}

// Optional detailed method for analysis (not used in benchmarks)
RCT_EXPORT_METHOD(getDetailedMemoryInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  // Get RSS
  mach_task_basic_info_data_t basicInfo;
  mach_msg_type_number_t basicCount = MACH_TASK_BASIC_INFO_COUNT;
  kern_return_t kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO,
                               (task_info_t)&basicInfo, &basicCount);

  // Get phys_footprint (iOS-specific memory metric)
  task_vm_info_data_t vmInfo;
  mach_msg_type_number_t vmCount = TASK_VM_INFO_COUNT;
  kern_return_t kr2 = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &vmCount);

  NSMutableDictionary *result = [NSMutableDictionary new];
  
  if (kr == KERN_SUCCESS) {
    uint64_t residentSize = basicInfo.resident_size;
    result[@"residentSize"] = @(residentSize);
    result[@"totalAppMemoryBytes"] = @(residentSize);  // Primary metric
    result[@"totalAppMemoryMB"] = @(residentSize / (1024.0 * 1024.0));
  }
  
  if (kr2 == KERN_SUCCESS) {
    // iOS-specific metrics for analysis
    result[@"physFootprint"] = @(vmInfo.phys_footprint);
    result[@"virtualSize"] = @(vmInfo.virtual_size);
    result[@"internal"] = @(vmInfo.internal);
    result[@"external"] = @(vmInfo.external);
    result[@"compressed"] = @(vmInfo.compressed);
  }
  
  if (kr != KERN_SUCCESS && kr2 != KERN_SUCCESS) {
    reject(@"MEMORY_ERROR", @"Failed to get memory info", nil);
    return;
  }
  
  result[@"timestamp"] = @((long long)([[NSDate date] timeIntervalSince1970] * 1000.0));
  resolve(result);
}

@end