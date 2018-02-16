import Foundation

public struct ParseFileStatus
{
    public typealias Func = (_ line: String) throws -> FileStatus
    
    public enum Failure: Error
    {
        case unexpectedEndOfLine     (file: String, line: Int, fileStatus: String)
        case couldNotParseFileStatus (file: String, line: Int, fileStatus: String)
        case couldNotParseFilename   (file: String, line: Int, fileStatus: String)
        case missingFromFilename     (file: String, line: Int, fileStatus: String)
        case missingToFilename       (file: String, line: Int, fileStatus: String)
        case missingFileMode         (file: String, line: Int, fileStatus: String)
        case invalidFileMode         (file: String, line: Int, fileStatus: String, mode: String)
    }
    
    public init() {}
    
    // MARK: -
    
    public func execute(diffOutput: String) throws -> FileStatus
    {
        var filestatus: FileStatus.Status? = nil
        var files: String? = nil
        var mode: String? = nil
        var from: String? = nil
        var to: String? = nil
        // parse status and files (with mode)
        let indexes = diffOutput.characters.indices
        for index in indexes {
            let substring = String(diffOutput.characters[index])
            guard substring != "\n" else {
                throw Failure.unexpectedEndOfLine(file: #file, line: #line, fileStatus: diffOutput)
            }
            let distance = diffOutput.characters.distance(from: diffOutput.characters.startIndex, to: index)
            if distance == 0 {
                filestatus = FileStatus.Status(rawValue: substring)
            } else if files == nil {
                guard substring != " " else { continue }
                files = substring
            } else {
                files?.append(substring)
            }
        }
        files = files?.trimmingCharacters(in: .whitespaces)
        guard let status = filestatus else {
            throw Failure.couldNotParseFileStatus(file: #file, line: #line, fileStatus: diffOutput)
        }
        guard let filename = files else {
            throw Failure.couldNotParseFilename(file: #file, line: #line, fileStatus: diffOutput)
        }
        // parse file mode and from and to filenames
        if hasMultipleFiles(status: filestatus) {
            let indexes = filename.characters.indices
            for index in indexes {
                let substring = String(filename.characters[index])
                if mode == nil {
                    mode = substring
                } else if from == nil {
                    guard substring != "\t" else {
                        from = ""
                        continue
                    }
                    mode?.append(substring)
                } else if to == nil {
                    guard substring != "\t" else {
                        to = ""
                        continue
                    }
                    from?.append(substring)
                } else {
                    to?.append(substring)
                }
            }
            to = to?.trimmingCharacters(in: .whitespaces)
            guard let fileMode = mode else {
                throw Failure.missingFileMode(file: #file, line: #line, fileStatus: diffOutput)
            }
            let invalidCharacterSet = CharacterSet.decimalDigits.inverted
            let range = fileMode.rangeOfCharacter(from: invalidCharacterSet)
            guard (range?.isEmpty ?? true) else {
                throw Failure.invalidFileMode(file: #file, line: #line, fileStatus: diffOutput, mode: fileMode)
            }
            guard to != nil else {
                throw Failure.missingToFilename(file: #file, line: #line, fileStatus: diffOutput)
            }
        } else {
            from = filename
        }
        guard let fromFilename = from else {
            throw Failure.missingFromFilename(file: #file, line: #line, fileStatus: diffOutput)
        }
        // build and return file status
        return FileStatus(
            from: fromFilename,
            to: to,
            status: status,
            mode: mode
        )
    }
    
    private func hasMultipleFiles(status: FileStatus.Status?) -> Bool
    {
        guard let status = status else { return false }
        switch status {
        case .added,      .deleted,   .modified,
             .changeType, .unmerged,  .unknown,
             .unmodified, .untracked, .ignored:
            return false
        case .copied, .renamed:
            return true
        }
    }
}
