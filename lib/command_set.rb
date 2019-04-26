require 'active_support/core_ext/object/blank'

class CommandSet
  attr_reader :name, :commands

  def initialize(name)
    @name     = name
    @commands = Array.new
  end

  def each_command
    return enum_for(:each_command) unless block_given?

    commands.each do |command|
      next if command.virtual?
      yield command
    end
  end

  INDENT_RX              = /(?<indent>(?:\t| {2})*)/.freeze
  EXTENDED_KEYSTROKES_RX = /F[1-9]|F1[0-5]/.freeze
  KEYSTROKE_RX           = /(?<keystroke>[^ ]|#{EXTENDED_KEYSTROKES_RX})/.freeze
  PHRASES_RX             = /(?<phrases>[^&*]+?)/.freeze
  ALIAS_DEFINITION_RX    = /(?:&(?<aliasdef>\w+))?/.freeze
  ALIAS_REFERENCE_RX     = /(?:\*(?<aliasref>\w+))?/.freeze
  ALIAS_DEF_OR_REF_RX    = /#{ALIAS_DEFINITION_RX}|#{ALIAS_REFERENCE_RX}/.freeze
  PHRASE_ALIAS_RX        = /#{PHRASES_RX}(?: #{ALIAS_DEF_OR_REF_RX})?/.freeze
  ALIAS_ONLY_RX          = /(?:#{ALIAS_DEF_OR_REF_RX})?/.freeze
  LINE_RX                = /^#{INDENT_RX}#{KEYSTROKE_RX}(?: #{PHRASE_ALIAS_RX}| #{ALIAS_ONLY_RX})?$/.freeze

  def self.parse(pathname)
    set     = new(pathname.basename('.vacc'))
    aliases = Hash.new

    current_parent = nil
    current_indent = 0

    pathname.each_line.with_index do |line, line_number|
      next if line.blank?

      matches = line.match(LINE_RX) or raise "Improper formatting on line #{line_number + 1}"
      indent    = matches[:indent].size / 2
      keystroke = matches[:keystroke]
      phrases   = matches[:phrases].present? ? matches[:phrases].split(/\s*,\s*/) : nil
      phrases&.each(&:strip!)

      if indent == current_indent
        # do nothing
      elsif indent == current_indent + 1
        current_parent = set.commands.last
      elsif indent < current_indent
        outdent = current_indent - indent
        outdent.times do
          raise "Tried to outdent #{outdent} times which is too many: Line #{line_number}" if current_parent.nil?

          current_parent = current_parent.parent
        end
      else
        raise "Unexpected indent on line #{line_number + 1}"
      end

      current_indent = indent
      command        = Command.new(keystroke, parent: current_parent, phrases: phrases)
      set.commands << command

      if (alias_name = matches[:aliasdef].presence)
        raise "Redefined alias '#{alias_name}' on line #{line_number}" if aliases.key?(alias_name)
        aliases[alias_name] = command
      elsif (alias_name = matches[:aliasref].presence)
        raise "Unknown alias '#{alias_name}' referenced on line #{line_number}" unless aliases.key?(alias_name)
        copy_alias(command, aliases[alias_name]) { |alias_command| set.commands << alias_command }
      end
    end

    return set
  end

  def inspect()
    "#<#{self.class} (#{each_command.count} commands)>"
  end

  def self.copy_alias(root_command, alias_root_command)
    alias_root_command.children.each do |alias_child|
      root_child = Command.new(alias_child.keystroke, parent: root_command, phrases: alias_child.phrases)
      yield root_child
      copy_alias(root_child, alias_child) { |grandchild| yield grandchild }
    end
  end

  private_class_method :copy_alias
end

class Command
  attr_reader :keystroke, :parent, :phrases, :children

  def initialize(keystroke, parent: nil, phrases: nil)
    @keystroke = keystroke
    @phrases   = phrases || Array.new
    @children  = Array.new

    self.parent = parent
  end

  def name
    return phrases.first if top_level?
    return parent.name ? "#{parent.name} :: #{phrases.first}" : phrases.first
  end

  def macro
    top_level? ? [keystroke] : parent.macro + [keystroke]
  end

  def full_phrases
    return phrases if top_level?

    if phrases.empty?
      return parent.full_phrases
    else
      return phrases.flat_map do |phrase|
        parent.full_phrases.map { |pp| "#{pp} #{phrase}" }
      end
    end
  end

  def parent=(parent)
    @parent = parent
    parent.children << self if parent
  end

  def root
    @root ||= top_level? ? self : parent.root
  end

  def has_children?() !@children.empty? end

  def virtual?() has_children? end
  def real?() !virtual? end

  def top_level?() parent.nil? end


  def inspect() "#<#{self.class} #{name}>" end
end
