import Foundation

enum CommandFileErrors: Error {
    case badEncoding
    case missingKeystroke(line: Int?)
    case badFormat(line: Int?)
    case unexpectedIndent(line: Int?)
    case badKeystroke(_ keystroke: String, line: Int?)
    case unknownAlias(_ alias: String, line: Int?)
    case aliasNameInUse(_ alias: String, line: Int?)
}

extension CommandFileErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .badEncoding:
                return NSLocalizedString("File must be ASCII-encoded only.", comment: "command file error")
            case let .missingKeystroke(line):
                let error = NSLocalizedString("Each line must start with a keystroke.", comment: "command file error")
                return prependLine(error: error, line: line)
            case let .badFormat(line):
                let error = NSLocalizedString("Bad formatting for line.", comment: "command file error")
                return prependLine(error: error, line: line)
            case let .unexpectedIndent(line):
                let error = NSLocalizedString("Unexpected indent.", comment: "command file error")
                return prependLine(error: error, line: line)
            case let .badKeystroke(keystroke, line):
                let format = NSLocalizedString("Couldn’t understand keystroke.", comment: "command file error")
                return prependLine(error: String(format: format, keystroke), line: line)
            case let .unknownAlias(name, line):
                let format = NSLocalizedString("Unknown alias “%@”.", comment: "command file error")
                return prependLine(error: String(format: format, name), line: line)
            case let .aliasNameInUse(name, line):
                let format = NSLocalizedString("Alias “%@” defined twice.", comment: "command file error")
                return prependLine(error: String(format: format, name), line: line)
        }
    }
    
    private func prependLine(error: String, line: Int?) -> String {
        if let line = line {
            let format = NSLocalizedString("Line %d: %@", comment: "error with line number")
            return String(format: format, line, error)
        } else {
            return error
        }
    }
}

enum GeneratorErrors: Error {
    case unsupportedKeystroke(_ keystroke: Keystroke)
    case chordingUnsupported
}

extension GeneratorErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case let .unsupportedKeystroke(keystroke):
                let format = NSLocalizedString("Keystroke “%@” is not supported.", comment: "generator error")
                return String(format: format, keystroke.localizedDescription)
            case .chordingUnsupported:
                return NSLocalizedString("Multiple simultaneous keystrokes (chording) is not supported.", comment: "generator error")
        }
    }
}
