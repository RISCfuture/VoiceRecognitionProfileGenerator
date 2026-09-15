# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-09-15

### Added

- Expansions in the DSL. A line such as `{tankerNames}: Texaco, Copper, Camel`
  defines a named list of alternatives, and referencing `{tankerNames}` in a
  phrase lets any of them be spoken at that position.

### Changed

- VoiceAttack profiles are written in the VoiceAttack 2.1.8 profile format.
- Alternative phrasings of a command are emitted as a single VoiceAttack
  command using dynamic command section syntax (`[one;two]`) instead of paired
  prefix and suffix commands.
- The bundled Falcon BMS 4.38 profile uses expansions for airbase, flight,
  AWACS, and tanker names, so flights and facilities can be addressed by name.

### Fixed

- An unrecognized keystroke is now named in the error message instead of being
  dropped from it.
- The generated profile is fully written before the tool exits.

## [1.0.0] - 2026-01-19

### Added

- Initial release.

[Unreleased]: https://github.com/RISCfuture/VoiceRecognitionProfileGenerator/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/RISCfuture/VoiceRecognitionProfileGenerator/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/RISCfuture/VoiceRecognitionProfileGenerator/releases/tag/v1.0.0
