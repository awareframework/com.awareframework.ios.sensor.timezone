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

    /// The sensor creates its own table: rows can be saved and read back for sync without the app
    /// creating the table (it used to be missing, so every save failed and nothing was synced)
    func testSensorCreatesItsTable() {
        let sensor = TimezoneSensor(TimezoneSensor.Config().apply { config in
            config.dbPath = "create_table_test_\(UUID().uuidString)"
        })
        XCTAssertEqual(sensor.CONFIG.dbTableName, TimezoneData.databaseTableName)
        guard let engine = sensor.dbEngine else { return XCTFail("no engine") }
        let saved = expectation(description: "saved")
        engine.save([TimezoneData()]) { error in
            XCTAssertNil(error)
            saved.fulfill()
        }
        wait(for: [saved], timeout: 5)
        XCTAssertEqual(engine.count(filter: nil), 1)
        XCTAssertEqual(engine.fetch(filter: nil, limit: nil)?.count, 1, "rows can be read for sync")
    }
}
