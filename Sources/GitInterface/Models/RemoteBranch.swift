import Foundation

public struct RemoteBranch: Branch
{
    public static let referencePrefix = "refs/remotes/"

    public let name:      String
    public let tipCommit: Sha1Hash
    public let remote:    String?
    
    public let isLocal = false
    
    public var referenceName: String
    {
        let prefix: String
        if let remote = remote {
            prefix = RemoteBranch.referencePrefix + remote + "/"
        } else {
            prefix = RemoteBranch.referencePrefix
        }
        return prefix + name
    }
}
