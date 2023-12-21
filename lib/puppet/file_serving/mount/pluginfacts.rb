# frozen_string_literal: true

require_relative '../../../puppet/file_serving/mount'

# Find files in the modules' pluginfacts directories.
# This is a very strange mount because it merges
# many directories into one.
class Puppet::FileServing::Mount::PluginFacts < Puppet::FileServing::Mount
  # Return an instance of the appropriate class.
  def find(relative_path, request)
    mod = request.environment.modules.find { |m| m.pluginfact(relative_path) }
    return nil unless mod

    path = mod.pluginfact(relative_path)

    path
  end

  def search(relative_path, request)
    # We currently only support one kind of search on plugins - return
    # them all.
    paths = request.environment.modules.find_all { |mod| mod.pluginfacts? }.collect { |mod| mod.plugin_fact_directory }
    if paths.empty?
      # If the modulepath is valid then we still need to return a valid root
      # directory for the search, but make sure nothing inside it is
      # returned.
      request.options[:recurse] = false
      request.environment.modulepath.empty? ? [Puppet[:codedir]] : request.environment.modulepath
    else
      paths
    end
  end

  def valid?
    true
  end
end
