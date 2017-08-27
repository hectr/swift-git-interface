import Foundation

public struct ParseCommit
{
    public typealias Func = (_ lines: String) throws -> Commit
    
    public enum Failure: Error
    {
        case missingMandatoryField (file: String, line: Int, field: String)
    }
    
    private enum Field: String
    {
        case commitHash     = "commit-hash"
        case treeHash       = "tree-hash"
        case parentsHashes  = "parents-hashes"
        case authorName     = "author-name"
        case authorEmail    = "author-email"
        case authorDate     = "author-date"
        case committerName  = "committer-name"
        case committerEmail = "committer-email"
        case committerDate  = "committer-date"
        case subject        = "subject"
    }
    
    private let parseDate: ParseISO8601Date.Func
    private let parseLine: ParseFileStatus.Func
    
    public init(parseDate: @escaping ParseISO8601Date.Func = ParseISO8601Date().execute,
                parseLine: @escaping ParseFileStatus.Func  = ParseFileStatus().execute)
    {
        self.parseDate = parseDate
        self.parseLine = parseLine
    }
    
    // MARK: -
    
    public func execute(diffOutput: String) throws -> Commit
    {
        let lines = diffOutput.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        var commitHash:     String = ""
        var treeHash:       String = ""
        var parentsHashes:  String = ""
        var authorName:     String = ""
        var authorEmail:    String = ""
        var authorDate:     String = ""
        var committerName:  String = ""
        var committerEmail: String = ""
        var committerDate:  String = ""
        var subject:        String = ""
        var fileStatuses = [String]()
        for line in lines {
            guard !line.isEmpty else { continue }
            let components = line.components(separatedBy: ": ")
            guard components.count <= 2 else { continue }
            let key = components.first ?? ""
            let value = components.last ?? ""
            switch key {
            case "'" + Field.commitHash.rawValue: commitHash     = value
            case Field.treeHash.rawValue:         treeHash       = value
            case Field.parentsHashes.rawValue:    parentsHashes  = value
            case Field.authorName.rawValue:       authorName     = value
            case Field.authorEmail.rawValue:      authorEmail    = value
            case Field.authorDate.rawValue:       authorDate     = value
            case Field.committerName.rawValue:    committerName  = value
            case Field.committerEmail.rawValue:   committerEmail = value
            case Field.committerDate.rawValue:    committerDate  = value
            case Field.subject.rawValue:          subject        = stringByRemovingTrailingQuote(value)
            case "":                              continue
            default:                              fileStatuses.append(value)
            }
        }
        return try buildCommit(
            commitHash:     commitHash,
            treeHash:       treeHash,
            parentsHashes:  parentsHashes,
            authorName:     authorName,
            authorEmail:    authorEmail,
            authorDate:     authorDate,
            committerName:  committerName,
            committerEmail: committerEmail,
            committerDate:  committerDate,
            subject:        subject,
            fileStatuses:   fileStatuses
        )
    }
    
    private func stringByRemovingTrailingQuote(_ original: String) -> String {
        guard original.characters.last == "'" else { return original }
        return original.substring(to: original.index(before: original.endIndex))
    }
    
    private func buildCommit(commitHash: Sha1Hash, treeHash: Sha1Hash, parentsHashes: String, authorName: String, authorEmail: String, authorDate: String, committerName: String, committerEmail: String, committerDate: String, subject: String, fileStatuses: [String]) throws -> Commit
    {
        guard !commitHash.isEmpty else {
            throw buildMissingMandatoryFieldError(.commitHash)
        }
        guard !treeHash.isEmpty else {
                throw buildMissingMandatoryFieldError(.treeHash)
        }
        guard !parentsHashes.isEmpty else {
                throw buildMissingMandatoryFieldError(.parentsHashes)
        }
        guard !authorName.isEmpty else {
                throw buildMissingMandatoryFieldError(.authorName)
        }
        guard !authorEmail.isEmpty else {
                throw buildMissingMandatoryFieldError(.authorEmail)
        }
        guard !authorDate.isEmpty else {
                throw buildMissingMandatoryFieldError(.authorDate)
        }
        guard !committerName.isEmpty else {
                throw buildMissingMandatoryFieldError(.committerName)
        }
        guard !committerEmail.isEmpty else {
                throw buildMissingMandatoryFieldError(.committerEmail)
        }
        guard !committerDate.isEmpty else {
                throw buildMissingMandatoryFieldError(.committerDate)
        }
        return Commit(
            sha1: commitHash,
            tree: Tree(sha1: treeHash),
            parents: parentsHashes.components(separatedBy: .whitespacesAndNewlines),
            message: subject.isEmpty ? nil : MessageMetadata(subject: subject),
            author: UserMetadata(name: authorName, email: authorEmail, date: try parseDate(authorDate)),
            committer: UserMetadata(name: committerName, email: committerEmail, date: try parseDate(committerDate)),
            files: try fileStatuses.map { try parseLine($0) }
        )
    }
    
    private func buildMissingMandatoryFieldError(_ field: ParseCommit.Field, file: String = #file, line: Int = #line) -> Error
    {
        return Failure.missingMandatoryField(
            file: file,
            line: line,
            field: field.rawValue)
    }
}
