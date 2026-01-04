import Foundation

class VACGenerator: Generator {
  private let commands: CommandSet

  var defaultKeystrokeAttributes = [
    "qual": "NONE",
    "pause": "60",
    "repeat": "1",
    "duration": "60"
  ]

  required init(commands: CommandSet) {
    self.commands = commands
  }

  func generate() throws -> String {
    let root = XMLElement(name: "profile")
    let xml = XMLDocument(rootElement: root)

    try commands.each { command in
      guard commands.isReal(command) else { return }
      try root.addChild(xmlElement(for: command))
    }

    root.addChild(
      XMLElement.make(
        "set",
        attributes: [
          "key": "NONE",
          "key1": "NONE",
          "vackey1": "NONE",
          "vackey2": "NONE",
          "ptamode": "default",
          "off": "NONE",
          "off1": "NONE",
          "off2": "NONE",
          "off3": "NONE"
        ]
      )
    )

    return xml.xmlString(options: .nodePrettyPrint)
  }

  private func xmlElement(for command: Command) throws -> XMLElement {
    let element = XMLElement(name: "command")
    element.setAttribute(name: "name", value: command.name)

    for (index, phrase) in command.fullPhrases.enumerated() {
      let name = (index == 0 ? "phrase" : "phrase\(index)")
      element.setAttribute(name: name, value: phrase)
    }

    for keystrokes in command.macro {
      guard let keystroke = keystrokes.first, keystrokes.count == 1 else {
        throw GeneratorErrors.chordingUnsupported
      }
      try element.addChild(xmlElement(for: keystroke))
    }

    return element
  }

  private func xmlElement(for keystroke: Keystroke) throws -> XMLElement {
    let element = XMLElement(name: "key")
    element.addAttributes(defaultKeystrokeAttributes)

    switch keystroke {
      case let .character(char):
        element.addAttributes([
          "value": String(char),
          "extended": "NONE",
          "extended2": "NONE"
        ])
      case let .function(num):
        element.addAttributes([
          "extended": "F\(num)",
          "extended2": "NONE"
        ])
      default: throw GeneratorErrors.unsupportedKeystroke(keystroke)
    }

    return element
  }
}
