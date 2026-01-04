class Command {
  let keystrokes: [Keystroke]
  var phrases: [String]
  weak var parent: Command?

  var hasValidKeystrokes: Bool { keystrokes.allSatisfy(\.isValid) }

  var isTopLevel: Bool { parent == nil }

  var name: String {
    guard let parent else { return phrases.first ?? "" }
    return [parent.name, phrases.first].compactMap(\.self).joined(separator: " :: ")
  }

  var macro: [[Keystroke]] {
    ((parent?.macro ?? []) + [keystrokes]).compactMap(\.self)
  }

  var fullPhrases: [String] {
    guard let parent else { return phrases }
    if phrases.isEmpty { return parent.fullPhrases }

    return phrases.flatMap { phrase in
      parent.fullPhrases.map { "\($0) \(phrase)" }
    }
  }

  var root: Command { parent?.root ?? self }

  init(keystrokes: [Keystroke], phrases: [String] = [], parent: Command? = nil) {
    self.keystrokes = keystrokes
    self.parent = parent
    self.phrases = phrases
  }

  func copyTo(parent: Command?) -> Command {
    Command(keystrokes: Array(keystrokes), phrases: Array(phrases), parent: parent)
  }
}
