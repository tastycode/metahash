# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "metahash/version"

Gem::Specification.new do |s|
  s.name        = "metahash"
  s.version     = Metahash::VERSION
  s.authors     = ["Thomas Devol"]
  s.email       = ["thomas.devol@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Provides metadata management for many file types}
  s.description = %q{Successor to exif/id3/xmp for metadata management}

  s.rubyforge_project = "metahash"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "ruby-debug"
  s.add_runtime_dependency "bson"
  s.add_runtime_dependency "json"
  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
