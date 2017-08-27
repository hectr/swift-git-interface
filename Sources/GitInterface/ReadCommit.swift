import Foundation
import ShellInterface

public struct ReadCommit: CustomStringConvertible
{
    public typealias Func = (_ sha1: String, _ context: TaskContext?) throws -> Void
    
    private let vcs:    String
    private let params: [String]
    private let shell:  ExecuteCommand.Func
    private let parse:  ParseCommit.Func
    
    public var description: String
    {
        let components = [vcs] + params + ["<commit>"]
        return components.joined(separator: " ")
    }
    
    public init(vcs:    String                        = "git",
                params: [String]                      = ["show", "-n1", "--name-status", "--format='commit-hash: %H%ntree-hash: %T%nparents-hashes: %P%nauthor-name: %an%nauthor-email: %ae%nauthor-date: %aI%ncommitter-name: %cn%ncommitter-email: %ce%ncommitter-date: %cI%nsubject: %s'"],
                shell:  @escaping ExecuteCommand.Func = ExecuteCommand().execute,
                parse:  @escaping ParseCommit.Func    = ParseCommit().execute)
    {
        self.vcs    = vcs
        self.params = params
        self.shell  = shell
        self.parse  = parse
    }
    
    // MARK: -
    
    public func execute(sha1: Sha1Hash, context: TaskContext? = TaskContext.current) throws -> Commit
    {
        let params = self.params + [sha1]
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
            throw TaskFailure.emptyOutput(file: #file, line: #line)
        }
        return try parse(output)
    }
}
