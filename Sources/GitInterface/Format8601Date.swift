import Foundation

public struct Format8601Date: CustomStringConvertible
{
    public typealias Func = (_ date: Date) -> String
    
    private let formatter: DateFormatter = {
        let formatter        = DateFormatter()
        formatter.locale     = Locale(identifier: ParseISO8601Date.localeIdentifier)
        formatter.dateFormat = ParseISO8601Date.dateFormat
        return formatter
    }()
    
    public var description: String
    {
        return "\(formatter.dateFormat ?? "missing date format") (\(formatter.locale?.identifier ?? "missing locale")) -> String"
    }
    
    // MARK: -
    
    public func execute(date: Date) -> String
    {
        return formatter.string(from: date)
    }
}
