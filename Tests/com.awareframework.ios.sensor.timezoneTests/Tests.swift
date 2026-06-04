import XCTest
import com_awareframework_ios_sensor_timezone
import com_awareframework_ios_core

final class Tests: XCTestCase {

    func testControllers() {
        let sensor = TimezoneSensor(TimezoneSensor.Config().apply { config in
            config.debug = true
        })

        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(
            forName: .actionAwareTimezoneSetLabel, object: nil, queue: .main) { notification in
            XCTAssertEqual(
                (notification.userInfo as? [String: String])?[TimezoneSensor.EXTRA_LABEL],
                newLabel)
            expectSetLabel.fulfill()
        }
        sensor.set(label: newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)

        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(
            forName: .actionAwareTimezoneSync, object: nil, queue: .main) { _ in
            expectSync.fulfill()
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)
    }
}
