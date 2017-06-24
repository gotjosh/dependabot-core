# frozen_string_literal: true
require "dependabot/file_parsers/ruby/bundler"
require "dependabot/file_parsers/python/pip"
require "dependabot/file_parsers/java_script/yarn"
require "dependabot/file_parsers/php/composer"
require "dependabot/file_parsers/elixir/hex"

module Dependabot
  module FileParsers
    def self.for_package_manager(package_manager)
      case package_manager
      when "bundler" then FileParsers::Ruby::Bundler
      when "yarn" then FileParsers::JavaScript::Yarn
      when "pip" then FileParsers::Python::Pip
      when "composer" then FileParsers::Php::Composer
      when "hex" then FileParsers::Elixir::Hex
      else raise "Unsupported package_manager #{package_manager}"
      end
    end
  end
end
