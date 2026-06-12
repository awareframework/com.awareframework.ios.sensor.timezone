import XCTest
@testable import com_awareframework_ios_sensor_timezone
import com_awareframework_ios_core

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
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
