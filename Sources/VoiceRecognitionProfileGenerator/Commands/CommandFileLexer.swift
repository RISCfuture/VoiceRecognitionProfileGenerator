import Foundation
import RegexBuilder

struct Token {
  let indent: [Substring]
  let keystrokes: [Substring]
  let phrases: [String]
  let aliasDefinition: String?
  let aliasReference: String?
  let expansionDefinition: (name: String, values: [String])?

  var indentLevel: Int { indent.count }
}

// Compiles its regexes once in init and reuses them read-only for every line.
// Build one instance per file and reuse it: the compiled `Regex` and `Reference`
// values are not Sendable, so a lexer can't be shared across isolation domains.
struct CommandFileLexer {
  private let indentsRef: Reference<Substring>
  private let keystrokesRef: Reference<Substring>
  private let phrasesRef: Reference<String?>
  private let aliasRef: Reference<String?>
  private let expansionNameRef: Reference<Substring>
  private let expansionValuesRef: Reference<Substring>

  private let indent: Regex<Substring>
  private let keystroke: Regex<Substring>
  private let phrase: Regex<Substring>
  private let expansionValue: Regex<Substring>

  private let expansionLineRx: Regex<(Substring, Substring, Substring)>
  private let lineRx: Regex<(Substring, Substring, Substring, String??, String??)>

  init() {
    let indentsRef = Reference(Substring.self)
    let keystrokesRef = Reference(Substring.self)
    let phrasesRef = Reference(String?.self)
    let aliasRef = Reference(String?.self)
    let expansionNameRef = Reference(Substring.self)
    let expansionValuesRef = Reference(Substring.self)

    let indent = Regex {
      ChoiceOf {
        "\t"; "  "
      }
    }

    let literalKey = Regex {
      CharacterClass(
        "A"..."Z",
        "a"..."z",
        "0"..."9",
        .anyOf("`-=[]\\;',./")
      )
    }

    let fkey = Regex {
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

    let arrow = Regex {
      ChoiceOf {
        "UP"; "DN"; "LT"; "RT"
      }
    }

    let modifier = Regex {
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

    let carriage = Regex {
      ChoiceOf {
        "SPC"; "ENT"; "BKSP"; "TAB"; "ESC"
      }
    }

    let movement = Regex {
      ChoiceOf {
        "INS"; "DEL"; "HOME"; "END"; "PGUP"; "PGDN"
      }
    }

    let control = Regex {
      ChoiceOf {
        "PSC"; "SCLK"; "BRK"; "NUML"
      }
    }

    let numpad = Regex {
      "NUM"
      ChoiceOf {
        CharacterClass("0"..."9", .anyOf("/*-+.="))
        "ENT"
        "CLR"
      }
    }

    let keystroke = Regex {
      ChoiceOf {
        literalKey; fkey; arrow; modifier; carriage; movement; control; numpad
      }
    }

    let keystrokeSeparator = Regex {
      OneOrMore { CharacterClass(.whitespace) }
      "+"
      OneOrMore { CharacterClass(.whitespace) }
    }

    let keystrokes = Regex {
      Capture(as: keystrokesRef) {
        keystroke
        ZeroOrMore {
          keystrokeSeparator; keystroke
        }
      }
    }

    let phrase = Regex {
      OneOrMore {
        CharacterClass("A"..."Z", "a"..."z", "0"..."9", .whitespace, .anyOf("'-{}"))
      }
    }

    let phraseSeparator = Regex {
      ZeroOrMore { CharacterClass(.whitespace) }
      ","
      ZeroOrMore { CharacterClass(.whitespace) }
    }

    let phrases = Regex {
      Capture(as: phrasesRef) {
        phrase
        ZeroOrMore {
          phraseSeparator; phrase
        }
      } transform: {
        String($0)
      }
    }

    let indents = Regex {
      Capture(as: indentsRef) {
        ZeroOrMore { indent }
      }
    }

    let aliasName = Regex {
      OneOrMore {
        CharacterClass("A"..."Z", "a"..."z", "0"..."9", .anyOf("_"))
      }
    }

    let aliasDefinitionRx = Regex {
      "&"; aliasName
    }
    let aliasReferenceRx = Regex {
      "*"; aliasName
    }
    let alias = Regex {
      Capture(as: aliasRef) {
        ChoiceOf {
          aliasDefinitionRx; aliasReferenceRx
        }
      } transform: {
        String($0)
      }
    }

    let expansionName = Regex {
      OneOrMore {
        CharacterClass("A"..."Z", "a"..."z", "0"..."9", .anyOf("_"))
      }
    }

    let expansionValue = Regex {
      OneOrMore {
        CharacterClass("A"..."Z", "a"..."z", "0"..."9", .whitespace, .anyOf("'-"))
      }
    }

    let expansionLineRx = Regex {
      "{"
      Capture(as: expansionNameRef) { expansionName }
      "}"
      ":"
      ZeroOrMore { CharacterClass(.whitespace) }
      Capture(as: expansionValuesRef) {
        expansionValue
        ZeroOrMore {
          phraseSeparator
          expansionValue
        }
      }
      ZeroOrMore { CharacterClass(.whitespace) }
    }.anchorsMatchLineEndings()

    let lineRx = Regex {
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

    self.indentsRef = indentsRef
    self.keystrokesRef = keystrokesRef
    self.phrasesRef = phrasesRef
    self.aliasRef = aliasRef
    self.expansionNameRef = expansionNameRef
    self.expansionValuesRef = expansionValuesRef
    self.indent = indent
    self.keystroke = keystroke
    self.phrase = phrase
    self.expansionValue = expansionValue
    self.expansionLineRx = expansionLineRx
    self.lineRx = lineRx
  }

  func lex(line: String, lineNumber _: Int?) throws -> Token? {
    // Try expansion definition line first (has no keystroke)
    if let expansionMatch = try expansionLineRx.wholeMatch(in: line) {
      let name = String(expansionMatch[expansionNameRef])
      let valuesString = expansionMatch[expansionValuesRef]
      let values = valuesString.matches(of: expansionValue)
        .map { String(valuesString[$0.range]).trimmingCharacters(in: .whitespaces) }
        .compactMap { $0.isEmpty ? nil : $0 }

      return Token(
        indent: [],
        keystrokes: [],
        phrases: [],
        aliasDefinition: nil,
        aliasReference: nil,
        expansionDefinition: (name: name, values: values)
      )
    }

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
      aliasReference: aliasReference.map(String.init),
      expansionDefinition: nil
    )
  }
}
