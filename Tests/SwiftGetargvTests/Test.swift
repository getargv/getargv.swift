import Foundation
import XCTest

@testable import SwiftGetargv

final class SwiftGetargvTests: XCTestCase {
    func testGetArgvOfPid() {
        let expectedOutput = CommandLine.arguments.joined(separator: " ").utf8CString

        switch getArgvOfPid(pid: getpid(), nuls: true) {
        case .success(let actualOutput):
            XCTAssertEqual(actualOutput.array, Array(expectedOutput), "The Args are not correct.")
        case .failure(let error):
            XCTFail("getArgvOfPid failed with \(error)")
        }
    }

    func testGetArgvOfPidWithNuls() {
        let expectedOutput = CommandLine.arguments.flatMap { $0.utf8CString }

        switch getArgvOfPid(pid: getpid()) {
        case .success(let actualOutput):
            XCTAssertEqual(actualOutput.array, expectedOutput, "The Args are not correct.")
        case .failure(let error):
            XCTFail("getArgvOfPid failed with \(error)")
        }
    }

    func testGetArgvAndArgcOfPid() {
        let expectedOutput = CommandLine.arguments

        switch getArgvAndArgcOfPid(pid: getpid(), encoding: String.Encoding.nonLossyASCII) {
        case .success(let actualOutput):
            XCTAssertEqual(actualOutput, expectedOutput, "The Args are not correct.")
        case .failure(let error):
            XCTFail("getArgvAndArgcOfPid failed with \(error)")
        }
    }
}
