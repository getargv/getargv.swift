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
}
