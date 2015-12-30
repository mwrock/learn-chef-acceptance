require 'fileutils'

property :source, String, name_property: true
property :dest, String, required: true
property :preserve, TrueClass||FalseClass, default: true

action :copy do
  FileUtils.cp_r(source, dest, preserve: preserve)
end