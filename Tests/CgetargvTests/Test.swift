import Foundation
import XCTest
@testable import Cgetargv

final class CgetargvTests: XCTestCase {
    func testGetArgvOfPid() {
        let input = getpid()
        let expectedOutput = ProcessInfo.processInfo.arguments.joined(separator: " ")
        XCTAssertEqual(get_argv_of_pid(input), expectedOutput, "The Args are not correct.")
    }
}
