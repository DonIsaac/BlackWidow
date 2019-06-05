require 'erb' 					# ERuby template engine
require 'pathname' 				# finding paths

module Redwood
	##
	# This class contains all the functionality required for rendering
	#		 HTML pages and partials
	#
	# The set of all assets required to render a page, such as the page template
	# and it's context, are collectively known as a +view+. View assets must be
	# located in specific locations, as Redwood follows a 'configuration by
	# convention' principle.
	#
	# Redwood's conventions are based heavily on Ruby on Rails. If you are 
	# familiar with Rails, ViewEngine works much like ActionView.
	#
	#   * page templates must be located in the `src/pages` directory
	#	* layout templates must be located in the `src/layouts` directory
	#	* partials must be located in the `src/partials` directory
	#	* contexts must be located in the `src/contexts` directory
	#
	# 
	# @author Donald Isaac
	#
	# Copyright (c) 2019 Open Sourcery. See LICENSE for license details.
	#
	class ViewEngine

		# Keys are the available view components, values are component folder names
		# TODO: Make this configurable from config.yaml
		VIEW_FOLDERS = {
			page: 'pages',
			context: 'contexts',
			partial: 'partials',
			layout: 'layouts'
		}

		##
		# Creates a new ViewEngine.
		#
		# @param root_dir: String | Pathname
		# 	Directory of a Redwood project's source code. This directory must
		#	be the immediate parent of all view component VIEW_FOLDERS.
		#
		def initialize(root_dir = Dir.pwd)
			@root = Pathname.new root_dir
			raise ArgumentError.new "The root path '" + @root.to_s + "'is a file." unless @root.directory?

			@view_components = {
				page: { dir: @root + Pathname.new(VIEW_FOLDERS[:page]), ext: '.erb'},
				context: { dir: @root + Pathname.new(VIEW_FOLDERS[:context]), ext: '.rb' },
				partial: { dir: @root + Pathname.new(VIEW_FOLDERS[:partial]), ext: '.erb' },
				layout: { dir: @root + Pathname.new(VIEW_FOLDERS[:layout]), ext: '.erb' }
			}
		end

		##
		# Renders ERB files to HTML.
		#
		# ### Usage
		#
		# ```ruby
		# # Render a page
		# render [name], layout: 'foo'
		# render page: [name]
		# render layout: [name], [page]
		#
		# # Render a partial
		# render partial [name]
		# render :partial [name], :locals 
		#```
		#
		# ### Available Options
		#
		# - :page
		# 		Renders a page view. This option is mutually exlusive with 
		#		the :partial option.
		#
		# - :partial
		#		Renders a partial view. This option is mutually exclusive with
		#		the :page option.
		#
		# - :layout
		#		Specifies the name of the layout to use when rendering a page
		#		view. If no layout is specified, the default layout is used.
		#
		# - :namespace
		#		The namespace to use. See the namespace section for more info.
		#
		# @param options: Hash | String
		# 		If options is a string, then a page view is rendered where
		# 		options is the name of the view. When options is a hash, it
		#		contains user specified options. See the usage section for all
		#		available options.
		#
		# @param extra_options: Hash
		# 		When options is the name of a view as a string, this hash
		# 		contains the rendering options.
		#
		# @return The rendered view as a, HTML string.
		#
		# @author Donald Isaac
		# 
		def render(options = {}, extra_options = {}, &block)
			case options
			when Hash
			  if options[:page]
				render_page options[:page], options
			  elsif options[:partial] # Only partials can take blocks
				render_partial options[:partial], options, &block
			  end
			# `options` param is the name of the page view
			when String
			  render_page options, extra_options
			else
			  raise ArgumentError 'options parameter must be a Hash or String'\
				' You passed a(n)' + options.class.name + '.'
			end
		  end

		##
		# Gets the view component hash.
		#
		# @return the view component hash.
		#
		def components
			@view_components
		end

		private

		##
		# Renders a view to HTML.
		#
		# A view is the collection of data associated with a specific page.
		# This data includes the erb template and it's associated context data.
		# 
		# @param view: String
		# 		The name of the view to render.
		#
		# @return The rendered page view as an HTML string.
		#
		def render_page(view, options={})
			loaded_components = load_components view, [:page, :context]
			page = ERB.new loaded_components[:page]
			binding = loaded_components[:context].new.method(:context).call
			raise 'Context method must return a binding obect.' unless binding.is_a? Binding

			page.result binding
		end

		def render_partial(partial, options={}, &block)
			'render_partial called! ' + partial + ', ' + options.to_s
		end
		##
		# Resolves the paths for all of a view's assets.
		#
		# Resolved assets include the view's templates and rendering context.
		# 
		# ==== Params:
		# [view]
		# 	String. The name or relative path of the view to resolve. The path
		#	must be relative to the +pages+ template directory.
		#
		# ==== Returns:
		#
		# String[]. The resolved asset paths in an array. The asset contains
		# The following items (in order):
		# 	[page]
		#		The page template
		#	[context]
		#		The view context
		#

		##
		# Loads a set of components for a view.
		#
		#
		def load_components(view = '', components = [], options = {})
			# Return an empty hash if no component types are specified
			if !components.length then return {} end

			# Strip whitespace
			view.strip
			namespace = options[:namespace] || ''

			# Raise an error if +view+ was just whitespace and/or a forward slash
			raise ArgumentError 'Invalid view name or directory.' unless view.length
			raise ArgumentError 'No view components specified ' unless components

			# Contents of view component files, where the key is component type,
			# and the value is the file's contents
			loaded_components = {}

			# Load the contents of each component file, 
			# verifying that each one exists
			components.each do |component_type|

				# Validate that the specified view component type exists
				if !@view_components.include? component_type 
					raise ArgumentError 'Component type ' + component_type + 'does not exist.'
				end

				component = @view_components[component_type]

				# Validate that view component hash has keys for the directory and extension type
				if !component.include?(:dir) || !component.include?(:ext)
					raise ArgumentError 'Component hashes must have the :dir and :ext keys.'
				end

				component_path = component[:dir].join view + namespace + component[:ext]

				# Throw an exception if the component file does not exist
				if !component_path.exist?
					raise "The '"  + component_type.to_s + "' file for the '" +
					view + "' view does not exist. View component path is " +
					component_path.to_s
				end

				# Read the contents of the component file and
				# store it into an array
				loaded_components[component_type] = case component[:ext]
				when '.rb'
					context_classname = if namespace.length then
						namespace.capitalize + '::' 
					end + view.capitalize + component_type.to_s.capitalize
					# Import the context class
					require_relative component_path
					# TODO: Handle modules as :namespace option
					Object.const_get context_classname
				else
					File.new(component_path, 'r').read
				end
			end

			return loaded_components
		end 
	end # !ViewEngine
end # !Module 
