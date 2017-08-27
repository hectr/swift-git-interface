import Foundation
import ShellInterface

public struct ReadTagsNames: CustomStringConvertible
{
    public typealias Func = (_ context: TaskContext?) throws -> [String]
    
    private let refsName = "tags"
    
    private let read: ReadLocalReferencesNames.Func
    
    public var description: String
    {
        let reader = ReadLocalReferencesNames()
        let template = reader.description
        return template.replacingOccurrences(of: reader.refsPlaceholder, with: refsName)
    }
    
    public init(read: @escaping ReadLocalReferencesNames.Func = ReadLocalReferencesNames().execute)
    {
        self.read = read
    }
    
    // MARK: -
    
    public func execute(context: TaskContext? = TaskContext.current) throws -> [String]
    {
        return try read(refsName, context)
    }
}
