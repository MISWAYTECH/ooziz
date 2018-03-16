//
//  MTDeviceManager.h
//  oozizSDK
//
//  Created by mac on 3/15/18.
//  Copyright © 2018 MISWAY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MTControlCommandType) {
    MTControlCommandSoundOrMute,
    MTControlCommandPowerOff,
};

typedef NSString * const MTNotificationName;
typedef NSString * const MTDiscoveredNewDeviceKey;

extern MTNotificationName MTDevicePowerOffNotification;
extern MTNotificationName MTDevicePowerOnNotification;

extern MTNotificationName MTDiscoveredNewDeviceNotification;
extern MTNotificationName MTDeviceConnectedNotification;
extern MTNotificationName MTDeviceDisconnectedNotification;

extern MTNotificationName MTDeviceUpdateBatteryLevelNotification;
extern MTNotificationName MTDeviceUpdateHumidityNotification;
extern MTNotificationName MTDeviceUpdateTemperatureNotification;
extern MTNotificationName MTDeviceUpdateRSSINotification;

extern MTNotificationName MTDeviceSinglePressedNotification;
extern MTNotificationName MTDeviceDoublePressedNotification;
extern MTNotificationName MTDeviceLongPressedNotification;

extern MTNotificationName MTCameraScaleUpNotification;
extern MTNotificationName MTCameraScaleDownNotification;
extern MTNotificationName MTCameraLongScaleUpNotification;
extern MTNotificationName MTCameraLongScaleDownNotification;
extern MTNotificationName MTDeviceLongPressCanceledNotification;

extern MTDiscoveredNewDeviceKey MTDiscoveredNewDeviceRSSIKey;
extern MTDiscoveredNewDeviceKey MTDiscoveredNewDeviceAdvertisementDataKey;

@interface MTDeviceManager : NSObject

@property (nonatomic, strong, readonly) CBPeripheral *activeDevice;
@property (nonatomic, assign, assign) int batteryLevel;
@property (nonatomic, assign, assign) float temperatureLevel;
@property (nonatomic, assign, assign) float humidityLevel;
@property (nonatomic, strong, readonly) NSNumber *rssi;

+ (instancetype)sharedManager;


/**
 Scan devices.
 */
- (void)scan;

/**
 Stop scan devices.
 */
- (void)stopScan;


/**
 Connect one divece.

 @param device Device to connect.
 */
- (void)connectDevice:(CBPeripheral *)device;

/**
 Disconnect one divece.

 @param device Device to disconnect
 */
- (void)disconnectDevice:(CBPeripheral *)device;


/**
 Retrieve devices.

 @param identifiers identifiers
 @return Devices.
 */
- (NSArray<CBPeripheral *> *)retrieveDevicesWithIdentifiers:(NSArray<NSUUID *> *)identifiers;


/**
 Fetch the list of device connected.

 @return Device list.
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedDevices;


/**
 Send control command to the connected device.

 @param command The type of control command.
 @param device The connectd device.
 */
- (void)sendControlCommand:(MTControlCommandType)command toDevice:(CBPeripheral *)device;

//Each method is called once, it sends a notification about Rssi, the interval of not less than 1.5s
- (void)readRSSI:(CBPeripheral *)device;

@end
NS_ASSUME_NONNULL_END
