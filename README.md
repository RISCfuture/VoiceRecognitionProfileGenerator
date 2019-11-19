Voice Recognition Profile Generator
===================================

This script generates both [VAC](https://www.dwvac.com) and
[VoiceAttack](https://voiceattack.com) profiles for voice recognition intended
for use in video gaming. **VAC** is a simple voice recognition macro utility
that recognizes voice commands and executes keyboard and mouse macros.
**VoiceAttack** is similar to VAC but has much more complex macro tools. Both
are intended for video gamers to allow hands-off control of their games.

This script reads voice commands generated from a simple, easy-to-write nested
domain-specific language (DSL). The DSL is optimized for games that use nested
menus for generating commands that communicate with NPCs. Here is a simple]
example of such a profile:

```
F1 Team
  a Attack My Target
  d Defend Our Base
```

This would generate two voice recognition macros: One triggered by the phrase
"Team Attack My Target", that types `F1` then `a`; and one triggered by the
phrase "Team Defend Our Base" that typed `F1` then `b`.

Usage
-----

Assuming you have a profile already written as `profile.vacc`, you can generate
a VAC profile by simply running:

``` sh
ruby generate.rb -f=vac /path/to/profile.vacc > profile.xml
```

You can then import this profile in VAC.

Likewise, to generate a VoiceAttack profile:

``` sh
ruby generate.rb -f=voiceattack /path/to/profile.vacc > profile.vap
```

You can then import this profile in VoiceAttack.

DSL Syntax
----------

A basic line consists of the key or keys to be pressed, a space, and then the
phrase to use to invoke the macro:

```
a Fire Torpedoes
wd Wave and Dance 
``` 

You can add multiple phrase aliases by comma-separating phrases:

```
a Fire Torpedoes, Torpedoes Away
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

Lowercase characters, numbers, and symbols in a keystroke simply type those
characters. Uppercase is used for special characters. For both VAC and
VoiceAttack, F-keys are supported as `F1` through `F15`. VoiceAttack also
supports numerous other special characters; see the
`VoiceAttackGenerator::KEY_CODES` constant for a guide.

Limitations
-----------

* Currently modifiers (such as shift or control), mouse macros, or other kinds
  of macros are not supported.
