//
//  TimezoneData.swift
//  com.aware.ios.sensor.timezone
//
//  Created by Yuuki Nishiyama on 2018/10/24.
//

import UIKit
import com_awareframework_ios_sensor_core

public class TimezoneData: AwareObject {
    public static var TABLE_NAME = "timezoneData"
    @objc dynamic public var timezoneId: String = ""
    
    override public func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["timezoneId"] = timezoneId
        return dict
    }
}
