lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'redwood/version'

Gem::Specification.new do |s|
	s.name        	= 'redwood'
	s.version     	= Redwood::VERSION
	s.platform    = Gem::Platform::RUBY
	s.summary     	= "Redwood Static Site Generator"
	s.description 	= "A simple static site generator powered by eRuby"
	s.author     	= "Donald Isaac"
	s.homepage    	= 'https://www.opensourceryumd.com'
	s.license     	= 'MIT'
	# s.bindir	  	= 'bin'

	s.add_dependency 'rake'

	s.files       	= `git ls-files`.split("\n")

	s.test_files  	= `git ls-files -- {test}/*`.split("\n")

	s.executables   = `git ls-files -- bin/*`
                    .split("\n")
					.map { |f| File.basename(f) }
	s.require_paths = ['lib']
end
