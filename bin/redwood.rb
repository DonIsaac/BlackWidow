#!/usr/bin/env ruby

# Redwood
# by Donald Isaac (https://www.opensourceryumd.com)
# Copyright (c) 2019 Open Sourcery. See LICENSE for license details.

require 'redwood'
require 'pathname'

module Redwood
	ENGINE = ViewEngine.new # Pathname.new(Dir.pwd).join 'src'

	##
	# Creates a new DocuBuld project outline
	#
	# This function creates a new project directory and populates it with a
	# config.yaml file and folders for view components.
	#
	# @param name: String
	#		The name of the project. This will also be the name of the project
	#		directory.
	#
	# @return void
	#
	def init_project name
		root = Pathname.new Dir.pwd
		if (root + name).exist? then
			raise ArgumentError 'Project could not be created: directory already exists.'
			exit 1
		end

		root.mkpath name
		root.join name
		ViewEngine::FOLDERS.each_value do |dir|
			root.mkpath dir
		end
		config = File.new root.join('.redwood.yaml'), 'w+'
	end

	def render_project
		# Project root directory is the directory with the config file
		root = File.dirname ::resolve_config
		Dir.chdir root
	end
end
# module Redwood
# 	class Redwood
# 	end
# end

engine = Redwood::ViewEngine.new Pathname.new(Dir.pwd).join 'src'
puts(engine.render 'index')
