import Foundation

public struct LocalBranch: Branch
{
    public static let referencePrefix = "refs/heads/"

    public let name:      String
    public let tipCommit: Sha1Hash
    
    public let isLocal = true
}
