require 'thor/group'
require "auto_rspec/generators/auto_rspec/parsers/application_record_parser"

# todo temporary
#
# Dir['auto_rspec/generators/auto_rspec/parsers/*.rb'].each { |file| require file }
require 'active_model'
require 'active_record'
require 'action_controller'

class AutoRspecGenerator < Thor::Group
  # source_root File.expand_path('../templates', __FILE__)

  include Thor::Actions
  include ActiveRecordParser

  argument :file_path, :type => :string

  def create_spec_file
    # error message if not appropriate path provided
    return puts "#{file_path} doesn't exist!" unless File.exist?(file_path)

    # todo replace
    file_name = File.basename(file_path)

    directories = File.dirname(file_path).split('/').drop(1)
    spec_path = 'spec/' + directories.join('/') + "/#{File.basename(file_path, '.*')}_spec.rb"

    # todo replace
    class_name = converted_string = file_path.dup.split('/').map(&:capitalize).join('::')

    # parse classes
    @class_name = class_name.split('.').first
    until @class_name.empty? || Object.const_defined?(@class_name)
      @class_name = @class_name.split('::').drop(1).join('::')
    end
    the_class = Module.const_get(@class_name) unless @class_name.empty?

    if the_class.nil?
      puts "Spec generation for provided file doesn't supported. Please use it only for ApplicationRecord/ActiveModel classes"
    elsif the_class < ActiveRecord::Base
      create_spec_directory(directories)
      @active_record_matchers = parse_active_record(the_class)
      template "application_record.erb", spec_path
    elsif the_class < ActiveModel
      create_spec_directory(directories)
      @active_model_matchers = parse_active_model(the_class)
      template "active_model.erb", spec_path
    elsif the_class < ApplicationController
      create_spec_directory(directories)
      @application_controller_matchers = parse_application_controller(the_class)
      template "application_controller.erb", spec_path
    else
      puts "Spec generation for provided file doesn't supported. Please use it only for ApplicationRecord/ActiveModel classes"
    end
  end

  private

  # Creates spec directory if it doesn't exist
  def create_spec_directory(directories)
    spec_dir_path = 'spec/'
    directories.each do |directory|
      spec_dir_path += "#{directory}/"
      Dir.mkdir(spec_dir_path) unless File.exist?(spec_dir_path)
    end
  end
end