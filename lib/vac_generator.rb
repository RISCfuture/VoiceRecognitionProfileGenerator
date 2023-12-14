# frozen_string_literal: true

require "lib/command_set"

class VACGenerator
  attr_reader :command_set

  def initialize(command_set)
    @command_set = command_set
    @builder     = Nokogiri::XML::Builder.new { generate_xml(_1) }
  end

  def to_s() @builder.to_xml(indent: 4) end

  private

  def generate_xml(xml)
    xml.profile do
      command_set.each_command { |command| output_command xml, command }

      xml.set key:  "NONE", key1: "NONE", vackey1: "NONE", vackey2: "NONE",
              ptamode: "default", off: "NONE", off1: "NONE", off2: "NONE",
              off3: "NONE"
    end
  end

  def output_command(xml, command)
    return if command.virtual?

    xml.command(xml_attributes(command)) do
      command.macro.each do |keystroke|
        if extended?(keystroke)
          xml.key extended:  keystroke,
                  extended2: "NONE",
                  qual:      "NONE",
                  pause:     60,
                  repeat:    1,
                  duration:  60
        else
          xml.key value:     keystroke,
                  extended:  "NONE",
                  extended2: "NONE",
                  qual:      "NONE",
                  pause:     60,
                  repeat:    1,
                  duration:  60
        end
      end
    end
  end

  def extended?(keystroke)
    keystroke.match? CommandSet::EXTENDED_KEYSTROKES_RX
  end

  def xml_attributes(command)
    attrs = {name: command.name}
    command.full_phrases.each_with_index do |phrase, index|
      key               = index.zero? ? "phrase" : "phrase#{index}"
      attrs[key.to_sym] = phrase
    end

    return attrs
  end
end
