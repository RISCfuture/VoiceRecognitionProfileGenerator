import Foundation

private extension CommandSet {
  func isPrefix(_ command: Command) -> Bool {
    command.isTopLevel && hasChildren(command)
  }

  func compositeGroup(_ command: Command) -> String {
    let source = isPrefix(command) ? command : command.root
    return source.phrases.first ?? ""
  }
}

private extension Command {
  var suffixPhrases: [String] {
    guard let parent else {
      preconditionFailure("suffixPhrases method should not be called on root nodes")
    }
    if parent.isTopLevel { return phrases }
    if phrases.isEmpty { return parent.suffixPhrases }
    if parent.suffixPhrases.isEmpty { return phrases }

    return phrases.flatMap { phrase in
      parent.suffixPhrases.map { parentPhrase in
        "\(parentPhrase) \(phrase)"
      }
    }
  }
}

private extension XMLElement {
  static let xsiNil = ["xsi:nil": "true"]

  func addNilChildren(_ names: String...) {
    let children = names.map { XMLElement.make($0, attributes: Self.xsiNil) }
    for child in children { addChild(child) }
  }
}

class VoiceAttackGenerator: Generator {
  private static let guidNil = "00000000-0000-0000-0000-000000000000"

  // Virtual key codes for characters (mostly ASCII but not entirely)
  private static let characterKeyCodes: [Character: Int] = [
    "\t": 9, "\n": 13, " ": 32,
    "0": 48, "1": 49, "2": 50, "3": 51, "4": 52,
    "5": 53, "6": 54, "7": 55, "8": 56, "9": 57,
    "a": 65, "b": 66, "c": 67, "d": 68, "e": 69, "f": 70, "g": 71,
    "h": 72, "i": 73, "j": 74, "k": 75, "l": 76, "m": 77, "n": 78,
    "o": 79, "p": 80, "q": 81, "r": 82, "s": 83, "t": 84, "u": 85,
    "v": 86, "w": 87, "x": 88, "y": 89, "z": 90,
    ";": 186, "=": 187, ",": 188, "-": 189, ".": 190, "/": 191,
    "`": 223, "[": 219, "\\": 220, "]": 221, "'": 222
  ]

  // Virtual key codes for numpad keys
  private static let numpadKeyCodes: [Character: Int] = [
    "0": 96, "1": 97, "2": 98, "3": 99, "4": 100,
    "5": 101, "6": 102, "7": 103, "8": 104, "9": 105,
    "*": 106, "+": 107, "-": 109, ".": 110, "/": 111
  ]

  private let commands: CommandSet

  required init(commands: CommandSet) {
    self.commands = commands
  }

  private static func keyCode(for keystroke: Keystroke) throws -> Int? {
    switch keystroke {
      case let .character(char):
        guard let code = characterKeyCodes[char] else {
          throw GeneratorErrors.unsupportedKeystroke(keystroke)
        }
        return code
      case let .function(num): return 111 + Int(num)
      case .shift(let side):
        guard side == nil else { throw GeneratorErrors.unsupportedKeystroke(keystroke) }
        return nil
      case .control(let side):
        guard side == nil else { throw GeneratorErrors.unsupportedKeystroke(keystroke) }
        return nil
      case .alt(let side):
        guard side == nil else { throw GeneratorErrors.unsupportedKeystroke(keystroke) }
        return nil
      case .windows(let side):
        switch side {
          case .left: return 91
          case .right: return 02
          case nil: throw GeneratorErrors.unsupportedKeystroke(keystroke)
        }
      case .apps: return 93
      case .backspace: return 8
      case .escape: return 27
      case .capsLock: throw GeneratorErrors.unsupportedKeystroke(keystroke)
      case .insert: return 45
      case .forwardDelete: return 46
      case .home: return 36
      case .end: return 35
      case .pageUp: return 33
      case .pageDown: return 34
      case .printScreen: return 44
      case .break: return 3
      case .scrollLock: return 145
      case .numLock: return 144
      case let .numpad(char):
        guard let code = numpadKeyCodes[char] else {
          throw GeneratorErrors.unsupportedKeystroke(keystroke)
        }
        return code
      case .clear: return 12
      case .upArrow: return 38
      case .leftArrow: return 37
      case .downArrow: return 40
      case .rightArrow: return 39
    }
  }

  func generate() throws -> String {
    let root = XMLElement.make(
      "Profile",
      attributes: [
        "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:xsd": "http://www.w3.org/2001/XMLSchema"
      ]
    )
    let xml = XMLDocument(rootElement: root)
    root.addChildren([
      "HasMB": "false",
      "Id": UUID().uuidString.lowercased(),
      "OverrideGlobal": "false",
      "GlobalHotkeyIndex": "0",
      "GlobalHotkeyEnabled": "false",
      "GlobalHotkeyValue": "0",
      "GlobalHotkeyShift": "0",
      "GlobalHotkeyAlt": "0",
      "GlobalHotkeyCtrl": "0",
      "GlobalHotkeyWin": "0",
      "GlobalHotkeyPassThru": "false",
      "OverrideMouse": "false",
      "MouseIndex": "0",
      "OverrideStop": "false",
      "StopCommandHotkeyEnabled": "false",
      "StopCommandHotkeyValue": "0",
      "StopCommandHotkeyShift": "0",
      "StopCommandHotkeyAlt": "0",
      "StopCommandHotkeyCtrl": "0",
      "StopCommandHotkeyWin": "0",
      "StopCommandHotkeyPassThru": "false",
      "DisableShortcuts": "false",
      "UseOverrideListening": "false",
      "OverrideJoystickGlobal": "false",
      "GlobalJoystickIndex": "0",
      "GlobalJoystickButton": "0",
      "GlobalJoystickNumber": "0",
      "GlobalJoystickButton2": "0",
      "GlobalJoystickNumber2": "0",
      "ExportVAVersion": "1.7.5",
      "ExportOSVersionMajor": "6",
      "ExportOSVersionMinor": "2",
      "OverrideConfidence": "false",
      "Confidence": "0",
      "CatchAllEnabled": "false",
      "InitializeCommandEnabled": "false",
      "UseProcessOverride": "false",
      "ProcessOverrideAciveWindow": "true",
      "DictationCommandEnabled": "false",
      "EnableProfileSwitch": "false",
      "GroupCategory": "false",
      "LastEditedCommand": Self.guidNil,
      "IS": "0",
      "IO": "0",
      "IP": "0",
      "BE": "0",
      "UnloadCommandEnabled": "false",
      "BlockExternal": "false",
      "CR": "0",

      "Name": commands.name
    ])
    root.addNilChildren(
      "ReferencedProfile",
      "CatchAllId",
      "DictationCommandId",
      "UnloadCommandId",
      "AuthorID",
      "ProductID",
      "InternalID"
    )

    let commandsNode = XMLElement(name: "Commands")
    try commands.each { command in
      guard commands.isPrefix(command) || commands.isReal(command) else { return }
      try commandsNode.addChild(xmlElement(for: command))
    }
    root.addChild(commandsNode)

    return xml.xmlString(options: .nodePrettyPrint)
  }

  private func xmlElement(for command: Command) throws -> XMLElement {
    let commandString =
      commands.isPrefix(command)
      ? command.phrases.joined(separator: ";") : command.suffixPhrases.joined(separator: ";")

    let node = XMLElement(name: "Command")
    node.addChildren([
      "ExecType": "3",
      "Confidence": "0",
      "PrefixActionCount": "0",
      "IsDynamicallyCreated": "false",
      "TargetProcessSet": "false",
      "TargetProcessType": "0",
      "TargetProcessLevel": "0",
      "CompareType": "0",
      "ExecFromWildcard": "false",
      "IsSubCommand": "false",
      "IsOverride": "false",
      "BaseId": UUID().uuidString.lowercased(),
      "OriginId": Self.guidNil,
      "SessionEnabled": "true",
      "Id": UUID().uuidString.lowercased(),
      "Enabled": "true",
      "UseShortcut": "false",
      "keyValue": "0",
      "keyShift": "0",
      "keyAlt": "0",
      "keyCtrl": "0",
      "keyWin": "0",
      "keyPassthru": "true",
      "UseSpokenPhrase": "true",
      "onlyKeyUp": "false",
      "RepeatNumber": "2",
      "RepeatType": "0",
      "SourceProfile": Self.guidNil,
      "UseConfidence": "false",
      "minimumConfidenceLevel": "0",
      "UseJoystick": "false",
      "joystickNumber": "0",
      "joystickButton": "0",
      "joystickNumber2": "0",
      "joystickButton2": "0",
      "joystickUp": "false",
      "KeepRepeating": "false",
      "UseProcessOverride": "false",
      "ProcessOverrideActiveWindow": "true",
      "LostFocusStop": "false",
      "PauseLostFocus": "false",
      "LostFocusBackCompat": "true",
      "UseMouse": "false",
      "Mouse1": "false",
      "Mouse2": "false",
      "Mouse3": "false",
      "Mouse4": "false",
      "Mouse5": "false",
      "Mouse6": "false",
      "Mouse7": "false",
      "Mouse8": "false",
      "Mouse9": "false",
      "MouseUpOnly": "false",
      "MousePassThru": "true",
      "joystickExclusive": "false",
      "lastEditedAction": Self.guidNil,
      "UseProfileProcessOverride": "false",
      "ProfileProcessOverrideActiveWindow": "false",
      "RepeatIfKeysDown": "false",
      "RepeatIfMouseDown": "false",
      "RepeatIfJoystickDown": "false",
      "AH": "0",
      "CL": "0",
      "HasMB": "false",
      "UseVariableHotkey": "false",
      "CLE": "0",
      "EX1": "false",
      "EX2": "false",

      "CommandString": commandString,
      "Async": commands.isReal(command) ? "false" : "true",
      "Description": command.phrases.first ?? command.name,
      "Category": command.root.phrases.first ?? "Uncategorized",
      "CommandType": commands.isPrefix(command) ? "1" : "2",
      "CompositeGroup": commands.compositeGroup(command)
    ])
    node.addNilChildren("Referrer", "InternalId")

    if commands.isReal(command) {
      try node.addChild(actionSequenceElement(for: command))
    } else {
      node.addChild(XMLElement(name: "ActionSequence"))
    }

    return node
  }

  private func actionSequenceElement(for command: Command) throws -> XMLElement {
    let node = XMLElement(name: "ActionSequence")

    for (index, keystrokes) in command.macro.enumerated() {
      guard let keystroke = keystrokes.first, keystrokes.count == 1 else {
        throw GeneratorErrors.chordingUnsupported
      }

      let commandAction = try commandAction(for: keystroke, index: index)
      node.addChild(commandAction)
    }

    return node
  }

  private func commandAction(for keystroke: Keystroke, index: Int) throws -> XMLElement {
    let node = XMLElement(name: "CommandAction")
    let caption = "Press \(keystroke.localizedDescription) key and hold for 0.1 seconds and release"

    node.addChildren([
      "PairingSet": "false",
      "PairingSetElse": "false",
      "Ordinal": String(index),
      "IndentLevel": "0",
      "ConditionSkip": "false",
      "IsSuffixAction": "false",
      "DecimalTransient1": "0",
      "id": UUID().uuidString.lowercased(),
      "ActionType": "PressKey",
      "Duration": "0.1",
      "Delay": "0",
      "Context": nil,
      "X": "0",
      "Y": "0",
      "Z": "0",
      "InputMode": "0",
      "ConditionPairing": "0",
      "ConditionGroup": "0",
      "ConditionStartOperator": "0",
      "ConditionStartValue": "0",
      "ConditionStartValueType": "0",
      "ConditionStartType": "0",
      "DecimalContext1": "0",
      "DecimalContext2": "0",
      "DateContext1": "0001-01-01T00:00:00",
      "DateContext2": "0001-01-01T00:00:00",
      "Disabled": "false",
      "RandomSounds": nil,

      "_caption": caption,
      "Caption": caption
    ])
    node.addNilChildren("ConditionMet")

    let keyCodes = XMLElement(name: "KeyCodes")
    guard let keyCode = try Self.keyCode(for: keystroke) else {
      throw GeneratorErrors.unsupportedKeystroke(keystroke)
    }
    keyCodes.addChild(XMLElement(name: "unsignedShort", stringValue: String(keyCode)))
    node.addChild(keyCodes)

    return node
  }
}
