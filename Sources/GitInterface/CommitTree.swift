import Foundation
import ShellInterface

public struct CommitTree: CustomStringConvertible
{
    public typealias Func = (_ message: String, _ tree: Tree, _ parent: Sha1Hash, _ context: TaskContext?) throws -> Sha1Hash
    
    private let vcs:    String
    private let param0: String
    private let param2: String
    private let param4: String
    private let shell:  ExecuteCommand.Func
    
    public var description: String
    {
        let params = buildParams(
            message: "<message>",
            tree:    "<tree>",
            parent:  "<parent>"
        )
        let components = [vcs] + params
        return components.joined(separator: " ")
    }
    
    public init(vcs:    String                        = "git",
                param0: String                        = "commit-tree",
                param2: String                        = "-p",
                param4: String                        = "-m",
                shell:  @escaping ExecuteCommand.Func = ExecuteCommand().execute)
    {
        self.vcs    = vcs
        self.param0 = param0
        self.param2 = param2
        self.param4 = param4
        self.shell  = shell
    }
    
    // MARK: -
    
    public func execute(message: String, tree: Tree, parent: Sha1Hash, context: TaskContext? = TaskContext.current) throws -> Sha1Hash
    {
        let params = buildParams(
            message: message,
            tree:    tree.sha1,
            parent:  parent
        )
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
        return result.standardOutput
    }
    
    private func buildParams(message: String, tree: Sha1Hash, parent: Sha1Hash) -> [String]
    {
        return [
            param0, tree,
            param2, parent,
            param4, message
        ]
    }

}
