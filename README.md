## Wemo-iOS

This iOS app is a proof of concept application to demonstrate the capbilities available to interface with Belkin Wemo switches [Belkin Wemo light switches](http://www.belkin.com/us/F7C063fc-Belkin/p/P-F7C063fc/). This project is based on this very helpful repository: https://github.com/gizmosachin/Wemo

Since I was unable to successfully scan my devices using the above-mentioned library, I took a different approach of entering the IP addresses and searching for devices that way. Some of the logic needs to be improved and is **not** suitable for production use, however it is a working first attempt at controlling Wemo switches.

This app can be used to manually control the switches or to setup a geofence around a location (i.e. a house), and turn on the switches once that geofence has been crossed. There is a Settings screen in the app that lets the user modify the geofence center coordinate, radius and time to turn on the devices after (for example: outdoor lights should turn on after 17:00)

## Usage

To detect your device, you should enter the IP address and MAC address of your Wemo switch in the **Constants.swift** file. To add multiple devices, create more WemoDevice objects and add them to the data source array. NOTE: I have not yet tested this out with more than one switch, so I am unsure of this exact behavior (TODO).

``` swift
    // Create a new device
    static let wemoDevicePublic1 = WemoDevice(ipAddress: "XXX.XXX.XXX.XX", macAddress: "XX:XX:XX:XX:XX:XX")
    static let wemoDevicePublic2 = WemoDevice(ipAddress: "XXX.XXX.XXX.XX", macAddress: "XX:XX:XX:XX:XX:XX")
    
    // Add it to the wemoDeviceArray
    static let wemoDeviceArray = [Constants.wemoDevicePublic1, Constants.wemoDevicePublic2]
```

Once the device has been detected, you can turn it on or off from anywhere in the app (with a push notification to provide the user with feedback, or to notify them when this happens in the background, by using:

``` swift
wemoDevice.turnOn(completion: { (success) in
  
  // Logic once the device is on
                
})

wemoDevice.turnOff(completion: { (success) in
                
  // Logic once the device is off
            
})
```

## Motivation

This project is the result of an afternoon thought of automating my home processes as much as possible. There are plenty of solutions out there now, but what better satisfaction do you get than from building it yourself? :)

## License

This project is available under the MIT License.
