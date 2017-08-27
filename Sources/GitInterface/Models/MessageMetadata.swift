import Foundation

public struct MessageMetadata
{
    public let subject: String
}

// MARK: - CustomStringConvertible

extension MessageMetadata: CustomStringConvertible
{
    public var description: String
    {
        return "\t" + subject // FIXME: include body (full message)
    }
}
