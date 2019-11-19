require 'optparse'
require 'pathname'

require 'bundler'
Bundler.require

$LOAD_PATH << __dir__
require 'lib/command_set'

FORMATS = %w[vac voiceattack].freeze
options = {format: 'vac'}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: generate.rb [options] /path/to/profile.vacc"

  opts.on('-h', '--help', "Prints this help") do
    puts parser
    exit
  end

  opts.on('-fFORMAT', '--format=FORMAT', "Specify output format: #{FORMATS.join(', ')}") do |f|
    options[:format] = f
  end
end
parser.parse!

generator = case options[:format]
              when 'vac'
                require 'lib/vac_generator'
                VACGenerator
              when 'voiceattack'
                require 'lib/voiceattack_generator'
                VoiceAttackGenerator
              else
                puts parser
                exit 1
            end
if ARGV.size != 1
  puts parser
  exit 2
end

command_set = CommandSet.parse(Pathname(ARGV.first))
profile = generator.new(command_set)
puts profile.to_s
