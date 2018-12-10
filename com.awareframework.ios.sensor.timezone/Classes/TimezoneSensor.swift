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
    public static let actionAwareTimezoneSetLabel = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE_SET_LABEL)
    public static let actionAwareTimezoneSyncCompletion  = Notification.Name(TimezoneSensor.ACTION_AWARE_TIMEZONE_SYNC_COMPLETION)

}

public protocol TimezoneObserver {
    func onTimezoneChanged(data:TimezoneData)
}

public class TimezoneSensor: AwareSensor {
    
    public static let TAG = "Aware::Timezone"
    
    /**
     * Broadcast event: when there is new timezone information
     */
    public static let ACTION_AWARE_TIMEZONE = "com.awareframework.ios.sensor.timezone"
    public static let EXTRA_DATA = "data"
    
    /**
     * Received event: Fire it to start the timezone sensor.
     */
    public static let ACTION_AWARE_TIMEZONE_START = "com.awareframework.ios.sensor.timezone.SENSOR_START"
    
    /**
     * Received event: Fire it to stop the timezone sensor.
     */
    public static let ACTION_AWARE_TIMEZONE_STOP = "com.awareframework.ios.sensor.timezone.SENSOR_STOP"
    
    /**
     * Received event: Fire it to sync the data with the server.
     */
    public static let ACTION_AWARE_TIMEZONE_SYNC = "com.awareframework.ios.sensor.timezone.SYNC"
    
    public static let ACTION_AWARE_TIMEZONE_SYNC_COMPLETION = "com.awareframework.ios.sensor.timezone.SENSOR_SYNC_COMPLETION"
    public static let EXTRA_STATUS = "status"
    public static let EXTRA_ERROR = "error"
    
    /**
     * Received event: Fire it to set the data label.
     * Use [EXTRA_LABEL] to send the label string.
     */
    public static let ACTION_AWARE_TIMEZONE_SET_LABEL = "com.awareframework.ios.sensor.timezone.SET_LABEL"
    
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
    public var CONFIG: Config = Config()
    
    public class Config:SensorConfig{
        public var sensorObserver:TimezoneObserver? = nil
        
        public override init(){
            super.init()
            dbPath = "aware_timezone"
        }
        
        public func apply(closure: (_ config:TimezoneSensor.Config) -> Void) -> Self{
            closure(self)
            return self
        }
        
    }
    
    public override convenience init() {
        self.init(Config())
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
            self.timer?.fire()
            self.notificationCenter.post(name:.actionAwareTimezoneStart, object: self)
        }
    }
    
    public override func stop() {
        if let t = self.timer{
            t.invalidate()
            self.timer = nil
            self.notificationCenter.post(name:.actionAwareTimezoneStop, object: self)
        }
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine{
            engine.startSync(TimezoneData.TABLE_NAME, TimezoneData.self, DbSyncConfig.init().apply{config in
                config.debug = self.CONFIG.debug
                config.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.timezone.sync.queue")
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = [TimezoneSensor.EXTRA_STATUS :status]
                    if let e = error {
                        userInfo[TimezoneSensor.EXTRA_ERROR] = e
                    }
                    self.notificationCenter.post(name: .actionAwareTimezoneSyncCompletion ,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            self.notificationCenter.post(name:.actionAwareTimezoneSync, object: self)
        }
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
        tzData.label = self.CONFIG.label
        
        if let engine = self.dbEngine{
            engine.save(tzData)
        }
        
        if let observer = self.CONFIG.sensorObserver {
            observer.onTimezoneChanged(data: tzData)
        }
        
        self.notificationCenter.post(name: .actionAwareTimezone,
                                     object: self,
                                     userInfo: [TimezoneSensor.EXTRA_DATA:tzData])
    }
    
    public override func set(label:String){
        self.CONFIG.label = label
        self.notificationCenter.post(name: .actionAwareTimezoneSetLabel,
                                     object: self,
                                     userInfo:[TimezoneSensor.EXTRA_LABEL:label])
    }
}
