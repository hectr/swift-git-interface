import Foundation

public struct Tag
{
    public static let referencePrefix = "refs/tags/"
    
    public let name:      String
    public let tipCommit: Sha1Hash
    
    public var referenceName: String
    {
        return "\(Tag.referencePrefix)\(name)"
    }
}
