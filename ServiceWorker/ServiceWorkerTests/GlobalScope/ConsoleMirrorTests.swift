import XCTest
@testable import ServiceWorker
import PromiseKit
import JavaScriptCore

class ConsoleMirrorTests: XCTestCase {

    override func tearDown() {
        Log.debug = { NSLog($0) }
        Log.info = { NSLog($0) }
        Log.warn = { NSLog($0) }
        Log.error = { NSLog($0) }
    }

    func testShouldMirrorAllLevels() {

        var functionsRun: Set<String> = []

        let testWorker = ServiceWorker.createTestWorker(id: name)

        // We need to do this first because the exec environment creation uses
        // the logging.

        testWorker.getExecutionEnvironment()
            .then { _ -> Promise<Void> in

                Log.info = { msg in
                    XCTAssertEqual(msg, "info-test")
                    functionsRun.insert("info")
                    Log.info = nil
                }

                Log.debug = { msg in
                    XCTAssertEqual(msg, "debug-test")
                    functionsRun.insert("debug")
                    Log.debug = nil
                }

                Log.warn = { msg in
                    XCTAssertEqual(msg, "warn-test")
                    functionsRun.insert("warn")
                    Log.warn = nil
                }

                Log.error = { msg in
                    XCTAssertEqual(msg, "error-test")
                    functionsRun.insert("error")
                    Log.error = nil
                }

                return testWorker.evaluateScript("""
                    console.info('info-test');
                    console.debug('debug-test');
                    console.warn('warn-test');
                    console.error('error-test');
                """)
            }
            .then { _ -> Void in

                XCTAssert(functionsRun.contains("info"), "Info")
                XCTAssert(functionsRun.contains("debug"), "Debug")
                XCTAssert(functionsRun.contains("warn"), "Warn")
                XCTAssert(functionsRun.contains("error"), "Error")
            }
            .assertResolves()
    }

    func testShouldMirrorObjects() {

        let expect = expectation(description: "Should log")

        Log.debug = { msg in
            XCTAssert(msg.contains("test = looks;"))
            XCTAssert(msg.contains("like = this;"))
            expect.fulfill()
        }

        let testWorker = ServiceWorker.createTestWorker(id: name)

        testWorker.evaluateScript("console.debug({test:'looks', like: 'this'})")
            .then {
                self.wait(for: [expect], timeout: 1)
            }
            .assertResolves()
    }
}
