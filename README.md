# oozizSDK-iOS

## Create a singleton object 
```Objectice-C
[MTDeviceManager sharedManager];
```

## Detecting Bluetooth is turned on, you need to register notice 
```Objectice-C
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(bleOn) 
                                             name:MTDevicePowerOnNotification 
                                           object:nil];
```

## Search for Bluetooth devices 
```Objectice-C
[[MTDeviceManager sharedManager] scan];
```

## Connecting a Bluetooth device 
```Objectice-C
[[MTDeviceManager sharedManager] connectDevice:peripheral];
```

## Connection callback notification registration required 
```Objectice-C
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectNotify:) name:MTDeviceConnectedNotification object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectNotify:) name:MTDeviceDisconnectedNotification object:nil];
```
