import Foundation
import RegexBuilder

class CommandFileParser {
  private let string: String
  let set: CommandSet

  required init(name: String, string: String) {
    self.string = string
    set = .init(name: name)
  }

  convenience init(name: String, url: URL) throws {
    self.init(name: name, string: try String(contentsOf: url, encoding: .ascii))
  }

  convenience init(name: String, data: Data) throws {
    guard let string = String(data: data, encoding: .ascii) else {
      throw CommandFileErrors.badEncoding
    }
    self.init(name: name, string: string)
  }

  func parse() throws {
    var parentStack = [Command]()

    var parseError: Error?

    var lineNum = 0
    string.enumerateLines { line, stop in
      lineNum += 1
      guard !line.isEmpty else { return }

      do {
        guard let token = try CommandFileLexer.lex(line: line, lineNumber: lineNum) else {
          throw CommandFileErrors.badFormat(line: lineNum)
        }

        if token.indentLevel == parentStack.count + 1 {
          guard let lastCommand = self.set.lastCommand else {
            throw CommandFileErrors.unexpectedIndent(line: lineNum)
          }
          parentStack.append(lastCommand)
        } else if token.indentLevel == parentStack.count {
          // do nothing
        } else if token.indentLevel < parentStack.count {
          for _ in token.indentLevel..<parentStack.count {
            parentStack.removeLast()
          }
        } else {
          throw CommandFileErrors.unexpectedIndent(line: lineNum)
        }

        let command = try self.commandFrom(token: token, parent: parentStack.last, line: lineNum)
        try self.set.add(command: command, withAlias: token.aliasDefinition)
        if let aliasRef = token.aliasReference {
          try self.expandAlias(parent: command, name: String(aliasRef))
        }
      } catch {
        parseError = error
        stop = true
      }
    }

    if let parseError { throw parseError }
  }

  private func commandFrom(token: Token, parent: Command?, line: Int?) throws -> Command {
    let keystrokes = try keystrokes(from: token.keystrokes.map { String($0) }, line: line)
    return Command(keystrokes: keystrokes, phrases: token.phrases, parent: parent)
  }

  private func expandAlias(parent: Command, name: String) throws {
    let command = try set.resolveAlias(name)
    let children = set.copyChildren(of: command, to: parent)
    try set.add(commands: children)
  }

  private func keystrokes(from strings: [String], line: Int?) throws -> [Keystroke] {
    let keystrokes = try strings.map { string in
      if let keystroke = specialKeystroke(from: string) { return keystroke }
      if let keystroke = modifierKeystroke(from: string) { return keystroke }
      if let keystroke = numpadKeystroke(from: string) { return keystroke }
      if let keystroke = functionKeystroke(from: string) { return keystroke }
      if let keystroke = literalKeystroke(from: string) { return keystroke }

      throw CommandFileErrors.badKeystroke(string, line: line)
    }

    guard keystrokes.allSatisfy(\.isValid) else {
      throw CommandFileErrors.badKeystroke(string, line: line)
    }

    return keystrokes
  }

  private func specialKeystroke(from string: String) -> Keystroke? {
    switch string {
      case "PSC": return .printScreen
      case "SCLK": return .scrollLock
      case "BRK": return .break
      case "NUML": return .numLock

      case "INS": return .insert
      case "DEL": return .forwardDelete
      case "HOME": return .home
      case "END": return .end
      case "PGUP": return .pageUp
      case "PGDN": return .pageDown

      case "SPC": return .character(" ")
      case "ENT": return .character("\n")
      case "BKSP": return .backspace
      case "TAB": return .character("\t")
      case "ESC": return .escape
      case "CAPS": return .capsLock

      case "UP": return .upArrow
      case "LT": return .leftArrow
      case "DN": return .downArrow
      case "RT": return .rightArrow

      default: return nil
    }
  }

  private func modifierKeystroke(from string: String) -> Keystroke? {
    switch string {
      case "APPS": return .apps
      case "SHIFT": return .shift(side: nil)
      case "CTRL": return .control(side: nil)
      case "WIN": return .windows(side: nil)
      case "ALT": return .alt(side: nil)

      default:
        let side: Side? =
          switch string.first {
            case "L": .left
            case "R": .right
            default: nil
          }
        guard let side else { return nil }

        switch string.suffix(from: string.index(after: string.startIndex)) {
          case "SHIFT": return .shift(side: side)
          case "CTRL": return .control(side: side)
          case "WIN": return .windows(side: side)
          case "ALT": return .alt(side: side)
          default: return nil
        }
    }
  }

  private func numpadKeystroke(from string: String) -> Keystroke? {
    guard string.starts(with: "NUM") else { return nil }
    let rest = string.suffix(from: string.index(string.startIndex, offsetBy: 3))

    if rest == "ENT" { return .numpad("\n") }
    if rest == "CLR" { return .clear }

    guard let char = rest.first, rest.count == 1 else { return nil }
    return .numpad(char)
  }

  private func functionKeystroke(from string: String) -> Keystroke? {
    guard string.starts(with: "F") else { return nil }
    guard let num = UInt8(string.suffix(from: string.index(after: string.startIndex))) else {
      return nil
    }
    return .function(num)
  }

  private func literalKeystroke(from string: String) -> Keystroke? {
    guard let char = string.first, string.count == 1 else { return nil }
    return .character(Character(char.lowercased()))
  }
}
