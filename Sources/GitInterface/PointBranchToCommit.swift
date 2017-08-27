import Foundation
import ShellInterface

public struct PointBranchToCommit: CustomStringConvertible
{
    public typealias Func = (_ branch: String, _ newTipCommit: Sha1Hash, _ context: TaskContext?) throws -> Void
    
    private let vcs:    String
    private let params: [String]
    private let shell:  ExecuteCommand.Func
    
    public var description: String
    {
        let components = [vcs] + params + ["<branchname>", "<startpoint>"]
        return components.joined(separator: " ")
    }
    
    public init(vcs:    String                        = "git",
                params: [String]                      = ["branch", "-f"],
                shell:  @escaping ExecuteCommand.Func = ExecuteCommand().execute)
    {
        self.vcs    = vcs
        self.params = params
        self.shell  = shell
    }
    
    // MARK: -
    
    public func execute(branch name: String, newTipCommit: Sha1Hash, context: TaskContext? = TaskContext.current) throws
    {
        // FIXME: fail if branch is current branch
        let params = self.params + [name, newTipCommit]
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
    }
}
