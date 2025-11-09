import Foundation
import Testing

public extension Optional {
    /// Boolean indicating that the Optional contains a value
    var isSome: Bool {
        return !self.isNone
    }
    /// Boolean indicating that the Optional does not contain a value
    var isNone: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
}

public extension Result {
    /// Boolean indicating that the Result contains a success value
    var isSuccess: Bool {
        return !self.isFailure
    }
    /// Boolean indicating that the Result contains a failure value
    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }
}


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

    @Test("test invalid pid returns a failure")
        func invalidPid() {
            let res = getArgvOfPid(pid: -1)
            #expect(res.isFailure)
            if case let .failure(errno) = res {
                #expect(errno == .noSuchProcess)
            }
        }
}
