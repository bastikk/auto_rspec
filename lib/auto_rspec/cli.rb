require "thor"
require 'auto_rspec'

require "auto_rspec/generators/auto_rspec/auto_rspec_generator"

module AutoRspec
  class CLI < Thor
    desc "generate", "Generates a rspec file for a given file"
    def generate(dir_path)
      AutoRspecGenerator.start([dir_path])
    end

    # # synonym for generate
    # def g(dir_path)
    #   generate(dir_path)
    # end
  end
end