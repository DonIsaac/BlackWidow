#!/usr/bin/env ruby

# Black Widow
# by Donald Isaac (https://www.opensourceryumd.com)
# Copyright (c) 2019 Open Sourcery. See LICENSE for license details.
require 'black-widow/engine'
require 'pathname'
require 'yaml'

module BlackWidow
	CONFIG_FILE_NAME = '.black-widow.yaml'
	@config = nil
	
	##
	# Resolves the location of the config file. 
	#
	# If no config file exists in the current directory, then the parent
	# directory is checked. This is done until the file is found or the root
	# directory is reached, in which case an IOError is raised.
	#
	# @return The absolute path to the config file.
	#
	def self.resolve_config
		config_path = Pathname.new Dir.pwd

		# Ascend up the file tree until a .black-widow.yaml file is found
		until config_path.children(false).include? CONFIG_FILE_NAME do
			# A path is equal to its parent if and only if it is the root directory
			if config_path == config_path.parent
				raise IOError.new 'BlackWidow: Could not find a ' + CONFIG_FILE_NAME +
				' file. Are you running this command in your project directory?'
			else
				config_path = config_path.parent
			end
		end

		config_path.join CONFIG_FILE_NAME
	end

	def self.config
		if !@config
			@config = resolve_config
		else
			@config
		end
	end
	
end
