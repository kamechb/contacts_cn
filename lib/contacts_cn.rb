$:.unshift(File.dirname(__FILE__)+"/contacts/")

require 'rubygems'
unless Object.const_defined?('ActiveSupport')
	require 'active_support'
end
require 'base'
require 'gmail'
require 'hotmail'
require 'yahoo'
require 'plaxo'
require 'aol'
require 'net_ease'
require 'sina'
require 'sohu'
require 'json_picker'
require 'hash_ext'
