import ArgumentParser
import Foundation

enum OutputFormat: String, ExpressibleByArgument {
  case vac
  case voiceAttack = "voiceattack"
}

@main
struct VoiceRecognitionProfileGenerator: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "generate-profile",
    abstract: "Generates VoiceAttack and VAC profiles from a simple rules file.",
    usage: """
      This tool generates both VAC (https://www.dwvac.com) and VoiceAttack
      (https://voiceattack.com) profiles for voice recognition intended
      for use in video gaming. **VAC** is a simple voice recognition macro
      utility that recognizes voice commands and executes keyboard and
      mouse macros. VoiceAttack is similar to VAC but has much more complex
      macro tools. Both are intended for video gamers to allow hands-off
      control of their games.

      This script reads voice commands generated from a simple, easy-to-write
      nested domain-specific language (DSL). The DSL is optimized for games
      that use nested menus for generating commands that communicate with
      NPCs.
      """
  )

  @Option(name: .shortAndLong, help: "The format to output")
  var format = OutputFormat.vac

  @Option(name: .shortAndLong, help: "A name for the profile (not used by VAC)")
  var name: String?

  @Argument(
    help: "The path to the command set file",
    transform: { URL(filePath: $0, directoryHint: .notDirectory) }
  )
  var commands: URL

  mutating func run() throws {
    let name = self.name
    let commands = self.commands
    let format = self.format

    Task { @MainActor in
      let name = name != nil ? name! : commands.deletingPathExtension().lastPathComponent

      do {
        let parser = try CommandFileParser(name: name, url: commands)
        try parser.parse()

        let generator: Generator =
          switch format {
            case .vac: VACGenerator(commands: parser.set)
            case .voiceAttack: VoiceAttackGenerator(commands: parser.set)
          }

        let profile = try generator.generate()
        print(profile)
      } catch {
        printStderr("Error while parsing \(commands.lastPathComponent):")
        Self.exit(withError: error)
      }
    }
  }
}

private func printStderr(_ string: String) {
  fputs(string + "\n", stderr)
}
