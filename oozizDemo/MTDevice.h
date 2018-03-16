//
//  MTDevice.h
//  oozizDemo
//
//  Created by MISWAY on 3/16/18.
//  Copyright (c) 2018年 MISWAY All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDevice : NSObject
@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) int batteryLevel;
@property (nonatomic) float temperatureLevel;
@property (nonatomic) float humidityLevel;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, strong) NSString *pressType;

@end
