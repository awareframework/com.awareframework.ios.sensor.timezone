# Aware Timezone

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.timezone)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.timezone)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.timezone)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.timezone.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.timezone)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS10 or later

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

Yuuki Nishiyama, tetujin@ht.sfc.keio.ac.jp

## License

Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

