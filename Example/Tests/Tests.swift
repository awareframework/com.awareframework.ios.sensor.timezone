import XCTest
import RealmSwift
import com_awareframework_ios_sensor_timezone

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSync(){
        //        let sensor = TimezoneSensor.init(TimezoneSensor.Config().apply{ config in
        //            config.debug = true
        //            config.dbType = .REALM
        //        })
        //        sensor.start();
        //        sensor.enable();
        //        sensor.sync(force: true)
        
        //        let syncManager = DbSyncManager.Builder()
        //            .setBatteryOnly(false)
        //            .setWifiOnly(false)
        //            .setSyncInterval(1)
        //            .build()
        //
        //        syncManager.start()
    }
    
    func testStorage(){
        let sensor = TimezoneSensor.init(TimezoneSensor.Config().apply{ config in
            config.dbType = .REALM
        })
        let timezoneStorageExpect = expectation(description: "timezone storage")
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareTimezone,
                                                              object: nil,
                                                              queue: .main) { (notification) in
            if let engine = sensor.dbEngine {
                if let data = engine.fetch(TimezoneData.TABLE_NAME, TimezoneData.self, nil) as? Results<Object> {
                    print(data.count)
                    if data.count != 1{
                        XCTFail()
                    }else{
                        timezoneStorageExpect.fulfill()
                    }
                }
            }
        }
        sensor.start()
        wait(for: [timezoneStorageExpect], timeout: 10)
        sensor.stop()
        NotificationCenter.default.removeObserver(observer)
    }
    
    func testObserver(){
        
        class Observer:TimezoneObserver{
            weak var timezoneExpectation: XCTestExpectation?
            func onTimezoneChanged(data: TimezoneData) {
                self.timezoneExpectation?.fulfill()
            }
        }
        
        let timezoneObserverExpect = expectation(description: "Timezone observer")
        let observer = Observer()
        observer.timezoneExpectation = timezoneObserverExpect
        let sensor = TimezoneSensor.init(TimezoneSensor.Config().apply{ config in
            config.sensorObserver = observer
        })
        sensor.start()
        wait(for: [timezoneObserverExpect], timeout: 3)
        sensor.stop()
    }
    
    func testControllers(){
        
        let sensor = TimezoneSensor()
        
        /// test set label action ///
        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(forName: .actionAwareTimezoneSetLabel, object: nil, queue: .main) { (notification) in
            let dict = notification.userInfo;
            if let d = dict as? Dictionary<String,String>{
                XCTAssertEqual(d[TimezoneSensor.EXTRA_LABEL], newLabel)
            }else{
                XCTFail()
            }
            expectSetLabel.fulfill()
        }
        sensor.set(label:newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)
        
        /// test sync action ////
        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareTimezoneSync , object: nil, queue: .main) { (notification) in
            expectSync.fulfill()
            print("sync")
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)
        
        
        //// test start action ////
        let expectStart = expectation(description: "start")
        let observer = NotificationCenter.default.addObserver(forName: .actionAwareTimezoneStart,
                                                              object: nil,
                                                              queue: .main) { (notification) in
                                                                expectStart.fulfill()
                                                                print("start")
        }
        sensor.start()
        wait(for: [expectStart], timeout: 5)
        NotificationCenter.default.removeObserver(observer)
        
        
        /// test stop action ////
        let expectStop = expectation(description: "stop")
        let stopObserver = NotificationCenter.default.addObserver(forName: .actionAwareTimezoneStop, object: nil, queue: .main) { (notification) in
            expectStop.fulfill()
            print("stop")
        }
        sensor.stop()
        wait(for: [expectStop], timeout: 5)
        NotificationCenter.default.removeObserver(stopObserver)
    }
    
    func testTimezoneData(){
        let data = TimezoneData()
        let dict = data.toDictionary()
        
        XCTAssertEqual(dict["timezoneId"] as? String, "")
    }
    
}
