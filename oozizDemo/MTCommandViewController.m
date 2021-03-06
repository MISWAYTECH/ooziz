//
//  MTCommandViewController.m
//  oozizDemo
//
//  Created by MISWAY on 3/16/18.
//  Copyright (c) 2018年 MISWAY All rights reserved.
//

#import "MTCommandViewController.h"
#import <oozizSDK/oozizSDK.h>
#import "MTDevice.h"

@interface MTCommandViewController ()

@end

@implementation MTCommandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressSoundBtn:(id)sender {
    NSArray<CBPeripheral *> * array = [[MTDeviceManager sharedManager] retrieveConnectedDevices];
    CBPeripheral *peripheral = nil;
    for (CBPeripheral *device in array) {
        if ([device.identifier.UUIDString isEqualToString:self.tag.uuidString]) {
            peripheral = device;
            break;
        }
    }
    if (peripheral) {
        [[MTDeviceManager sharedManager] sendControlCommand:MTControlCommandSoundOrMute toDevice:peripheral];
    }
    
    
}
- (IBAction)pressMuteBtn:(id)sender {

}
- (IBAction)pressOffBtn:(id)sender {
    NSArray<CBPeripheral *> * array = [[MTDeviceManager sharedManager] retrieveConnectedDevices];
    CBPeripheral *peripheral = nil;
    for (CBPeripheral *device in array) {
        if ([device.identifier.UUIDString isEqualToString:self.tag.uuidString]) {
            peripheral = device;
            break;
        }
    }
    if (peripheral) {
        [[MTDeviceManager sharedManager] sendControlCommand:MTControlCommandPowerOff toDevice:peripheral];
    }
}

- (IBAction)pressBatteryLevel:(id)sender {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
