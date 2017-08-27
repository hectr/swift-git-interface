import Foundation

public protocol Branch
{
    static var referencePrefix: String { get }
    
    var name:      String   { get }
    var tipCommit: Sha1Hash { get }
    var isLocal:   Bool     { get }
}

extension Branch
{
    public var referenceName: String
    {
        return "\(Self.referencePrefix)\(name)"
    }
}
