# Voice Recognition Profile Generator

This tool generates both [VAC](https://www.dwvac.com) and
[VoiceAttack](https://voiceattack.com) profiles for voice recognition intended
for use in video gaming. **VAC** is a simple voice recognition macro utility
that recognizes voice commands and executes keyboard and mouse macros.
**VoiceAttack** is similar to VAC but has much more complex macro tools. Both
are intended for video gamers to allow hands-off control of their games.

This script reads voice commands generated from a simple, easy-to-write nested
domain-specific language (DSL). The DSL is optimized for games that use nested
menus for generating commands that communicate with NPCs. Here is a simple
example of such a profile:

```
F1 Team
  a Attack My Target
  d Defend Our Base
```

This would generate two voice recognition macros: one triggered by the phrase
"Team Attack My Target", that types `F1` then `a`; and one triggered by the
phrase "Team Defend Our Base" that typed `F1` then `b`.

## Requirements and Installation

Compiling this tool requires a Mac* running macOS 14 or newer, with Xcode
installed. Swift 6.0 or newer is required.

To compile this tool, simply run `swift build -c release`. The generated binary
will be in `.build/release/generate-profile`. You can then move the binary
anywhere.

*Why macOS when both VAC and VoiceAttack are Windows-only? Because I've been
having fun converting my old Ruby scripts to Swift, is my purely selfish reason.
The old, cross-platform Ruby script is still available on the `ruby` branch of
this repository.

## Usage

Assuming you have a profile already written as `profile.vacc`, you can generate
a VAC profile by simply running:

``` sh
generate-profile -f=vac /path/to/profile.vacc > profile.xml
```

You can then import this profile in VAC.

Likewise, to generate a VoiceAttack profile:

``` sh
generate-profile -f=voiceattack /path/to/profile.vacc > profile.vap
```

You can then import this profile in VoiceAttack.

# DSL Syntax

A basic line consists of the key or keys to be pressed, a space, and then the
phrase to use to invoke the macro:

```
a Fire Torpedoes
wd Wave and Dance
```

As you saw before, you can generate complex phrases by nesting commands
underneath other commands:

```
t Team
  f Form on Me
s Squad
  f Form on Me
```

You can add intermediate lines that do not have any phrases if you need to group
those commands:

```
t Team
  1
    a Attack Target One
    d Defend Base One
  2
    a Attack Target Two
    d Defend Base Two
```

This would result in a command with the phrase "Team Attack Target One" having
the macro "t-1-a".

Phrases can only be letters. They cannot contain numbers or special characters.
So use phrases like "Target Two" instead of "Target 2", or "Send One Hundred
Dollars" instead of "Send $100".

Likewise, it's recommended that you spell phonetically any acronyms or jargon
words the recognizer might have trouble with. So use the phrase
"Next Double You Pee" instead of "Next WP", and "Say Pause It" instead of "Say
Posit".

### Multiple Phrases

You can add assign a macro to multiple phrases by comma-separating phrases:

```
a Fire Torpedoes, Torpedoes Away
```

This would create two commands ("Fire Torpedoes", "Torpedoes Away") that run
the same macro.

### Keystrokes

The appearance of most letters, numbers, or symbols simply represent the keys
corresponding to those symbols. So "t" would press the "T" key, and "," would
press the Comma key. In addition, the following special keys are supported:

* Function keys `F1` through `F15`
* `SPC`, `BKSP`, `ENT`, `TAB`, `CAPS`, `ESC`, and `APPS`
* `SHIFT`, `LSHIFT,` and `RSHIFT`; and similar for `CTRL`, `ALT`, and `WIN`
* `UP`, `DN`, `LT`, and `RT` arrows
* `HOME`, `END`, `INS`, `DEL`, `PGUP`, and `PGDN`
* `PSC`, `SCLK`, and `BRK`
* `NUM0` through `NUM9`, `NUM+`, `NUM-`, etc., and `NUMENT`

Note that shifted characters, like "@" (Shift-2) cannot be used directly. You
must use chording (see below) to type Shift-2 instead.

### Chording

You can chord keystrokes (press multiple keys at the same time) by separating
chord elements with ` + ` -- _spaces are required_. Example:

```
SHF + t Team
  1 Attack My Target
``` 

This would generate a macro that first presses "Shift-T", then presses "1".
Again, the spaces around the `+` are required.

### Aliases

To avoid repetition, you can assign a group of commands an alias with `&`, and
then reference that alias when needed with `*`:

```
t Team
  a Attack &bases
    1 Base One
    2 Base Two
  d Defend *bases
  r Resupply *bases
```

And the intermediate commands of course don't need phrases if they're just used
for grouping:

```
t Team
  F1 &actions
    F1 Attack Base
    F2 Defend Base
    F3 Resupply
  F2 &queries
    F1 Say Health
    F2 Say Weapons
    F3 Say Location
s Squad
  F1 *actions
  F2 *queries

```

Limitations
-----------

* VAC
  * Chording is not supported
  * Modifier keys are not supported
  * Special keys (except function keys) are not supported
* VoiceAttack
  * Chording is not supported
  * Modifier keys are not supported

Pull requests welcome! ;)
