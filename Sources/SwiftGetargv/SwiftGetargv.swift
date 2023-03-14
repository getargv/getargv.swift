import Cgetargv
import Foundation
import System

@available(macOS 11, *)
extension String {
    init(
      cString cstr: UnsafePointer<CChar>,
      encoding enc: String.Encoding
    ) throws {
        if case let .some(str) = String(cString: cstr, encoding: enc) {
            self.init(str)
        } else {
            throw Errno(rawValue: EILSEQ)
        }
    }
}

extension Optional {

    var isNil: Bool {
        switch self {
        case Optional.none:
            return true
        default:
            return false
        }
    }

    var isSome: Bool {
        return !self.isNil
    }

}

@available(macOS 11, *)
public class PrintableArgvResult {
    var res: ArgvResult;
    init() {
        res = ArgvResult();
    }

    deinit {
        if (res.buffer != nil) { free_ArgvResult(&res) }
    }

    public func print() -> Result<Void,Errno> {
        if !print_argv_of_pid(res.start_pointer, res.end_pointer) {
            return .failure(Errno(rawValue: errno))
        } else {
            return .success(())
        }
    }
    public var array: Array<CChar> {
        get { return Array(buffer) }
    }
    public var buffer: UnsafeBufferPointer<CChar> {
        get { return UnsafeBufferPointer<CChar>(start: res.start_pointer!, count: res.end_pointer - res.start_pointer + 1) }
    }
}

@available(macOS 11, *)
public func GetArgvOfPid(pid: pid_t, skip: uint = 0, nuls: Bool = false) -> Result<PrintableArgvResult, Errno> {
    let options = GetArgvOptions(skip:skip, pid:pid, nuls:nuls)
    let res = PrintableArgvResult();
    if (!withUnsafePointer(to: options, { get_argv_of_pid($0, &res.res) })) { return .failure(Errno(rawValue: errno)) }
    return .success(res)
}

@available(macOS 11, *)
public func GetArgvAndArgcOfPid(pid: pid_t, encoding: String.Encoding) -> Result<Array<String>, Errno> {
    var res = ArgvArgcResult();
    if (!get_argv_and_argc_of_pid(pid, &res)) { return .failure(Errno(rawValue: errno)) }

    defer{free_ArgvArgcResult(&res)}

    do {
        return .success(Array(try UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>(start: res.argv, count: Int(res.argc)).map { try String(cString: $0!, encoding: encoding) }))
    } catch {
        return .failure(Errno(rawValue: EILSEQ))
    }
}
