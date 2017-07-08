# frozen_string_literal: true
require "dependabot/file_fetchers/ruby/bundler"
require "dependabot/file_fetchers/python/pip"
require "dependabot/file_fetchers/python/pipfile"
require "dependabot/file_fetchers/java_script/yarn"
require "dependabot/file_fetchers/php/composer"

module Dependabot
  module FileFetchers
    def self.for_package_manager(package_manager)
      case package_manager
      when "bundler" then FileFetchers::Ruby::Bundler
      when "yarn" then FileFetchers::JavaScript::Yarn
      when "pip" then FileFetchers::Python::Pip
      when "pipfile" then FileFetchers::Python::Pipfile
      when "composer" then FileFetchers::Php::Composer
      else raise "Unsupported package_manager #{package_manager}"
      end
    end
  end
end
