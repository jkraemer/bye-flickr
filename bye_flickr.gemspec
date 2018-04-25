require_relative 'lib/bye_flickr/version'

Gem::Specification.new do |s|
  s.name        = 'bye_flickr'
  s.version     = ByeFlickr::VERSION
  s.executables << 'bye-flickr'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jens Krämer"]
  s.email       = ["jk@jkraemer.net"]
  s.homepage    = "http://github.com/jkraemer/bye_flickr"
  s.summary     = %q{Download all photos and metadata from your flickr account.}
  s.description = %q{With Flickr facing an uncertain future in the hands of competitor SmugMug I decided it was time to leave the sinking ship. This gem will download all your collections, sets and photos not organized in any set as well. Metadata is stored in json files, one per image file. Collection / Set metadata is stored as JSON files, as well.}
  s.licenses    = ['MIT']

  s.required_rubygems_version = ">= 2.0"

  # required for validation
  s.rubyforge_project         = "bye-flickr"

  # If you have other dependencies, add them here
  s.add_dependency "flickraw", "~> 0.9"
  s.add_dependency "net-http-persistent", "~> 3.0"
  s.add_dependency "concurrent-ruby", "~> 1.0"
  s.add_dependency "slop", "~> 4.6"
  s.add_development_dependency 'bundler', '~> 1.16'

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
end
