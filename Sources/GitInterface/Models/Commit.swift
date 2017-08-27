import Foundation

public struct Commit
{
    public let sha1:      Sha1Hash
    public let tree:      Tree
    public let parents:   [Sha1Hash]
    public let message:   MessageMetadata?
    public let author:    UserMetadata
    public let committer: UserMetadata
    public let files:     [FileStatus]
}

// MARK: - CustomStringConvertible

extension Commit: CustomStringConvertible
{
    public var description: String
    {
        var string = String()
        string += "commit "    + sha1 + "\n"
        string += "tree "      + tree.sha1 + "\n"
        string += "parent "    + parents.joined(separator: " ") + "\n"
        string += "author "    + author.description + "\n"
        string += "committer " + committer.description + "\n"
        if let message = message {
            string += "\n" + message.description + "\n"
        }
        string += "\n" + files.map { $0.description }.joined(separator: "\n")
        return string
    }
}
