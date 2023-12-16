class Command {
    let keystrokes: Array<Keystroke>
    var phrases: Array<String>
    weak var parent: Command? = nil
    
    init(keystrokes: Array<Keystroke>, phrases: Array<String> = [], parent: Command? = nil) {
        self.keystrokes = keystrokes
        self.parent = parent
        self.phrases = phrases
    }
    
    var hasValidKeystrokes: Bool { keystrokes.allSatisfy(\.isValid) }
    
    var isTopLevel: Bool { parent == nil }
    
    var name: String {
        if isTopLevel { return phrases.first ?? "" }
        return [parent!.name, phrases.first].compactMap { $0 }.joined(separator: " :: ")
    }
    
    var macro: Array<Array<Keystroke>> {
        ((parent?.macro ?? []) + [keystrokes]).compactMap { $0 }
    }
    
    var fullPhrases: Array<String> {
        if isTopLevel { return phrases }
        if phrases.isEmpty { return parent!.fullPhrases }
        
        return phrases.flatMap { phrase in
            parent!.fullPhrases.map { "\($0) \(phrase)" }
        }
    }
    
    var root: Command { isTopLevel ? self : parent!.root }
    
    func copyTo(parent: Command?) -> Command {
        Command(keystrokes: Array(keystrokes), phrases: Array(phrases), parent: parent)
    }
}
