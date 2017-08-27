import Foundation

public struct LocalRefsInfo
{
    public let branches: [Branch]
    public let tags:     [Tag]
}

// MARK: - CustomStringConvertible

extension LocalRefsInfo: CustomStringConvertible
{
    public var description: String
    {
        var lines = [String]()
        for branch in branches {
            let hash = branch.tipCommit
            let referenceName = branch.referenceName
            let line = "\(hash) \(referenceName)"
            lines.append(line)
        }
        for tag in tags {
            let hash = tag.tipCommit
            let referenceName = tag.referenceName
            let line = "\(hash) \(referenceName)"
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }
}
