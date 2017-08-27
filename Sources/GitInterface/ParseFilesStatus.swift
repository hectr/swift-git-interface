import Foundation

public struct ParseFilesStatus
{
    public typealias Func = (_ diffOutput: String) throws -> [FileStatus]

    private let parseLine: ParseFileStatus.Func
    
    public init(parseLine: @escaping ParseFileStatus.Func = ParseFileStatus().execute)
    {
        self.parseLine = parseLine
    }
    
    // MARK: -
    
    public func execute(diffOutput: String) throws -> [FileStatus]
    {
        let lines = diffOutput.components(separatedBy: CharacterSet.newlines)
        let statuses = try lines.map { try parseLine($0) }
        return statuses
    }
}
