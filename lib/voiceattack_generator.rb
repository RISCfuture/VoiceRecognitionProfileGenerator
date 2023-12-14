# frozen_string_literal: true

require "securerandom"

class Command
  def prefix?() top_level? && has_children? end

  def composite_group
    prefix? ? phrases.first : root.phrases.first
  end

  def suffix_phrases
    return phrases if parent.top_level?

    return parent.suffix_phrases if phrases.empty?

    return phrases if parent.suffix_phrases.empty?

    return phrases.flat_map do |phrase|
      parent.suffix_phrases.map { |pp| "#{pp} #{phrase}" }
    end
  end
end

class VoiceAttackGenerator
  attr_reader :command_set

  def initialize(command_set)
    @command_set = command_set
    @builder     = Nokogiri::XML::Builder.new { generate_xml(_1) }
  end

  def to_s() @builder.to_xml(indent: 4) end

  private

  KEY_CODES = {
      "BRK"   => 3,
      "BS"    => 8,
      "TAB"   => 9,
      "CLR"   => 12,
      "ENTER" => 13,
      "PAUSE" => 19,
      "ESC"   => 27,
      "SPC"   => 32,
      "PGUP"  => 33,
      "PGDN"  => 34,
      "END"   => 35,
      "HOME"  => 36,
      "LT"    => 37,
      "UP"    => 38,
      "RT"    => 39,
      "DN"    => 40,
      "PRINT" => 44,
      "INS"   => 45,
      "DEL"   => 46,
      "0"     => 48,
      "1"     => 49,
      "2"     => 50,
      "3"     => 51,
      "4"     => 52,
      "5"     => 53,
      "6"     => 54,
      "7"     => 55,
      "8"     => 56,
      "9"     => 57,
      "a"     => 65,
      "b"     => 66,
      "c"     => 67,
      "d"     => 68,
      "e"     => 69,
      "f"     => 70,
      "g"     => 71,
      "h"     => 72,
      "i"     => 73,
      "j"     => 74,
      "k"     => 75,
      "l"     => 76,
      "m"     => 77,
      "n"     => 78,
      "o"     => 79,
      "p"     => 80,
      "q"     => 81,
      "r"     => 82,
      "s"     => 83,
      "t"     => 84,
      "u"     => 85,
      "v"     => 86,
      "w"     => 87,
      "x"     => 88,
      "y"     => 89,
      "z"     => 90,
      "LWIN"  => 91,
      "RWIN"  => 92,
      "SEL"   => 93,
      "KP0"   => 96,
      "KP1"   => 97,
      "KP2"   => 98,
      "KP3"   => 99,
      "KP4"   => 100,
      "KP5"   => 101,
      "KP6"   => 102,
      "KP7"   => 103,
      "KP8"   => 104,
      "KP9"   => 105,
      "KP*"   => 106,
      "KP+"   => 107,
      "KP-"   => 109,
      "KP."   => 110,
      "KP/"   => 111,
      "F1"    => 112,
      "F2"    => 113,
      "F3"    => 114,
      "F4"    => 115,
      "F5"    => 116,
      "F6"    => 117,
      "F7"    => 118,
      "F8"    => 119,
      "F9"    => 120,
      "F10"   => 121,
      "F11"   => 122,
      "F12"   => 123,
      "NUML"  => 144,
      "SCRL"  => 145,
      ";"     => 186,
      "="     => 187,
      ","     => 188,
      "-"     => 189,
      "."     => 190,
      "/"     => 191,
      "`"     => 223,
      "["     => 219,
      "\\"    => 220,
      "]"     => 221,
      "'"     => 222
  }.freeze
  private_constant :KEY_CODES

  XSI_NIL  = {"xsi:nil" => true}.freeze
  GUID_NIL = "00000000-0000-0000-0000-000000000000"
  private_constant :XSI_NIL, :GUID_NIL

  def generate_xml(xml)
    xml.Profile("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema") do
      xml.HasMB false
      xml.Id SecureRandom.uuid
      xml.Name command_set.name
      xml.Commands do
        template_commands xml
        command_set.commands.each do |command|
          next unless command.prefix? || command.real?

          output_command xml, command
        end
      end
      xml.OverrideGlobal false
      xml.GlobalHotkeyIndex 0
      xml.GlobalHotkeyEnabled false
      xml.GlobalHotkeyValue 0
      xml.GlobalHotkeyShift 0
      xml.GlobalHotkeyAlt 0
      xml.GlobalHotkeyCtrl 0
      xml.GlobalHotkeyWin 0
      xml.GlobalHotkeyPassThru false
      xml.OverrideMouse false
      xml.MouseIndex 0
      xml.OverrideStop false
      xml.StopCommandHotkeyEnabled false
      xml.StopCommandHotkeyValue 0
      xml.StopCommandHotkeyShift 0
      xml.StopCommandHotkeyAlt 0
      xml.StopCommandHotkeyCtrl 0
      xml.StopCommandHotkeyWin 0
      xml.StopCommandHotkeyPassThru false
      xml.DisableShortcuts false
      xml.UseOverrideListening false
      xml.OverrideJoystickGlobal false
      xml.GlobalJoystickIndex 0
      xml.GlobalJoystickButton 0
      xml.GlobalJoystickNumber 0
      xml.GlobalJoystickButton2 0
      xml.GlobalJoystickNumber2 0
      xml.ReferencedProfile XSI_NIL
      xml.ExportVAVersion "1.7.5"
      xml.ExportOSVersionMajor 6
      xml.ExportOSVersionMinor 2
      xml.OverrideConfidence false
      xml.Confidence 0
      xml.CatchAllEnabled false
      xml.CatchAllId XSI_NIL
      xml.InitializeCommandEnabled false
      xml.UseProcessOverride false
      xml.ProcessOverrideAciveWindow true
      xml.DictationCommandEnabled false
      xml.DictationCommandId XSI_NIL
      xml.EnableProfileSwitch false
      xml.GroupCategory false
      xml.LastEditedCommand GUID_NIL
      xml.IS 0
      xml.IO 0
      xml.IP 0
      xml.BE 0
      xml.UnloadCommandEnabled false
      xml.UnloadCommandId XSI_NIL
      xml.BlockExternal false
      xml.AuthorID XSI_NIL
      xml.ProductID XSI_NIL
      xml.CR 0
      xml.InternalID XSI_NIL
    end
  end

  def output_command(xml, command)
    xml.Command do
      xml.Referrer XSI_NIL
      xml.ExecType 3
      xml.Confidence 0
      xml.PrefixActionCount 0
      xml.IsDynamicallyCreated false
      xml.TargetProcessSet false
      xml.TargetProcessType 0
      xml.TargetProcessLevel 0
      xml.CompareType 0
      xml.ExecFromWildcard false
      xml.IsSubCommand false
      xml.IsOverride false
      xml.BaseId SecureRandom.uuid
      xml.OriginId GUID_NIL
      xml.SessionEnabled true
      xml.Id SecureRandom.uuid
      xml.CommandString(command.prefix? ? command.phrases.join(";") : command.suffix_phrases.join(";"))
      if command.real?
        xml.ActionSequence do
          command.macro.each_with_index do |keystroke, ordinal|
            xml.CommandAction do
              xml._caption "Press #{keystroke.upcase} key and hold for 0.1 seconds and release"
              xml.PairingSet false
              xml.PairingSetElse false
              xml.Ordinal ordinal
              xml.ConditionMet XSI_NIL
              xml.IndentLevel 0
              xml.ConditionSkip false
              xml.IsSuffixAction false
              xml.DecimalTransient1 0
              xml.Caption "Press #{keystroke.upcase} key and hold for 0.1 seconds and release"
              xml.id SecureRandom.uuid
              xml.ActionType "PressKey"
              xml.Duration 0.1
              xml.Delay 0
              xml.KeyCodes do
                raise "Unknown code for key '#{keystroke}'" unless KEY_CODES.key?(keystroke)

                xml.unsignedShort KEY_CODES[keystroke]
              end
              xml.Context
              xml.X 0
              xml.Y 0
              xml.Z 0
              xml.InputMode 0
              xml.ConditionPairing 0
              xml.ConditionGroup 0
              xml.ConditionStartOperator 0
              xml.ConditionStartValue 0
              xml.ConditionStartValueType 0
              xml.ConditionStartType 0
              xml.DecimalContext1 0
              xml.DecimalContext2 0
              xml.DateContext1 "0001-01-01T00:00:00"
              xml.DateContext2 "0001-01-01T00:00:00"
              xml.Disabled false
              xml.RandomSounds
            end
          end
        end
      else
        xml.ActionSequence
      end
      xml.Async !command.real?
      xml.Enabled true
      xml.Description command.phrases.first
      xml.Category command.root.phrases.first
      xml.UseShortcut false
      xml.keyValue 0
      xml.keyShift 0
      xml.keyAlt 0
      xml.keyCtrl 0
      xml.keyWin 0
      xml.keyPassthru true
      xml.UseSpokenPhrase true
      xml.onlyKeyUp false
      xml.RepeatNumber 2
      xml.RepeatType 0
      xml.CommandType(command.prefix? ? 1 : 2)
      xml.CompositeGroup command.composite_group
      xml.SourceProfile GUID_NIL
      xml.UseConfidence false
      xml.minimumConfidenceLevel 0
      xml.UseJoystick false
      xml.joystickNumber 0
      xml.joystickButton 0
      xml.joystickNumber2 0
      xml.joystickButton2 0
      xml.joystickUp false
      xml.KeepRepeating false
      xml.UseProcessOverride false
      xml.ProcessOverrideActiveWindow true
      xml.LostFocusStop false
      xml.PauseLostFocus false
      xml.LostFocusBackCompat true
      xml.UseMouse false
      xml.Mouse1 false
      xml.Mouse2 false
      xml.Mouse3 false
      xml.Mouse4 false
      xml.Mouse5 false
      xml.Mouse6 false
      xml.Mouse7 false
      xml.Mouse8 false
      xml.Mouse9 false
      xml.MouseUpOnly false
      xml.MousePassThru true
      xml.joystickExclusive false
      xml.lastEditedAction GUID_NIL
      xml.UseProfileProcessOverride false
      xml.ProfileProcessOverrideActiveWindow false
      xml.RepeatIfKeysDown false
      xml.RepeatIfMouseDown false
      xml.RepeatIfJoystickDown false
      xml.AH 0
      xml.CL 0
      xml.HasMB false
      xml.UseVariableHotkey false
      xml.CLE 0
      xml.EX1 false
      xml.EX2 false
      xml.InternalId XSI_NIL
    end
  end

  def template_commands(xml)
    xml.Command do
      xml.Referrer "xsi:nil" => true
      xml.ExecType 3
      xml.Confidence 0
      xml.PrefixActionCount 0
      xml.IsDynamicallyCreated false
      xml.TargetProcessSet false
      xml.TargetProcessType 0
      xml.TargetProcessLevel 0
      xml.CompareType 0
      xml.ExecFromWildcard false
      xml.IsSubCommand false
      xml.IsOverride false
      xml.BaseId "f3055b29-e45a-4cb5-97d6-621260da2da8"
      xml.OriginId "00000000-0000-0000-0000-000000000000"
      xml.SessionEnabled true
      xml.Id "3f7f6946-d078-45bc-bfe5-7d2307cf9fae"
      xml.CommandString "Start Listening UHF"
      xml.ActionSequence do
        xml.CommandAction do
          xml._caption "Start VoiceAttack listening"
          xml.PairingSet false
          xml.PairingSetElse false
          xml.Ordinal 0
          xml.ConditionMet "xsi:nil" => true
          xml.IndentLevel 0
          xml.ConditionSkip false
          xml.IsSuffixAction false
          xml.DecimalTransient1 0
          xml.Caption "Start VoiceAttack listening"
          xml.Id "f6fb6a3c-366e-4a18-b90a-58bddf4ba962"
          xml.ActionType "InternalProcess_StartListening"
          xml.Duration 0
          xml.Delay 0
          xml.KeyCodes
          xml.X 0
          xml.Y 0
          xml.Z 0
          xml.InputMode 0
          xml.ConditionPairing 0
          xml.ConditionGroup 0
          xml.ConditionStartOperator 0
          xml.ConditionStartValue 0
          xml.ConditionStartValueType 0
          xml.ConditionStartType 0
          xml.DecimalContext1 0
          xml.DecimalContext2 0
          xml.DateContext1 "0001-01-01T00:00:00"
          xml.DateContext2 "0001-01-01T00:00:00"
          xml.Disabled false
          xml.RandomSounds
        end
      end

      xml.Async true
      xml.Enabled true
      xml.Description "Start Listening"
      xml.UseShortcut false
      xml.keyValue 0
      xml.keyShift 0
      xml.keyAlt 0
      xml.keyCtrl 0
      xml.keyWin 0
      xml.keyPassthru true
      xml.UseSpokenPhrase false
      xml.onlyKeyUp false
      xml.RepeatNumber 2
      xml.RepeatType 0
      xml.CommandType 0
      xml.SourceProfile "00000000-0000-0000-0000-000000000000"
      xml.UseConfidence false
      xml.minimumConfidenceLevel 0
      xml.UseJoystick true
      xml.joystickNumber 1
      xml.joystickButton 28
      xml.joystickNumber2 0
      xml.joystickButton2(-1)
      xml.joystickUp false
      xml.KeepRepeating false
      xml.UseProcessOverride false
      xml.ProcessOverrideActiveWindow true
      xml.LostFocusStop false
      xml.PauseLostFocus false
      xml.LostFocusBackCompat true
      xml.UseMouse false
      xml.Mouse1 false
      xml.Mouse2 false
      xml.Mouse3 false
      xml.Mouse4 false
      xml.Mouse5 false
      xml.Mouse6 false
      xml.Mouse7 false
      xml.Mouse8 false
      xml.Mouse9 false
      xml.MouseUpOnly false
      xml.MousePassThru true
      xml.joystickExclusive false
      xml.lastEditedAction "00000000-0000-0000-0000-000000000000"
      xml.UseProfileProcessOverride false
      xml.ProfileProcessOverrideActiveWindow false
      xml.RepeatIfKeysDown false
      xml.RepeatIfMouseDown false
      xml.RepeatIfJoystickDown false
      xml.AH 0
      xml.CL 0
      xml.HasMB false
      xml.UseVariableHotkey false
      xml.CLE 0
      xml.EX1 false
      xml.EX2 false
      xml.InternalId "xsi:nil" => true
    end

    xml.Command do
      xml.Referrer "xsi:nil" => true
      xml.ExecType 3
      xml.Confidence 0
      xml.PrefixActionCount 0
      xml.IsDynamicallyCreated false
      xml.TargetProcessSet false
      xml.TargetProcessType 0
      xml.TargetProcessLevel 0
      xml.CompareType 0
      xml.ExecFromWildcard false
      xml.IsSubCommand false
      xml.IsOverride false
      xml.BaseId "66a6ab07-af62-4748-a25f-410a871ecdd0"
      xml.OriginId "00000000-0000-0000-0000-000000000000"
      xml.SessionEnabled true
      xml.Id "87f967c7-923d-41cb-9ba5-a2689857188b"
      xml.CommandString "Start Listening VHF"
      xml.ActionSequence do
        xml.CommandAction do
          xml._caption "Start VoiceAttack listening"
          xml.PairingSet false
          xml.PairingSetElse false
          xml.Ordinal 0
          xml.ConditionMet "xsi:nil" => true
          xml.IndentLevel 0
          xml.ConditionSkip false
          xml.IsSuffixAction false
          xml.DecimalTransient1 0
          xml.Caption "Start VoiceAttack listening"
          xml.Id "cc101475-f053-46c0-a9ec-6603d6b54711"
          xml.ActionType "InternalProcess_StartListening"
          xml.Duration 0
          xml.Delay 0
          xml.KeyCodes
          xml.X 0
          xml.Y 0
          xml.Z 0
          xml.InputMode 0
          xml.ConditionPairing 0
          xml.ConditionGroup 0
          xml.ConditionStartOperator 0
          xml.ConditionStartValue 0
          xml.ConditionStartValueType 0
          xml.ConditionStartType 0
          xml.DecimalContext1 0
          xml.DecimalContext2 0
          xml.DateContext1 "0001-01-01T00:00:00"
          xml.DateContext2 "0001-01-01T00:00:00"
          xml.Disabled false
          xml.RandomSounds
        end
      end

      xml.Async true
      xml.Enabled true
      xml.Description "Start Listening"
      xml.UseShortcut false
      xml.keyValue 0
      xml.keyShift 0
      xml.keyAlt 0
      xml.keyCtrl 0
      xml.keyWin 0
      xml.keyPassthru true
      xml.UseSpokenPhrase false
      xml.onlyKeyUp false
      xml.RepeatNumber 2
      xml.RepeatType 0
      xml.CommandType 0
      xml.SourceProfile "00000000-0000-0000-0000-000000000000"
      xml.UseConfidence false
      xml.minimumConfidenceLevel 0
      xml.UseJoystick true
      xml.joystickNumber 1
      xml.joystickButton 30
      xml.joystickNumber2 0
      xml.joystickButton2(-1)
      xml.joystickUp false
      xml.KeepRepeating false
      xml.UseProcessOverride false
      xml.ProcessOverrideActiveWindow true
      xml.LostFocusStop false
      xml.PauseLostFocus false
      xml.LostFocusBackCompat true
      xml.UseMouse false
      xml.Mouse1 false
      xml.Mouse2 false
      xml.Mouse3 false
      xml.Mouse4 false
      xml.Mouse5 false
      xml.Mouse6 false
      xml.Mouse7 false
      xml.Mouse8 false
      xml.Mouse9 false
      xml.MouseUpOnly false
      xml.MousePassThru true
      xml.joystickExclusive false
      xml.lastEditedAction "13b3fbe3-4d15-48da-8ac9-e7d741e36a8d"
      xml.UseProfileProcessOverride false
      xml.ProfileProcessOverrideActiveWindow false
      xml.RepeatIfKeysDown false
      xml.RepeatIfMouseDown false
      xml.RepeatIfJoystickDown false
      xml.AH 0
      xml.CL 0
      xml.HasMB false
      xml.UseVariableHotkey false
      xml.CLE 0
      xml.EX1 false
      xml.EX2 false
      xml.InternalId "xsi:nil" => true
    end

    xml.Command do
      xml.Referrer "xsi:nil" => true
      xml.ExecType 3
      xml.Confidence 0
      xml.PrefixActionCount 0
      xml.IsDynamicallyCreated false
      xml.TargetProcessSet false
      xml.TargetProcessType 0
      xml.TargetProcessLevel 0
      xml.CompareType 0
      xml.ExecFromWildcard false
      xml.IsSubCommand false
      xml.IsOverride false
      xml.BaseId "7a676e64-1b1e-4fa7-b85f-4f8a73cca67d"
      xml.OriginId "00000000-0000-0000-0000-000000000000"
      xml.SessionEnabled true
      xml.Id "b1db2b7f-c46f-46dc-a2a6-4f502c4e70ff"
      xml.CommandString "Stop Listening UHF"
      xml.ActionSequence do
        xml.CommandAction do
          xml._caption "Stop VoiceAttack listening"
          xml.PairingSet false
          xml.PairingSetElse false
          xml.Ordinal 0
          xml.ConditionMet "xsi:nil" => true
          xml.IndentLevel 0
          xml.ConditionSkip false
          xml.IsSuffixAction false
          xml.DecimalTransient1 0
          xml.Caption "Stop VoiceAttack listening"
          xml.Id "98a925de-16ec-4c89-b5b4-d889b219fb6d"
          xml.ActionType "InternalProcess_StopListening"
          xml.Duration 0
          xml.Delay 0
          xml.KeyCodes
          xml.X 0
          xml.Y 0
          xml.Z 0
          xml.InputMode 0
          xml.ConditionPairing 0
          xml.ConditionGroup 0
          xml.ConditionStartOperator 0
          xml.ConditionStartValue 0
          xml.ConditionStartValueType 0
          xml.ConditionStartType 0
          xml.DecimalContext1 0
          xml.DecimalContext2 0
          xml.DateContext1 "0001-01-01T00:00:00"
          xml.DateContext2 "0001-01-01T00:00:00"
          xml.Disabled false
          xml.RandomSounds
        end
      end

      xml.Async true
      xml.Enabled true
      xml.UseShortcut false
      xml.keyValue 0
      xml.keyShift 0
      xml.keyAlt 0
      xml.keyCtrl 0
      xml.keyWin 0
      xml.keyPassthru true
      xml.UseSpokenPhrase false
      xml.onlyKeyUp false
      xml.RepeatNumber 2
      xml.RepeatType 0
      xml.CommandType 0
      xml.SourceProfile "00000000-0000-0000-0000-000000000000"
      xml.UseConfidence false
      xml.minimumConfidenceLevel 0
      xml.UseJoystick true
      xml.joystickNumber 1
      xml.joystickButton 28
      xml.joystickNumber2 0
      xml.joystickButton2(-1)
      xml.joystickUp true
      xml.KeepRepeating false
      xml.UseProcessOverride false
      xml.ProcessOverrideActiveWindow true
      xml.LostFocusStop false
      xml.PauseLostFocus false
      xml.LostFocusBackCompat true
      xml.UseMouse false
      xml.Mouse1 false
      xml.Mouse2 false
      xml.Mouse3 false
      xml.Mouse4 false
      xml.Mouse5 false
      xml.Mouse6 false
      xml.Mouse7 false
      xml.Mouse8 false
      xml.Mouse9 false
      xml.MouseUpOnly false
      xml.MousePassThru true
      xml.joystickExclusive false
      xml.lastEditedAction "17712435-a8d7-4404-827a-9355a5f3e64d"
      xml.UseProfileProcessOverride false
      xml.ProfileProcessOverrideActiveWindow false
      xml.RepeatIfKeysDown false
      xml.RepeatIfMouseDown false
      xml.RepeatIfJoystickDown false
      xml.AH 0
      xml.CL 0
      xml.HasMB false
      xml.UseVariableHotkey false
      xml.CLE 0
      xml.EX1 false
      xml.EX2 false
      xml.InternalId "xsi:nil" => true
    end

    xml.Command do
      xml.Referrer "xsi:nil" => true
      xml.ExecType 3
      xml.Confidence 0
      xml.PrefixActionCount 0
      xml.IsDynamicallyCreated false
      xml.TargetProcessSet false
      xml.TargetProcessType 0
      xml.TargetProcessLevel 0
      xml.CompareType 0
      xml.ExecFromWildcard false
      xml.IsSubCommand false
      xml.IsOverride false
      xml.BaseId "c04a09b9-5de2-43ec-b65a-87429e5bf95c"
      xml.OriginId "00000000-0000-0000-0000-000000000000"
      xml.SessionEnabled true
      xml.Id "35e039e5-d944-41b3-8375-98e4214883b6"
      xml.CommandString "Stop Listening VHF"
      xml.ActionSequence do
        xml.CommandAction do
          xml._caption "Stop VoiceAttack listening"
          xml.PairingSet false
          xml.PairingSetElse false
          xml.Ordinal 0
          xml.ConditionMet "xsi:nil" => true
          xml.IndentLevel 0
          xml.ConditionSkip false
          xml.IsSuffixAction false
          xml.DecimalTransient1 0
          xml.Caption "Stop VoiceAttack listening"
          xml.Id "ad39e270-dac9-4332-824d-1cefc112b46e"
          xml.ActionType "InternalProcess_StopListening"
          xml.Duration 0
          xml.Delay 0
          xml.KeyCodes
          xml.X 0
          xml.Y 0
          xml.Z 0
          xml.InputMode 0
          xml.ConditionPairing 0
          xml.ConditionGroup 0
          xml.ConditionStartOperator 0
          xml.ConditionStartValue 0
          xml.ConditionStartValueType 0
          xml.ConditionStartType 0
          xml.DecimalContext1 0
          xml.DecimalContext2 0
          xml.DateContext1 "0001-01-01T00:00:00"
          xml.DateContext2 "0001-01-01T00:00:00"
          xml.Disabled false
          xml.RandomSounds
        end
      end

      xml.Async true
      xml.Enabled true
      xml.UseShortcut false
      xml.keyValue 0
      xml.keyShift 0
      xml.keyAlt 0
      xml.keyCtrl 0
      xml.keyWin 0
      xml.keyPassthru true
      xml.UseSpokenPhrase false
      xml.onlyKeyUp false
      xml.RepeatNumber 2
      xml.RepeatType 0
      xml.CommandType 0
      xml.SourceProfile "00000000-0000-0000-0000-000000000000"
      xml.UseConfidence false
      xml.minimumConfidenceLevel 0
      xml.UseJoystick true
      xml.joystickNumber 1
      xml.joystickButton 30
      xml.joystickNumber2 0
      xml.joystickButton2(-1)
      xml.joystickUp true
      xml.KeepRepeating false
      xml.UseProcessOverride false
      xml.ProcessOverrideActiveWindow true
      xml.LostFocusStop false
      xml.PauseLostFocus false
      xml.LostFocusBackCompat true
      xml.UseMouse false
      xml.Mouse1 false
      xml.Mouse2 false
      xml.Mouse3 false
      xml.Mouse4 false
      xml.Mouse5 false
      xml.Mouse6 false
      xml.Mouse7 false
      xml.Mouse8 false
      xml.Mouse9 false
      xml.MouseUpOnly false
      xml.MousePassThru true
      xml.joystickExclusive false
      xml.lastEditedAction "17712435-a8d7-4404-827a-9355a5f3e64d"
      xml.UseProfileProcessOverride false
      xml.ProfileProcessOverrideActiveWindow false
      xml.RepeatIfKeysDown false
      xml.RepeatIfMouseDown false
      xml.RepeatIfJoystickDown false
      xml.AH 0
      xml.CL 0
      xml.HasMB false
      xml.UseVariableHotkey false
      xml.CLE 0
      xml.EX1 false
      xml.EX2 false
      xml.InternalId "xsi:nil" => true
    end
  end
end
