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

// Return RSS as the primary metric for parity with Flutter
RCT_EXPORT_METHOD(getCurrentMemoryUsage:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  // RSS via MACH_TASK_BASIC_INFO
  mach_task_basic_info_data_t basicInfo;
  mach_msg_type_number_t basicCount = MACH_TASK_BASIC_INFO_COUNT;
  kern_return_t kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO,
                               (task_info_t)&basicInfo, &basicCount);
  if (kr != KERN_SUCCESS) {
    reject(@"memory_error", @"Failed to get MACH_TASK_BASIC_INFO", nil);
    return;
  }
  uint64_t residentSize = basicInfo.resident_size;

  // phys_footprint via TASK_VM_INFO (diagnostic only)
  task_vm_info_data_t vmInfo;
  mach_msg_type_number_t vmCount = TASK_VM_INFO_COUNT;
  kr = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &vmCount);
  uint64_t physFootprint = 0;
  uint64_t virtualSize   = 0;
  if (kr == KERN_SUCCESS) {
    physFootprint = vmInfo.phys_footprint;
    virtualSize   = vmInfo.virtual_size;
  }

  resolve(@{
    // Use residentSize for parity
    @"residentSize": @(residentSize),
    // Keep these for visibility only
    @"totalPSS": @(physFootprint),
    @"virtualSize": @(virtualSize),
    @"timestamp": @((long long)([[NSDate date] timeIntervalSince1970] * 1000.0))
  });
}

RCT_EXPORT_METHOD(getDetailedMemoryInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  // Same pattern: provide both RSS and footprint
  mach_task_basic_info_data_t basicInfo;
  mach_msg_type_number_t basicCount = MACH_TASK_BASIC_INFO_COUNT;
  kern_return_t kr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO,
                               (task_info_t)&basicInfo, &basicCount);

  task_vm_info_data_t vmInfo;
  mach_msg_type_number_t vmCount = TASK_VM_INFO_COUNT;
  kern_return_t kr2 = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &vmCount);

  if (kr != KERN_SUCCESS && kr2 != KERN_SUCCESS) {
    reject(@"memory_error", @"Failed to get memory info", nil);
    return;
  }

  NSMutableDictionary *result = [NSMutableDictionary new];
  if (kr == KERN_SUCCESS) {
    result[@"residentSize"] = @(basicInfo.resident_size);
  }
  if (kr2 == KERN_SUCCESS) {
    result[@"physFootprint"] = @(vmInfo.phys_footprint);
    result[@"virtualSize"] = @(vmInfo.virtual_size);
    result[@"internal"] = @(vmInfo.internal);
    result[@"external"] = @(vmInfo.external);
    result[@"compressed"] = @(vmInfo.compressed);
    result[@"rssCompressed"] = @(vmInfo.compressed);
  }
  result[@"timestamp"] = @((long long)([[NSDate date] timeIntervalSince1970] * 1000.0));

  resolve(result);
}

@end
