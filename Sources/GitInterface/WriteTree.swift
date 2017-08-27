import Foundation
import ShellInterface

public struct WriteTree: CustomStringConvertible
{
    public typealias Func = (_ context: TaskContext?) throws -> Tree
    
    private let vcs:    String
    private let params: [String]
    private let shell:  ExecuteCommand.Func
    
    public var description: String
    {
        let components = [vcs] + params
        return components.joined(separator: " ")
    }
    
    public init(vcs:    String                        = "git",
                params: [String]                      = ["write-tree"],
                shell:  @escaping ExecuteCommand.Func = ExecuteCommand().execute)
    {
        self.vcs    = vcs
        self.params = params
        self.shell  = shell
    }
    
    // MARK: -
    
    public func execute(context: TaskContext? = TaskContext.current) throws -> Tree
    {
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
        guard !result.standardOutput.isEmpty else {
            throw TaskFailure.emptyOutput(file: #file, line: #line)
        }
        return Tree(sha1: result.standardOutput)
    }
}
