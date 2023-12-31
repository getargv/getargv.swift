import Cgetargv
import Foundation
import System

@available(macOS 11, *)
extension String {
    init(
        cString cstr: UnsafePointer<CChar>,
        encoding enc: String.Encoding
    ) throws {
        if case .some(let str) = String(cString: cstr, encoding: enc) {
            self.init(str)
        } else {
            throw Errno(rawValue: EILSEQ)
        }
    }
}

/// A class that holds a printable representation of the arguments of a process.
///
/// This class holds the output of ``GetArgvOfPid(pid:skip:nuls:)`` and provides a ``print()`` method,
/// as well as access to the underlying `Array<CChar>` and even the `UnsafeBufferPointer<CChar>`.
@available(macOS 11, *)
public final class PrintableArgvResult {

    private var res = ArgvResult()

    init?(options: borrowing GetArgvOptions) {
        if !withUnsafePointer(to: options, { get_argv_of_pid($0, &res) }) { return nil }
    }

    deinit {
        if res.buffer != nil { free_ArgvResult(&res) }
    }

    /// Print the arguments to `stdout`.
    ///
    /// prints the results of ``GetArgvOfPid(pid:skip:nuls:)`` to `stdout` exactly as parsed, including `nul` bytes if they were not replaced with `space`s.
    ///
    /// - Returns: A `Result` indicating if there was an error
    public func print() -> Result<Void, Errno> {
        return if print_argv_of_pid(res.start_pointer, res.end_pointer) {
            .success(())
        } else {
            .failure(Errno(rawValue: errno))
        }
    }
    /// The underlying buffer as an `Array<CChar>`.
    ///
    /// > Warning: Be careful with this, there are no guarantees that the bytes that were passed to a process are in
    /// any sort of predictable format, other than being `nul` or `space` delimited as specified to ``GetArgvOfPid(pid:skip:nuls:)``.
    public var array: [CChar] {
        return Array(buffer)
    }
    /// The underlying `UnsafeBufferPointer<CChar>`.
    ///
    /// > Warning: Be careful with this, there are no guarantees that the bytes that were passed to a process are in
    /// any sort of predictable format, other than being `nul` or `space` delimited as specified to ``GetArgvOfPid(pid:skip:nuls:)``.
    public var buffer: UnsafeBufferPointer<CChar> {
        get { return UnsafeBufferPointer<CChar>(start: res.start_pointer!, count: res.end_pointer - res.start_pointer + 1) }
    }
}

/// Get the arguments of a process in a printable format.
///
/// Gets the arguments of a process specified by pid and returns them in a ``PrintableArgvResult`` class that can
/// print them to `stdout`. There are formatting options too, for skipping past leading arguments and for replacing
/// `nul` bytes with `space`s, which can be handy when creating cli tools, and which are more efficiently implemented
/// internal to the function.
///
/// # Example:
/// This snippet prints all but the first argument of the calling process separated by whitespace for human consumption.
///```swift
///switch GetArgvOfPid(pid: getpid(), skip: 1, nuls: true) {
///     case .success(let res):
///         res.print()
///     case .failure(let error):
///         print(error.localizedDescription)
///}
///```
///
/// - Parameters:
///   - pid: The id of the process of which to get the arguments.
///   - skip: The number of leading arguments to skip over.
///   - nuls: Whether to replace `nul` bytes with `space` characters to make the arguments human readable.
/// - Returns: A `Result` containing either a ``PrintableArgvResult`` holding the parsed arguments ready for printing, or an `Errno` representing what went wrong.
@available(macOS 11, *)
public func GetArgvOfPid(pid: pid_t, skip: uint = 0, nuls: Bool = false) -> Result<PrintableArgvResult, Errno> {
    let options = GetArgvOptions(skip: skip, pid: pid, nuls: nuls)
    return if let res = PrintableArgvResult(options: options) {
        .success(res)
    } else {
        .failure(Errno(rawValue: errno))
    }
}

/// Get the arguments of a process in an inspectable format.
///
/// Tries to interpret the bytes that were passed to `pid` as an `Array` of `String`s with the specified encoding.
/// The encoding parameter is required because the argument's encoding isn't known to this function if there even
/// was one, so it is up to the user to try to find a workable `String.Encoding`. C strings have no encoding rules
/// so there is no guarantee that any encoding will work.
///
/// # Example:
/// This snippet prints the number of arguments to the calling function
///```swift
///switch GetArgvAndArgcOfPid(pid: getpid(), encoding: String.Encoding.utf8) {
///     case .success(let arr):
///         print("pid had \(arr.count) arguments.")
///     case .failure(let error):
///         print(error.localizedDescription)
///}
///```
///
/// - Parameters:
///   - pid: The id of the process of which to get the arguments.
///   - encoding: Which `String.Encoding` to use to decode the argument bytes as `String`s.
/// - Returns: A `Result` containing either an `Array<String>` holding the parsed arguments ready for use, or an `Errno` representing what went wrong.
@available(macOS 11, *)
public func GetArgvAndArgcOfPid(pid: pid_t, encoding: String.Encoding) -> Result<[String], Errno> {
    var res = ArgvArgcResult()
    if !get_argv_and_argc_of_pid(pid, &res) { return .failure(Errno(rawValue: errno)) }

    defer { free_ArgvArgcResult(&res) }

    do {
        return .success(
            Array(
                try UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>(start: res.argv, count: Int(res.argc)).map {
                    try String(cString: $0!, encoding: encoding)
                })
        )
    } catch {
        return .failure(Errno(rawValue: EILSEQ))
    }
}
