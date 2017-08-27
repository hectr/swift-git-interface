import Foundation

public struct ParseLocalRefs
{
    public typealias Func = (_ lines: String) throws -> LocalRefsInfo
    
    public enum Failure: Error
    {
        case invalidFormat           (file: String, line: Int, reference: String)
        case missingMandatoryField   (file: String, line: Int, reference: String)
        case invalidLocalBranchName  (file: String, line: Int, reference: String, name: String)
        case invalidRemoteBranchName (file: String, line: Int, reference: String, name: String)
        case invalidTagName          (file: String, line: Int, reference: String, name: String)
    }
    
    // MARK: -
    
    public func execute(output: String) throws -> LocalRefsInfo
    {
        var branches = [Branch]()
        var tags     = [Tag]()
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            let components = line.components(separatedBy: " ")
            guard components.count == 2 else {
                throw Failure.invalidFormat(file: #file, line: #line, reference: line)
            }
            guard let commit = components.first else {
                throw Failure.missingMandatoryField(file: #file, line: #line, reference: line)
            }
            guard let fullName = components.last else {
                throw Failure.missingMandatoryField(file: #file, line: #line, reference: line)
            }
            if fullName.hasPrefix(LocalBranch.referencePrefix) {
                guard let prefixRange = fullName.range(of: LocalBranch.referencePrefix) else {
                    throw Failure.invalidLocalBranchName(file: #file, line: #line, reference: line, name: fullName)
                }
                let name = fullName.replacingCharacters(in: prefixRange, with: "")
                let branch = LocalBranch(name: name, tipCommit: commit)
                branches.append(branch)
            } else if fullName.hasPrefix(RemoteBranch.referencePrefix) {
                guard let prefixRange = fullName.range(of: RemoteBranch.referencePrefix) else {
                    throw Failure.invalidRemoteBranchName(file: #file, line: #line, reference: line, name: fullName)
                }
                let name = fullName.replacingCharacters(in: prefixRange, with: "")
                let branch = RemoteBranch(name: name, tipCommit: commit, remote: nil)
                branches.append(branch)
            } else if fullName.hasPrefix(Tag.referencePrefix) {
                guard let prefixRange = fullName.range(of: Tag.referencePrefix) else {
                    throw Failure.invalidTagName(file: #file, line: #line, reference: line, name: fullName)
                }
                let name = fullName.replacingCharacters(in: prefixRange, with: "")
                let tag = Tag(name: name, tipCommit: commit)
                tags.append(tag)
            } else if fullName == "refs/stash" {
                // no-op
            }
        }
        return LocalRefsInfo(branches: branches, tags: tags)
    }
}
