import Foundation
import Testing

@testable import Cgetargv

@Suite()
struct CgetargvTests {

    @Test("test getArgvOfPid NUL replacement", arguments: zip([true, false], [" ", "\0"]))
    func GetArgvOfPidNuls(nuls: Bool, separator: String) throws {
        let options = GetArgvOptions(skip: 0, pid: getpid(), nuls: nuls)
        var res = ArgvResult()
        try #require(withUnsafePointer(to: options, { get_argv_of_pid($0, &res) }))

        let expectedOutput = CommandLine.arguments.joined(separator: separator).utf8CString.withUnsafeBufferPointer { bytes -> Data in
            Data(buffer: bytes)
        }

        let count = (res.start_pointer == nil || res.end_pointer == res.start_pointer) ? 0 : res.end_pointer - res.start_pointer + 1
        let actualOutput = Data(
            buffer: UnsafeBufferPointer<CChar>(start: res.start_pointer!, count: count)
        )

        #expect(actualOutput == expectedOutput)
    }

    @Test("test getArgvAndArgcOfPid")
    func testGetArgvAndArgcOfPid() throws {
        let pid = getpid()
        var res = ArgvArgcResult()
        try #require(get_argv_and_argc_of_pid(pid, &res))

        let expectedOutput = ProcessInfo.processInfo.arguments
        let actualOutput = Array(
            UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>(start: res.argv, count: Int(res.argc))
        ).map { String(cString: $0!) }

        #expect(actualOutput == expectedOutput)
    }
}
