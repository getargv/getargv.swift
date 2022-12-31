import Foundation
import XCTest
@testable import Cgetargv

final class CgetargvTests: XCTestCase {
    func testGetArgvOfPid() {
        let options = GetArgvOptions(skip: 0, pid: getpid(), nuls: true)
        var res = ArgvResult();
        XCTAssert(withUnsafePointer(to: options, { get_argv_of_pid($0, &res) }))

        let expectedOutput = ProcessInfo.processInfo.arguments.joined(separator: " ")
        let actualOutput = String(cString: res.start_pointer)

        XCTAssertEqual(actualOutput, expectedOutput, "The Args are not correct.")
    }

    func testGetArgvOfPidWithNuls() {
        let options = GetArgvOptions(skip: 0, pid: getpid(), nuls: false)
        var res = ArgvResult();
        XCTAssert(withUnsafePointer(to: options, { get_argv_of_pid($0, &res) }))

        let expectedOutput = ProcessInfo.processInfo.arguments.flatMap { $0.utf8CString }
        let actualOutput = Array(UnsafeBufferPointer<CChar>(start: res.start_pointer!, count: res.end_pointer - res.start_pointer + 1))

        XCTAssertEqual(actualOutput, expectedOutput, "The Args are not correct.")
    }

    func testGetArgvAndArgcOfPid() {
        let pid = getpid()
        var res = ArgvArgcResult();
        XCTAssert(get_argv_and_argc_of_pid(pid, &res))

        let expectedOutput = ProcessInfo.processInfo.arguments
        let actualOutput = Array(UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>(start: res.argv, count: Int(res.argc))).map { String(cString: $0!) }

        XCTAssertEqual(actualOutput, expectedOutput, "The Args are not correct.")
    }
}
