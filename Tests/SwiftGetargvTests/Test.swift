import Foundation
import XCTest
@testable import SwiftGetargv

final class SwiftGetargvTests: XCTestCase {
    func testGetArgvOfPid() {
        let expectedOutput = ProcessInfo.processInfo.arguments.joined(separator: " ")

        switch GetArgvOfPid(pid: getpid(), nuls: true) {
        case .success(let actualOutput):
            XCTAssertEqual(actualOutput.array, Array(expectedOutput), "The Args are not correct.")
        case .failure(let error):
            XCTFail("GetArgvOfPid failed with \(error)")
        }
    }

    func testGetArgvOfPidWithNuls() {
        let expectedOutput = ProcessInfo.processInfo.arguments.flatMap { $0.utf8CString }

        switch GetArgvOfPid(pid: getpid()) {
        case .success(let actualOutput):
            XCTAssertEqual(actualOutput.array, expectedOutput, "The Args are not correct.")
        case .failure(let error):
            XCTFail("GetArgvOfPid failed with \(error)")
        }
    }

    func testGetArgvAndArgcOfPid() {
        let expectedOutput = ProcessInfo.processInfo.arguments

        switch GetArgvAndArgcOfPid(pid: getpid()) {
        case .success(let actualOutput):
            XCTAssertEqual(actualOutput, expectedOutput, "The Args are not correct.")
        case .failure(let error):
            XCTFail("GetArgvAndArgcOfPid failed with \(error)")
        }
    }
}
