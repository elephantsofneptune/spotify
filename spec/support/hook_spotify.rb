#
# Hooks into FFI for extra introspection during testing.
#
require 'ffi'

$attached_methods ||= {}

module SpotifyHook
  # stores function information that we can assert on later
  def attach_function(name, func, arguments, returns, options)
    args  = [name, func, arguments.dup, returns, options]
    hargs = [:name, :func, :args, :returns].zip args
    $attached_methods[name.to_s] = Hash[hargs]

    super
  end
end

module Spotify
  class API
    # so that Spotify cannot extend again
    extend FFI::Library
    extend SpotifyHook

    # allows us to test for Mac/Linux independently
    FFI::Platform::OS.replace(ENV.fetch('RUBY_PLATFORM') do
      puts "[WARN] Tests running with default ruby platform, #{::FFI::Platform::OS}, please be"
      puts "[WARN] specific in which platform to target by setting ENV[RUBY_PLATFORM]"
      puts "(warnings coming from #{__FILE__}:#{__LINE__})"
      puts
      ::FFI::Platform::OS
    end)
  end
end

# All is in place, load it up
require 'spotify'
