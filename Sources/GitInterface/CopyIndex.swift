import Foundation
import ShellInterface

public struct CopyIndex
{
    public typealias Func = (_ context: TaskContext) throws -> Data
    
    public init() {}
    
    // MARK: -
    
    public func execute(context: TaskContext = TaskContext.current) throws -> Data
    {
        let basePath = context.workingDirectory ?? ""
        let baseUrl = URL(fileURLWithPath: basePath)
        let url = baseUrl.appendingPathComponent(".git/index")
        let data = try Data(contentsOf: url)
        return data
    }
}
