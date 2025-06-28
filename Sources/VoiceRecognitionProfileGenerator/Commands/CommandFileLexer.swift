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

@MainActor
enum CommandFileLexer {
    private static let indentsRef = Reference(Substring.self)
    private static let keystrokesRef = Reference(Substring.self)
    private static let phrasesRef = Reference(String?.self)
    private static let aliasRef = Reference(String?.self)

    private static let indent = Regex {
        ChoiceOf { "\t" ; "  " }
    }

    private static let indents = Regex {
        Capture(as: indentsRef) {
            ZeroOrMore { indent }
        }
    }

    private static let literalKey = Regex {
        CharacterClass("A"..."Z",
                       "a"..."z",
                       "0"..."9",
                       .anyOf("`-=[]\\;',./"))
    }

    private static let fkey = Regex {
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

    private static let arrow = Regex {
        ChoiceOf { "UP" ; "DN" ; "LT" ; "RT" }
    }

    private static let modifier = Regex {
        ChoiceOf {
            Regex {
                ChoiceOf { "L" ; "R" }
                ChoiceOf { "SHIFT" ; "CTRL" ; "WIN" ; "ALT" }
            }
            "APPS"
            "CAPS"
        }
    }

    private static let carriage = Regex {
        ChoiceOf { "SPC" ; "ENT" ; "BKSP" ; "TAB" ; "ESC" }
    }

    private static let movement = Regex {
        ChoiceOf { "INS" ; "DEL" ; "HOME" ; "END" ; "PGUP" ; "PGDN" }
    }

    private static let control = Regex {
        ChoiceOf { "PSC" ; "SCLK" ; "BRK" ; "NUML" }
    }

    private static let numpad = Regex {
        "NUM"
        ChoiceOf {
            CharacterClass("0"..."9", .anyOf("/*-+.="))
            "ENT"
            "CLR"
        }
    }

    private static let keystroke = Regex {
        ChoiceOf { literalKey ; fkey ; arrow ; modifier ; carriage ; movement ; control ; numpad }
    }

    private static let keystrokeSeparator = Regex {
        OneOrMore { CharacterClass(.whitespace) }
        "+"
        OneOrMore { CharacterClass(.whitespace) }
    }

    private static let keystrokes = Regex {
        Capture(as: keystrokesRef) {
            keystroke
            ZeroOrMore { keystrokeSeparator ; keystroke }
        }
    }

    private static let phrase = Regex {
        OneOrMore {
            CharacterClass("A"..."Z", "a"..."z", "0"..."9", .whitespace, .anyOf("'-"))
        }
    }

    private static let phraseSeparator = Regex {
        ZeroOrMore { CharacterClass(.whitespace) }
        ","
        ZeroOrMore { CharacterClass(.whitespace) }
    }

    private static let phrases = Regex {
        Capture(as: phrasesRef) {
            phrase
            ZeroOrMore { phraseSeparator ; phrase }
        } transform: { String($0) }
    }

    private static let aliasName = Regex {
        OneOrMore {
            CharacterClass("A"..."Z", "a"..."z", "0"..."9", .anyOf("_"))
        }
    }

    private static let aliasDefinitionRx = Regex { "&" ; aliasName }
    private static let aliasReferenceRx = Regex { "*" ; aliasName }
    private static let alias = Regex {
        Capture(as: aliasRef) {
            ChoiceOf { aliasDefinitionRx ; aliasReferenceRx }
        } transform: { String($0) }
    }

    private static let lineRx = Regex {
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
        let keystrokes = match[keystrokesRef].matches(of: keystroke).map { match[keystrokesRef][$0.range] }
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

        return Token(indent: indents,
                     keystrokes: keystrokes,
                     phrases: phrases,
                     aliasDefinition: aliasDefinition != nil ? String(aliasDefinition!) : nil,
                     aliasReference: aliasReference != nil ? String(aliasReference!) : nil )
    }
}
