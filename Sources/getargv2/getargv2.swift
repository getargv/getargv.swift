import ArgumentParser
import SwiftGetargv
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
        do {
            let result = try GetArgvOfPid(pid: pid, skip: skip ?? 0, nuls: !keepNuls).get()
            try result.print().get()
        } catch {
            var standardError = StandardError()
            print("getargv: '\(error.localizedDescription)'", to: &standardError)
        }
    }
}
