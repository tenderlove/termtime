require_relative "lib/termtime/version"

Gem::Specification.new do |s|
  s.name        = "termtime"
  s.version     = TermTime::VERSION
  s.summary     = "Pure Ruby terminfo library"
  s.description = "This is a pure Ruby terminfo library"
  s.authors     = [ "Aaron Patterson" ]
  s.email       = "tenderlove@ruby-lang.org"
  s.files       = `git ls-files -z`.split("\x0")
  s.test_files  = s.files.grep(%r{^test/})
  s.homepage    = "https://github.com/tenderlove/termtime"
  s.license     = "Apache-2.0"

  s.add_development_dependency("rake", "~> 13.0")
  s.add_development_dependency("minitest", "~> 5.20")
end
