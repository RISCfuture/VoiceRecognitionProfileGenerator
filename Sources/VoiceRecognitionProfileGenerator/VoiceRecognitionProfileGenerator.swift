import Foundation
import ArgumentParser

enum OutputFormat: String, ExpressibleByArgument {
    case vac
    case voiceAttack = "voiceattack"
}

@main
struct VoiceRecognitionProfileGenerator: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "The format to output")
    var format = OutputFormat.vac
    
    @Option(name: .shortAndLong, help: "A name for the profile (not used by VAC)")
    var name: String? = nil
    
    @Argument(help: "The path to the command set file", transform: { URL(filePath: $0, directoryHint: .notDirectory) })
    var commands: URL
    
    mutating func run() throws {
        let name = self.name
        let commands = self.commands
        let format = self.format
        
        Task { @MainActor in
            let name = name != nil ? name! : commands.deletingPathExtension().lastPathComponent
            
            let parser = try CommandFileParser(name: name, url: commands)
            do {
                try parser.parse()
            } catch {
                printStderr("Error while parsing \(commands.lastPathComponent):")
                Self.exit(withError: error)
            }
            
            let generator: Generator = switch format {
                case .vac: VACGenerator(commands: parser.set)
                case .voiceAttack: VoiceAttackGenerator(commands: parser.set)
            }
            
            let profile = try generator.generate()
            print(profile)
        }
    }
}

fileprivate func printStderr(_ string: String) {
    fputs(string + "\n", stderr)
}

