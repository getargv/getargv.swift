import Foundation
import Testing

@testable import SwiftGetargv

@Suite()
struct SwiftGetargvTests {

    @available(macOS 11.0, *)
    @Test("test getArgvOfPid NUL replacement", arguments: zip([true, false], [" ", "\0"]))
        func GetArgvOfPidNuls(nuls: Bool, separator: String) throws {
            let expectedOutput = CommandLine.arguments.joined(separator: separator).utf8CString

            let actualOutput = try #require(try getArgvOfPid(pid: getpid(), nuls: nuls).get())

            #expect(actualOutput.array == Array(expectedOutput))
        }

    @available(macOS 11.0, *)
    @Test("test getArgvAndArgcOfPid")
        func testGetArgvAndArgcOfPid() throws {
            let expectedOutput = CommandLine.arguments

            let actualOutput = try #require(try getArgvAndArgcOfPid(pid: getpid(), encoding: String.Encoding.nonLossyASCII).get())

            #expect(actualOutput == expectedOutput)
        }
}
