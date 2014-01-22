$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spud_photos/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tb_photos"
  s.version     = Spud::Photos::VERSION
  s.authors     = ["Greg Woods"]
  s.email       = ["greg@westlakedesign.com"]
  s.homepage    = "http://bitbucket.org/westlakedesign/tb_photos"
  s.summary     = "Twice Baked Engine"
  s.description = "Twice Baked is a feature complete photo management/gallery for the spud engine. Manage multiple galleries, albums, and photos. Use HTML 5 to drag and drop many images at once."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir.glob('spec/**/*').reject{ |f| f.match(/^spec\/dummy\/(log|tmp)/) }

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency 'tb_core', "~> 1.2"
  s.add_dependency 'paperclip'

  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'rspec', '2.8.0'
  s.add_development_dependency 'rspec-rails', '2.8.1'
  s.add_development_dependency 'shoulda', '~> 3.0.1'
  s.add_development_dependency 'factory_girl', '~> 3.0'
  s.add_development_dependency 'mocha', '0.10.3'
  s.add_development_dependency 'database_cleaner', '1.0.0.RC1'
  s.add_development_dependency 'simplecov', '~> 0.6.4'
end
