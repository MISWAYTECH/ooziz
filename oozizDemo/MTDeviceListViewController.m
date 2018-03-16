//
//  MTDeviceListViewController.m
//  oozizDemo
//
//  Created by MISWAY on 3/16/18.
//  Copyright (c) 2018年 MISWAY All rights reserved.
//

#import "MTDeviceListViewController.h"
#import <oozizSDK/oozizSDK.h>

@interface MTDeviceListViewController ()
@property (nonatomic, strong) NSMutableArray *discoveredArray;
@property (nonatomic, strong) NSMutableArray *rssiArray;
@property (nonatomic, strong) UIBarButtonItem *leftBarItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarItem;

@end

@implementation MTDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"home";
    
    self.leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"update" style:UIBarButtonItemStylePlain target:self action:@selector(pressLeftBarItem)];
    self.navigationItem.leftBarButtonItem = self.leftBarItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleOn) name:MTDevicePowerOnNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleOff) name:MTDevicePowerOffNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoverNotify:) name:MTDiscoveredNewDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectNotify:) name:MTDeviceConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectNotify:) name:MTDeviceDisconnectedNotification object:nil];

    self.discoveredArray = [[NSMutableArray alloc] init];
    self.rssiArray = [[NSMutableArray alloc] init];
    [MTDeviceManager sharedManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressLeftBarItem {
    NSMutableArray *array1 = [NSMutableArray array];
    NSMutableArray *array2 = [NSMutableArray array];
    for (CBPeripheral *peripheral in self.discoveredArray) {
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [array1 addObject:peripheral];
            NSUInteger indexRow = [self.discoveredArray indexOfObject:peripheral];
            [array2 addObject:[self.rssiArray objectAtIndex:indexRow]];
        }
    }
    [self.discoveredArray removeObjectsInArray:array1];
    [self.rssiArray removeObjectsInArray:array2];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.discoveredArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home" forIndexPath:indexPath];
    
    CBPeripheral *peripheral = [self.discoveredArray objectAtIndex:indexPath.row];;
    NSNumber *rssi = [self.rssiArray objectAtIndex:indexPath.row];;
   
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", peripheral.name, rssi];
    NSString *str = nil;
    switch (peripheral.state) {
        case 0:
            str = @"CBPeripheralStateDisconnected";
            break;
        case 1:
            str = @"CBPeripheralStateConnecting";
            break;
        case 2:
            str = @"CBPeripheralStateConnected";
            break;
            
        default:
            break;
    }
    cell.detailTextLabel.text = str;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = self.discoveredArray[indexPath.row];
    [[MTDeviceManager sharedManager] connectDevice:peripheral];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - discover notify

- (void)bleOn {
    [[MTDeviceManager sharedManager] scan];
}

- (void)bleOff {
    
}

- (void)discoverNotify:(NSNotification *)notification {
    
    CBPeripheral *peripheral = notification.object;
    NSNumber *rssi = [notification.userInfo objectForKey:MTDiscoveredNewDeviceRSSIKey];
    
    if ([self.discoveredArray containsObject:peripheral]) {
        int indexRow = (int)[self.discoveredArray indexOfObject:peripheral];
        [self.rssiArray replaceObjectAtIndex:indexRow withObject:rssi];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        [self.discoveredArray addObject:peripheral];
        [self.rssiArray addObject:rssi];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.discoveredArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)connectNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    
    int indexRow = (int)[self.discoveredArray indexOfObject:peripheral];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)disconnectNotify:(NSNotification *)notification {
    CBPeripheral *peripheral = notification.object;
    
    int indexRow = (int)[self.discoveredArray indexOfObject:peripheral];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
