# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dry_scaffold}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Grimfelt"]
  s.date = %q{2009-05-01}
  s.description = %q{A DRYer scaffold generator for Rails. Generates dry semantic and standards compliant views, and dry RESTful controllers.}
  s.email = %q{grimen@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "MIT-LICENSE",
    "README.textile",
    "Rakefile",
    "TODO.textile",
    "generators/dmodel/dmodel_generator.rb",
    "generators/dry_model/USAGE",
    "generators/dry_model/dry_model_generator.rb",
    "generators/dry_model/templates/factories_factory_girl.rb",
    "generators/dry_model/templates/factories_machinist.rb",
    "generators/dry_model/templates/fixtures_standard.yml",
    "generators/dry_model/templates/migration_standard.rb",
    "generators/dry_model/templates/model_standard.rb",
    "generators/dry_model/templates/unit_test_standard.rb",
    "generators/dry_scaffold/USAGE",
    "generators/dry_scaffold/dry_scaffold_generator.rb",
    "generators/dry_scaffold/templates/controller_inherited_resources.rb",
    "generators/dry_scaffold/templates/controller_standard.rb",
    "generators/dry_scaffold/templates/functional_test_standard.rb",
    "generators/dry_scaffold/templates/helper_standard.rb",
    "generators/dry_scaffold/templates/helper_test_standard.rb",
    "generators/dry_scaffold/templates/prototypes/controller_inherited_resources.rb",
    "generators/dry_scaffold/templates/prototypes/controller_standard.rb",
    "generators/dry_scaffold/templates/prototypes/controller_test_standard.rb",
    "generators/dry_scaffold/templates/prototypes/helper_standard.rb",
    "generators/dry_scaffold/templates/prototypes/helper_test_standard.rb",
    "generators/dry_scaffold/templates/prototypes/layout.html.haml",
    "generators/dry_scaffold/templates/prototypes/view__form.html.haml",
    "generators/dry_scaffold/templates/prototypes/view__item.html.haml",
    "generators/dry_scaffold/templates/prototypes/view_edit.html.haml",
    "generators/dry_scaffold/templates/prototypes/view_index.html.haml",
    "generators/dry_scaffold/templates/prototypes/view_new.html.haml",
    "generators/dry_scaffold/templates/prototypes/view_show.html.haml",
    "generators/dry_scaffold/templates/view__form.html.haml",
    "generators/dry_scaffold/templates/view__item.html.haml",
    "generators/dry_scaffold/templates/view_edit.html.haml",
    "generators/dry_scaffold/templates/view_index.html.haml",
    "generators/dry_scaffold/templates/view_layout.html.haml",
    "generators/dry_scaffold/templates/view_new.html.haml",
    "generators/dry_scaffold/templates/view_show.html.haml",
    "generators/dscaffold/dscaffold_generator.rb",
    "rails/init.rb",
    "tasks/dry_scaffold.rake"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/grimen/dry_scaffold/tree/master}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{A DRYer scaffold generator for Rails. Generates dry semantic and standards compliant views, and dry RESTful controllers.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
