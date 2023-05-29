# frozen_string_literal: true

require_relative "auto_rspec/version"

module AutoRspec
  class Error < StandardError; end
  # Your code goes here...

  class AutoRspec
    def self.generate
      puts "Generating file"
    end
  end
end
