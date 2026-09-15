import Foundation

enum CommandFileErrors: Error, Sendable {
  case badEncoding
  case missingKeystroke(line: Int?)
  case badFormat(line: Int?)
  case unexpectedIndent(line: Int?)
  case badKeystroke(_ keystroke: String, line: Int?)
  case unknownAlias(_ alias: String, line: Int?)
  case aliasNameInUse(_ alias: String, line: Int?)
  case unknownExpansion(_ name: String, line: Int?)
  case expansionNameInUse(_ name: String, line: Int?)
}

extension CommandFileErrors: LocalizedError {
  var errorDescription: String? {
    switch self {
      case .badEncoding:
        return String(
          localized: "File must be ASCII-encoded only.",
          bundle: Bundle.module,
          comment: "command file error"
        )
      case let .missingKeystroke(line):
        let error = String(
          localized: "Each line must start with a keystroke.",
          bundle: Bundle.module,
          comment: "command file error"
        )
        return prependLine(error: error, line: line)
      case let .badFormat(line):
        let error = String(
          localized: "Bad formatting for line.",
          bundle: Bundle.module,
          comment: "command file error"
        )
        return prependLine(error: error, line: line)
      case let .unexpectedIndent(line):
        let error = String(
          localized: "Unexpected indent.",
          bundle: Bundle.module,
          comment: "command file error"
        )
        return prependLine(error: error, line: line)
      case let .badKeystroke(keystroke, line):
        let error = String(
          localized: "Couldn’t understand keystroke “\(keystroke)”.",
          bundle: Bundle.module,
          comment: "command file error"
        )
        return prependLine(error: error, line: line)
      case let .unknownAlias(name, line):
        let error = String(
          localized: "Unknown alias “\(name)”.",
          bundle: Bundle.module,
          comment: "command file error"
        )
        return prependLine(error: error, line: line)
      case let .aliasNameInUse(name, line):
        let error = String(
          localized: "Alias “\(name)” defined twice.",
          bundle: Bundle.module,
          comment: "command file error"
        )
        return prependLine(error: error, line: line)
      case let .unknownExpansion(name, line):
        let error = "Unknown expansion \"{\(name)}\"."
        return prependLine(error: error, line: line)
      case let .expansionNameInUse(name, line):
        let error = "Expansion \"{\(name)}\" defined twice."
        return prependLine(error: error, line: line)
    }
  }

  private func prependLine(error: String, line: Int?) -> String {
    if let line {
      return String(
        localized: "Line \(line, format: .number.grouping(.never)): \(error)",
        bundle: Bundle.module,
        comment: "error with line number"
      )
    }
    return error
  }
}

enum GeneratorErrors: Error, Sendable {
  case unsupportedKeystroke(_ keystroke: Keystroke)
  case chordingUnsupported
}

extension GeneratorErrors: LocalizedError {
  var errorDescription: String? {
    switch self {
      case let .unsupportedKeystroke(keystroke):
        return String(
          localized: "Keystroke “\(keystroke.localizedDescription)” is not supported.",
          bundle: Bundle.module,
          comment: "generator error"
        )
      case .chordingUnsupported:
        return String(
          localized: "Multiple simultaneous keystrokes (chording) is not supported.",
          bundle: Bundle.module,
          comment: "generator error"
        )
    }
  }
}
