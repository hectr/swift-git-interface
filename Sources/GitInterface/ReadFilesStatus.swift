import Foundation
import ShellInterface

public struct ReadFilesStatus: CustomStringConvertible
{
    public typealias Func = (_ diffCommit: String?, _ context: TaskContext?) throws -> [FileStatus]
    
    private let vcs:    String
    private let params: [String]
    private let shell:  ExecuteCommand.Func
    private let parse:  ParseFilesStatus.Func

    public var description: String
    {
        let components = [vcs] + params + ["<commit>"]
        return components.joined(separator: " ")
    }
    
    public init(vcs:    String                          = "git",
                params: [String]                        = ["diff", "--name-status"],
                shell:  @escaping ExecuteCommand.Func   = ExecuteCommand().execute,
                parse:  @escaping ParseFilesStatus.Func = ParseFilesStatus().execute)
    {
        self.vcs    = vcs
        self.params = params
        self.shell  = shell
        self.parse  = parse
    }
    
    // MARK: -
    
    public func execute(diffCommit: String?, context: TaskContext? = TaskContext.current) throws -> [FileStatus]
    {
        var params = self.params
        if let diffCommit = diffCommit {
            params.append(diffCommit)
        }
        let result = shell(vcs, params, context, true)
        guard let terminationStatus = result.terminationStatus else {
            throw TaskFailure.stillRunning(file: #file, line: #line)
        }
        guard terminationStatus == 0 else {
            throw TaskFailure.nonzeroTerminationStatus(
                file: #file,
                line: #line,
                terminationStatus: terminationStatus,
                uncaughtSignal: result.terminatedDueUncaughtSignal
            )
        }
        let output = result.standardOutput
        guard !output.isEmpty else {
            return []
        }
        return try parse(output)
    }
}
