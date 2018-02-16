import Foundation

public struct ParseISO8601Date: CustomStringConvertible
{
    public typealias Func = (_ date: String) throws -> Date
    
    public enum Failure: Error
    {
        case invalidFormat (file: String, line: Int, date: String)
    }
 
    static let localeIdentifier = "en_US_POSIX"
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    private let formatter: DateFormatter = {
        let formatter        = DateFormatter()
        formatter.locale     = Locale(identifier: ParseISO8601Date.localeIdentifier)
        formatter.dateFormat = ParseISO8601Date.dateFormat
        return formatter
    }()
    
    public var description: String
    {
        return "\(formatter.dateFormat ?? "missing date format") (\(formatter.locale?.identifier ?? "missing locale")) -> Date"
    }
    
    public init() {}
    
    // MARK: -
    
    public func execute(date string: String) throws -> Date
    {
        guard let date = formatter.date(from: string) else {
            throw Failure.invalidFormat(file: #file, line: #line, date: string)
        }
        return date
    }
}
