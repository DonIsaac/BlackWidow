#!/usr/bin/env ruby

# Redwood
# by Donald Isaac (https://www.opensourceryumd.com)
# Copyright (c) 2019 Open Sourcery. See LICENSE for license details.
require_relative 'engine'
require 'pathname'
require 'yaml'

module Redwood

	CONFIG = YAML.load_file resolve_config
	
	##
	# Resolves the location of the config file. 
	#
	# If no config file exists in the current directory, then the parent
	# directory is checked. This is done until the file is found or the root
	# directory is reached, in which case an IOError is raised.
	#
	# @return The absolute path to the config file.
	#
	def resolve_config
		config_path = Pathname.new Dir.pwd

		# Ascend up the file tree until a .redwood.yaml file is found
		until config_path.children(false).include? '.redwood.yaml' do
			# A path is equal to its parent if and only if it is the root directory
			if config_path == config_path.parent
				raise IOError 'Redwood: Could not find .redwood.yaml config file.'
			else
				config_path = config_path.parent
			end
		end

		config_path.join '.redood.yaml'
	end
end