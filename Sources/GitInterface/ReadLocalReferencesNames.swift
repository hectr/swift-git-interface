import Foundation
import ShellInterface

public struct ReadLocalReferencesNames: CustomStringConvertible
{
    public typealias Func = (_ ref: String, _ context: TaskContext?) throws -> [String]
    
    internal let refsPlaceholder = "<refs>"
    
    private let vcs:    String
    private let params: [String]
    private let shell:  ExecuteCommand.Func
    
    public var description: String
    {
        let components = [vcs] + params + [refPath(for: refsPlaceholder)]
        return components.joined(separator: " ")
    }
    
    public init(vcs:    String                        = "git",
                params: [String]                      = ["for-each-ref", "--format='%(refname:short)'"],
                shell:  @escaping ExecuteCommand.Func = ExecuteCommand().execute)
    {
        self.vcs    = vcs
        self.params = params
        self.shell  = shell
    }
    
    // MARK: -
    
    public func execute(refs: String, context: TaskContext? = TaskContext.current) throws -> [String]
    {
        let params = self.params + [refPath(for: refs)]
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
        let quotedNames = output.components(separatedBy: "\n")
        let quotesCharacterSet = CharacterSet(charactersIn: "'")
        let names = quotedNames.map { $0.trimmingCharacters(in: quotesCharacterSet) }
        return names
    }
    
    private func refPath(for refs: String) -> String
    {
        return "refs/\(refs)/"
    }
}
