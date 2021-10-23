# AWARE: Timezone

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.timezone)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.timezone)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.timezone)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.timezone)

The timezone sensor keeps track of the user’s current timezone.

## Requirements
iOS 10 or later

## Installation

com.awareframework.ios.sensor.timezone is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.timezone'
```

2. Import com.awareframework.ios.sensor.timezone library into your source code.
```swift
import com_awareframework_ios_sensor_timezone 
```

## Public functions

### TimezoneSensor

* `init(config:TimezoneSensor.Config?)` : Initializes the timezone sensor with the optional configuration.
* `start()`: Starts the timezone sensor with the optional configuration.
* `stop()`: Stops the service.


### TimezoneSensor.Config

Class to hold the configuration of the sensor.

#### Fields

+ `sensorObserver: TimezoneObserver`: Callback for live data updates.
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to `Logcat`. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.NONE`)
+ `dbPath: String` Path of the database. (default = "aware_timezone")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Broadcasts

+ `TimezoneSensor.ACTION_AWARE_TIMEZONE` broadcasted when there is new timezone information. Extra includes `TimezoneSensor.EXTRA_DATA` for the new timezone.

## Data Representations

### Timezone Data

| Field      | Type   | Description                                                                  |
| ---------- | ------ | ---------------------------------------------------------------------------- |
| timezoneId | String | the timezone ID string, i.e., “America/Los_Angeles, GMT-08:00”  |
| deviceId   | String | AWARE device UUID                                                            |
| label      | String | Customizable label. Useful for data calibration or traceability              |
| timestamp  | Long   | unixtime milliseconds since 1970                                             |
| timezone   | Int    | Timezone of the device                                                       |
| os         | String | Operating system of the device (ex. android)                                 |

## Example usage

```swift
let timezoneSensor = TimezoneSensor.init(TimezoneSensor.Config().apply{ config in
    config.sensorObserver = Observer()
    config.debug = true
    config.dbType = .REALM
})
timezoneSensor?.start()
```

```swift
class Observer:TimezoneObserver{
    func onTimezoneChanged(data: TimezoneData) {
        // Your code here..
    }
}
```

## Author

Yuuki Nishiyama, yuukin@iis.u-tokyo.ac.jp

## License

Copyright (c) 2021 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

