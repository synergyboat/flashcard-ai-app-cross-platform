//
//  BenchmarkLogger.swift
//  flashcardaiapp
//
//  Created by Aman Nirala on 16/08/25.
//
import Foundation

@objc(BenchmarkLogger)
class BenchmarkLogger: NSObject {
  @objc
  func log(_ level: NSString, message: NSString) {
    let tag = "Benchmark"
    switch level as String {
      case "error": NSLog("[\(tag)] ❌ %@", message)
      case "warn":  NSLog("[\(tag)] ⚠️ %@", message)
      default:      NSLog("[\(tag)] %@", message)
    }
  }
}
