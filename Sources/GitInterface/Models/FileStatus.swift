import Foundation

public struct FileStatus
{
    public enum Status: String
    {
        case added      = "A"
        case copied     = "C"
        case deleted    = "D"
        case modified   = "M"
        case renamed    = "R"
        case changeType = "T"
        case unmerged   = "U"
        case unknown    = "X"
        case unmodified = " "
        case untracked  = "?"
        case ignored    = "!"
    }
    
    public let from:   String
    public let to:     String?
    public let status: FileStatus.Status
    public let mode:   String?
}

// MARK: - CustomStringConvertible

extension FileStatus: CustomStringConvertible
{
    public var description: String
    {
        let filenames: String
        if let to = to {
            filenames = "\t" + from + "\t" + to
        } else {
            filenames = "\t" + from
        }
        return status.rawValue + (mode ?? "") + filenames
    }
}
