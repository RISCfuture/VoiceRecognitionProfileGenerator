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
                return String(localized: "File must be ASCII-encoded only.", bundle: Bundle.module, comment: "command file error")
            case let .missingKeystroke(line):
                let error = String(localized: "Each line must start with a keystroke.", bundle: Bundle.module, comment: "command file error")
                return prependLine(error: error, line: line)
            case let .badFormat(line):
                let error = String(localized: "Bad formatting for line.", bundle: Bundle.module, comment: "command file error")
                return prependLine(error: error, line: line)
            case let .unexpectedIndent(line):
                let error = String(localized: "Unexpected indent.", bundle: Bundle.module, comment: "command file error")
                return prependLine(error: error, line: line)
            case let .badKeystroke(keystroke, line):
                let format = String(localized: "Couldn’t understand keystroke.", bundle: Bundle.module, comment: "command file error")
                return prependLine(error: String(format: format, keystroke), line: line)
            case let .unknownAlias(name, line):
                let format = String(localized: "Unknown alias “%@”.", bundle: Bundle.module, comment: "command file error")
                return prependLine(error: String(format: format, name), line: line)
            case let .aliasNameInUse(name, line):
                let format = String(localized: "Alias “%@” defined twice.", bundle: Bundle.module, comment: "command file error")
                return prependLine(error: String(format: format, name), line: line)
        }
    }

    private func prependLine(error: String, line: Int?) -> String {
        if let line {
            let format = String(localized: "Line %d: %@", bundle: Bundle.module, comment: "error with line number")
            return String(format: format, line, error)
        }
        return error
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
                let format = String(localized: "Keystroke “%@” is not supported.", bundle: Bundle.module, comment: "generator error")
                return String(format: format, keystroke.localizedDescription)
            case .chordingUnsupported:
                return String(localized: "Multiple simultaneous keystrokes (chording) is not supported.", bundle: Bundle.module, comment: "generator error")
        }
    }
}
