//
//  MTDeviceViewController.m
//  oozizDemo
//
//  Created by MISWAY on 3/16/18.
//  Copyright (c) 2018年 MISWAY All rights reserved.
//

#import "MTDeviceViewController.h"
#import "MTCommandViewController.h"

#import <oozizSDK/oozizSDK.h>
#import "MTDevice.h"

@interface MTDeviceViewController ()
@property (nonatomic, strong) NSMutableArray *connectedDevices;
@property (nonatomic, strong) UIBarButtonItem *leftBarItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarItem;

@end

@implementation MTDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connectedDevices = [[NSMutableArray alloc] init];
//    self.leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(pressLeftBarItem)];
//    self.navigationItem.leftBarButtonItem = self.leftBarItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectNotify:) name:MTDeviceDisconnectedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singlePressNotify:) name:MTDeviceSinglePressedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doublePressNotify:) name:MTDeviceDoublePressedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(longPressNotify:) name:MTDeviceLongPressedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelNotify:) name:MTDeviceUpdateBatteryLevelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(temperatureNotify:) name:MTDeviceUpdateBatteryLevelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(humidityNotify:) name:MTDeviceUpdateHumidityNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rssiNotify:) name:MTDeviceUpdateRSSINotification object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(readAllRssis) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __func__);
//    [self.connectedDevices removeAllObjects];
    NSArray *array = [[MTDeviceManager sharedManager] retrieveConnectedDevices];
    
    //连接了新的设备
    for (CBPeripheral *peripheral in array) {
        BOOL isExist = NO;
        for (MTDevice *temp in self.connectedDevices) {
            if ([temp.uuidString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                break;
            }
        }
        
        if (isExist == NO) {
            MTDevice *tag = [[MTDevice alloc] init];
            tag.uuidString = peripheral.identifier.UUIDString;
            [self.connectedDevices addObject:tag];
        }
    }
    
   
    //断开了设备
    NSMutableArray *lostArray = [[NSMutableArray alloc] init];
    int indexSection = 0;
    int indexRow = 0;
    for (MTDevice *temp in self.connectedDevices) {
        BOOL isExist = NO;
        for (CBPeripheral *peripheral in array) {
            indexRow++;
            if ([peripheral.identifier.UUIDString isEqualToString:temp.uuidString]) {
                isExist = YES;
                break;
            }
        }
        indexSection++;
        
        if (isExist == NO) {
            [lostArray addObject:temp];
        }
    }
    [self.connectedDevices removeObjectsInArray:lostArray];

    
    [self.tableView reloadData];
    self.navigationItem.title = [NSString stringWithFormat:@"device (%d)", (int)self.connectedDevices.count];
}

//- (void)pressLeftBarItem {
//    
//    [self.tableView reloadData];
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.connectedDevices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device" forIndexPath:indexPath];
    
    MTDevice *tag = [self.connectedDevices objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"battery: %d%%\ntemperature: %.1f\nhumidity: %.1f%%\nrssi:%@\npress type: %@", tag.batteryLevel, tag.temperatureLevel, tag.humidityLevel, tag.rssi, tag.pressType];
    cell.textLabel.numberOfLines = 5;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MTDevice *tag = self.connectedDevices[indexPath.row];
        MTCommandViewController *controller = (MTCommandViewController *)[segue destinationViewController];
        controller.tag = tag;
    }
}

#pragma mark - notify

- (void)disconnectNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    for (MTDevice *temp in self.connectedDevices) {
        if ([temp.uuidString isEqualToString:peripheral.identifier.UUIDString]) {
            [self.connectedDevices removeObject:temp];
            [self.tableView reloadData];
            break;
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"device (%d)", (int)self.connectedDevices.count];
}

- (void)singlePressNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.pressType = @"single press";
}

- (void)doublePressNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.pressType = @"double press";
}

- (void)longPressNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.pressType = @"long press";
}

- (void)batteryLevelNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.batteryLevel = [MTDeviceManager sharedManager].batteryLevel;
    
    [self.tableView reloadData];
}

- (void)temperatureNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.temperatureLevel = [MTDeviceManager sharedManager].temperatureLevel;
    
    [self.tableView reloadData];
}

- (void)humidityNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.humidityLevel = [MTDeviceManager sharedManager].humidityLevel;
    [self.tableView reloadData];
}

- (void)rssiNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    MTDevice *tag = [self findAXATag:peripheral.identifier.UUIDString];
    tag.rssi = [MTDeviceManager sharedManager].rssi;
    [self.tableView reloadData];
}

- (MTDevice *)findAXATag:(NSString *)uuidString {
    for (MTDevice *temp in self.connectedDevices) {
        if ([temp.uuidString isEqual:uuidString]) {
            return temp;
        }
    }
    return nil;
}

- (void)readAllRssis {
    [[MTDeviceManager sharedManager] readRSSI:[MTDeviceManager sharedManager].activeDevice];
}

@end
