//
//  TimezoneSensor.swift
//  com.aware.ios.sensor.timezone
//
//  Created by Yuuki Nishiyama on 2018/10/24.
//

import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_core

extension Notification.Name{
    public static let actionAwareTimezone = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE)
    public static let actionAwareTimezoneStart = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE_START)
    public static let actionAwareTimezoneStop = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE_STOP)
    public static let actionAwareTimezoneSync = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE_SYNC)
    public static let actionAwareTImezoneSetLabel = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE_SET_LABEL)
}

public protocol TimezoneObserver {
    func onTimezoneChanged(data:TimezoneData)
}

public class TimezoneSensor: AwareSensor {
    
    public static let TAG = "Aware::Timezone"
    
    /**
     * Broadcast event: when there is new timezone information
     */
    public static let ACTION_AWARE_TIMEZONE = "ACTION_AWARE_TIMEZONE"
    public static let EXTRA_DATA = "data"
    
    /**
     * Received event: Fire it to start the timezone sensor.
     */
    public static let ACTION_AWARE_TIMEZONE_START = "com.aware.android.sensor.timezone.SENSOR_START"
    
    /**
     * Received event: Fire it to stop the timezone sensor.
     */
    public static let ACTION_AWARE_TIMEZONE_STOP = "com.aware.android.sensor.timezone.SENSOR_STOP"
    
    /**
     * Received event: Fire it to sync the data with the server.
     */
    public static let ACTION_AWARE_TIMEZONE_SYNC = "com.aware.android.sensor.timezone.SYNC"
    
    /**
     * Received event: Fire it to set the data label.
     * Use [EXTRA_LABEL] to send the label string.
     */
    public static let ACTION_AWARE_TIMEZONE_SET_LABEL = "com.aware.android.sensor.timezone.SET_LABEL"
    
    /**
     * Label string sent in the intent extra.
     */
    public static let EXTRA_LABEL = "label"
    
    
    private var lastTimezone: String = ""
    private var timer:Timer? = nil
    
    /**
     * Current configuration of the [TimezoneSensor]. Some changes in the configuration will have
     * immediate effect.
     */
    var CONFIG: Config = Config()
    
    public class Config:SensorConfig{
        public var sensorObserver:TimezoneObserver? = nil
        
        public override init(){
            super.init()
            dbPath = "aware_timezone"
        }
        
        public convenience init(_ json:JSON){
            self.init()
        }
        
        public func apply(closure: (_ config:TimezoneSensor.Config) -> Void) -> Self{
            closure(self)
            return self
        }
        
    }
    
    public init(_ config:TimezoneSensor.Config){
        super.init()
        CONFIG = config
        initializeDbEngine(config: config)
    }
    
    public override func start() {
        if self.timer == nil {
            let hour:Double = 60 * 60
            // retrieve timezone every hour
            self.timer = Timer.scheduledTimer(withTimeInterval: hour, repeats: true, block: { timer in
                self.retrieveTimezone()
            })
        }
        self.notificationCenter.post(name:.actionAwareTimezoneStart, object:nil)
    }
    
    public override func stop() {
        if let t = self.timer{
            t.invalidate()
            self.timer = nil
        }
        self.notificationCenter.post(name:.actionAwareTimezoneStop, object:nil)
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine{
            engine.startSync(TimezoneData.TABLE_NAME, DbSyncConfig.init().apply{config in
                config.debug = self.CONFIG.debug
            })
        }
        self.notificationCenter.post(name:.actionAwareTimezoneSync, object:nil)
    }
    
    func retrieveTimezone(){
        let currentTimezone = TimeZone.current.identifier
        print(currentTimezone)
        if self.lastTimezone == "" {
            // save timezone data
            self.saveTimezoneData(currentTimezone)
        } else if self.lastTimezone != currentTimezone{
            // save timezone data
            self.saveTimezoneData(currentTimezone)
        } else {
            // same timezone
        }
        self.lastTimezone = currentTimezone
    }
    
    func saveTimezoneData(_ timezoneId:String) {
        
        let tzData = TimezoneData()
        tzData.timezoneId = timezoneId
        
        if let engine = self.dbEngine{
            engine.save(tzData, TimezoneData.TABLE_NAME)
        }
        
        if let observer = self.CONFIG.sensorObserver {
            observer.onTimezoneChanged(data: tzData)
        }
        
        self.notificationCenter.post(name: .actionAwareTimezone, object: nil, userInfo: [TimezoneSensor.EXTRA_DATA:tzData])
    }
}
