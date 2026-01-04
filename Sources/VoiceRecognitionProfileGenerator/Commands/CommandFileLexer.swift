import Foundation
@preconcurrency import RegexBuilder

struct Token {
  let indent: [Substring]
  let keystrokes: [Substring]
  let phrases: [String]
  let aliasDefinition: String?
  let aliasReference: String?

  var indentLevel: Int { indent.count }
}

enum CommandFileLexer {
  nonisolated(unsafe) private static let indentsRef = Reference(Substring.self)
  nonisolated(unsafe) private static let keystrokesRef = Reference(Substring.self)
  nonisolated(unsafe) private static let phrasesRef = Reference(String?.self)
  nonisolated(unsafe) private static let aliasRef = Reference(String?.self)

  nonisolated(unsafe) private static let indent = Regex {
    ChoiceOf {
      "\t"; "  "
    }
  }

  nonisolated(unsafe) private static let indents = Regex {
    Capture(as: indentsRef) {
      ZeroOrMore { indent }
    }
  }

  nonisolated(unsafe) private static let literalKey = Regex {
    CharacterClass(
      "A"..."Z",
      "a"..."z",
      "0"..."9",
      .anyOf("`-=[]\\;',./")
    )
  }

  nonisolated(unsafe) private static let fkey = Regex {
    ChoiceOf {
      Regex {
        "F"
        ("1"..."9")
      }
      Regex {
        "F1"
        ("0"..."5")
      }
    }
  }

  nonisolated(unsafe) private static let arrow = Regex {
    ChoiceOf {
      "UP"; "DN"; "LT"; "RT"
    }
  }

  nonisolated(unsafe) private static let modifier = Regex {
    ChoiceOf {
      Regex {
        ChoiceOf {
          "L"; "R"
        }
        ChoiceOf {
          "SHIFT"; "CTRL"; "WIN"; "ALT"
        }
      }
      "APPS"
      "CAPS"
    }
  }

  nonisolated(unsafe) private static let carriage = Regex {
    ChoiceOf {
      "SPC"; "ENT"; "BKSP"; "TAB"; "ESC"
    }
  }

  nonisolated(unsafe) private static let movement = Regex {
    ChoiceOf {
      "INS"; "DEL"; "HOME"; "END"; "PGUP"; "PGDN"
    }
  }

  nonisolated(unsafe) private static let control = Regex {
    ChoiceOf {
      "PSC"; "SCLK"; "BRK"; "NUML"
    }
  }

  nonisolated(unsafe) private static let numpad = Regex {
    "NUM"
    ChoiceOf {
      CharacterClass("0"..."9", .anyOf("/*-+.="))
      "ENT"
      "CLR"
    }
  }

  nonisolated(unsafe) private static let keystroke = Regex {
    ChoiceOf {
      literalKey; fkey; arrow; modifier; carriage; movement; control; numpad
    }
  }

  nonisolated(unsafe) private static let keystrokeSeparator = Regex {
    OneOrMore { CharacterClass(.whitespace) }
    "+"
    OneOrMore { CharacterClass(.whitespace) }
  }

  nonisolated(unsafe) private static let keystrokes = Regex {
    Capture(as: keystrokesRef) {
      keystroke
      ZeroOrMore {
        keystrokeSeparator; keystroke
      }
    }
  }

  nonisolated(unsafe) private static let phrase = Regex {
    OneOrMore {
      CharacterClass("A"..."Z", "a"..."z", "0"..."9", .whitespace, .anyOf("'-"))
    }
  }

  nonisolated(unsafe) private static let phraseSeparator = Regex {
    ZeroOrMore { CharacterClass(.whitespace) }
    ","
    ZeroOrMore { CharacterClass(.whitespace) }
  }

  nonisolated(unsafe) private static let phrases = Regex {
    Capture(as: phrasesRef) {
      phrase
      ZeroOrMore {
        phraseSeparator; phrase
      }
    } transform: {
      String($0)
    }
  }

  nonisolated(unsafe) private static let aliasName = Regex {
    OneOrMore {
      CharacterClass("A"..."Z", "a"..."z", "0"..."9", .anyOf("_"))
    }
  }

  nonisolated(unsafe) private static let aliasDefinitionRx = Regex {
    "&"; aliasName
  }
  nonisolated(unsafe) private static let aliasReferenceRx = Regex {
    "*"; aliasName
  }
  nonisolated(unsafe) private static let alias = Regex {
    Capture(as: aliasRef) {
      ChoiceOf {
        aliasDefinitionRx; aliasReferenceRx
      }
    } transform: {
      String($0)
    }
  }

  nonisolated(unsafe) private static let lineRx = Regex {
    indents
    keystrokes
    Optionally {
      OneOrMore { CharacterClass(.whitespace) }
      phrases
    }
    Optionally {
      OneOrMore { CharacterClass(.whitespace) }
      alias
    }
    ZeroOrMore { CharacterClass(.whitespace) }
  }.anchorsMatchLineEndings()

  static func lex(line: String, lineNumber _: Int?) throws -> Token? {
    guard let match = try lineRx.wholeMatch(in: line) else { return nil }
    let phrasesMatch = match[phrasesRef] ?? ""

    let indents = match[indentsRef].matches(of: indent).map { match[indentsRef][$0.range] }
    let keystrokes = match[keystrokesRef].matches(of: keystroke).map {
      match[keystrokesRef][$0.range]
    }
    let phrases = phrasesMatch.matches(of: phrase)
      .map { phrasesMatch[$0.range].trimmingCharacters(in: .whitespaces) }
      .compactMap { $0.isEmpty ? nil : $0 }

    var aliasDefinition: Substring?,
      aliasReference: Substring?
    if let aliasUse = match[aliasRef] {
      if aliasUse.starts(with: "&") {
        aliasDefinition = aliasUse.suffix(from: aliasUse.index(after: aliasUse.startIndex))
      } else if aliasUse.starts(with: "*") {
        aliasReference = aliasUse.suffix(from: aliasUse.index(after: aliasUse.startIndex))
      }
    }

    return Token(
      indent: indents,
      keystrokes: keystrokes,
      phrases: phrases,
      aliasDefinition: aliasDefinition.map(String.init),
      aliasReference: aliasReference.map(String.init)
    )
  }
}
