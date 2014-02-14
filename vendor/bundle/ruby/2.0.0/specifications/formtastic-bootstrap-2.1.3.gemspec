# -*- encoding: utf-8 -*-
# stub: formtastic-bootstrap 2.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "formtastic-bootstrap"
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Matthew Bellantoni", "Aaron Stone"]
  s.date = "2013-06-13"
  s.description = "Formtastic form builder to generate Twitter Bootstrap-friendly markup."
  s.email = ["mjbellantoni@yahoo.com", "aaron@serendipity.cx"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.md"]
  s.files = ["LICENSE.txt", "README.md"]
  s.homepage = "http://github.com/mjbellantoni/formtastic-bootstrap"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.1"
  s.summary = "Formtastic form builder to generate Twitter Bootstrap-friendly markup."

  s.installed_by_version = "2.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<formtastic>, ["~> 2.2"])
      s.add_development_dependency(%q<ammeter>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<rake>, ["< 1.0"])
      s.add_development_dependency(%q<rcov>, ["< 1.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rspec_tag_matchers>, [">= 0"])
      s.add_development_dependency(%q<tzinfo>, [">= 0"])
    else
      s.add_dependency(%q<formtastic>, ["~> 2.2"])
      s.add_dependency(%q<ammeter>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.2"])
      s.add_dependency(%q<rake>, ["< 1.0"])
      s.add_dependency(%q<rcov>, ["< 1.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.8.0"])
      s.add_dependency(%q<rspec_tag_matchers>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
    end
  else
    s.add_dependency(%q<formtastic>, ["~> 2.2"])
    s.add_dependency(%q<ammeter>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.2"])
    s.add_dependency(%q<rake>, ["< 1.0"])
    s.add_dependency(%q<rcov>, ["< 1.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.8.0"])
    s.add_dependency(%q<rspec_tag_matchers>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
  end
end
