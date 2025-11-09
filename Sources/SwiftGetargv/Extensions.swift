import System

extension Optional {
    func toResult<E: Error>(
        err: E
    ) -> Result<Wrapped, E> {
        switch self {
        case .some(let v): .success(v)
        case .none: .failure(err)
        }
    }
}

@available(macOS 11, *)
extension String {
    static func decodeCString(
      cString cstr: UnsafePointer<CChar>,
      encoding enc: String.Encoding
    ) -> Result<String, Errno> {
        // https://developer.apple.com/documentation/swift/string/init(cstring:encoding:)-3h7bc
        unsafe String(cString: cstr, encoding: enc).toResult(err: .illegalByteSequence)
    }
}

extension UnsafeBufferPointer {
    func flatMapResult<Value, Error>(_ transform: (Self.Element) -> Result<Value, Error>) -> Result<[Value], Error> {
        var arr = [Value]()
        arr.reserveCapacity(self.count)
        return unsafe self.reduce(into: .success(arr)) { acc, el in
            // if accumulator is still a success so far
            if case .success(var arr) = acc {
                // transform current element, and:
                // if the result is a success, append its value to the array in the existing accumulator and set a .success with the array as the value as the accumulator
                // if the result is a failure, set the failure as the accumulator
                acc = transform(el).map {
                    arr.append($0)
                    return arr
                }
            }
        }
    }
}
