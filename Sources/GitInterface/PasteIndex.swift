import Foundation
import ShellInterface

public struct PasteIndex
{
    public typealias Func = (_ data: Data, _ context: TaskContext) throws -> Void
    
    public init() {}
    
    // MARK: -
    
    public func execute(data: Data, context: TaskContext = TaskContext.current) throws
    {
        // FIXME: check file already exists
        let basePath = context.workingDirectory ?? ""
        let baseUrl = URL(fileURLWithPath: basePath)
        let url = baseUrl.appendingPathComponent(".git/index")
        try data.write(to: url, options: [.atomic])
    }
}
