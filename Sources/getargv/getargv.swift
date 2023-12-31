import ArgumentParser
import Cgetargv
import Foundation
import System

@available(macOS 10.15.4, *)
class StandardError: TextOutputStream {
    func write(_ string: String) {
        try! FileHandle.standardError.write(contentsOf: Data(string.utf8))
    }
}

@available(macOS 11, *)
@main
struct getargv: ParsableCommand {
    @Flag(name: [.customShort("0")], help: "Print args nul separated")
    var keepNuls: Bool = false

    @Option(name: .shortAndLong, help: "The number of leading args to skip")
    var skip: uint? = nil

    @Argument(help: "The pid of the process to print the args thereof")
    var pid: pid_t

    mutating func run() throws {
        let options = GetArgvOptions(skip: skip ?? 0, pid: pid, nuls: !keepNuls)
        var res = ArgvResult()
        let result = withUnsafePointer(to: options, { get_argv_of_pid($0, &res) })
        if result {
            print_argv_of_pid(res.start_pointer, res.end_pointer)
            free_ArgvResult(&res)
        } else {
            let err = Errno(rawValue: errno)
            var standardError = StandardError()
            print("getargv: '\(err)'", to: &standardError)
        }
    }
}
