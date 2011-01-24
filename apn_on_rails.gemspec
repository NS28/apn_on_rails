Gem::Specification.new do |s|
  s.name = %q{apn_on_rails}
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["markbates", "Rebecca Nesson"]
  s.date = %q{2010-11-09}
  s.description = %q{APN on Rails is a Ruby on Rails gem that allows you to easily add Apple Push Notification (iPhone) support to your Rails application.}
  s.email = %q{roland.venesz@wopata.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README",
    "README.textile" ]
  s.files = [
    ".rspec",
    ".specification",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README",
    "README.textile",
    "Rakefile",
    "VERSION",
    "apn_on_rails.gemspec",
    "autotest/discover.rb",
    "spec/rails_root/config/apple_push_notification_development.pem" ]
  s.homepage = %q{http://github.com/wopata/apn_on_rails}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Apple Push Notifications on Rails}
  s.test_files = Dir['spec/**/*.rb']

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<configatron>, [">= 0"])
      s.add_development_dependency(%q<autotest>, [">= 0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0.rc.5"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.0.pre2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<actionpack>, ["~> 2.3.8"])
      s.add_development_dependency(%q<activerecord>, ["~> 2.3.8"])
    else
      s.add_dependency(%q<configatron>, [">= 0"])
      s.add_dependency(%q<autotest>, [">= 0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.0.rc.5"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.0.pre2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<actionpack>, ["~> 2.3.8"])
      s.add_dependency(%q<activerecord>, ["~> 2.3.8"])
    end
  else
    s.add_dependency(%q<configatron>, [">= 0"])
    s.add_dependency(%q<autotest>, [">= 0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.0.rc.5"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.0.pre2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<actionpack>, ["~> 2.3.8"])
    s.add_dependency(%q<activerecord>, ["~> 2.3.8"])
  end
end
