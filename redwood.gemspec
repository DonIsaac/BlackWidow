Gem::Specification.new do |s|
	s.name        = 'redwood'
	s.version     = '0.0.1'
	s.date        = '2019-06-05'
	s.summary     = "Redwood Static Site Generator"
	s.description = "A simple static site generator powered by eRuby"
	s.authors     = ["Donald Isaac"]
	s.email       = ''
	s.files       = ["lib/redwood.rb"]
	s.homepage    = 'https://www.opensourceryumd.com'
	s.license     = 'MIT'
	s.bindir	  = 'bin'
	s.files       = `git ls-files`.split("\n")

	s.test_files  = `git ls-files -- {test}/*`.split("\n")

	s.executables   = `git ls-files -- bin/*`
                    .split("\n")
                    .map { |f| File.basename(f) }
end
