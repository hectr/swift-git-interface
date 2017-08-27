import Foundation

public struct UserMetadata
{
    public let name:     String
    public let email:    String
    public let date:     Date
}

// MARK: - CustomStringConvertible

extension UserMetadata: CustomStringConvertible
{
    public var description: String
    {
        let format = Format8601Date().execute
        return"\(name) <\(email)> \(format(date))" // FIXME: format date as UNIX timestamp
    }
}
