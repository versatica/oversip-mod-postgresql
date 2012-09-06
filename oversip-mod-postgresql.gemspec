require "./lib/oversip-mod-postgresql/version"

::Gem::Specification.new do |spec|
  spec.name = "oversip-mod-postgresql"
  spec.version = ::OverSIP::Modules::Postgresql::VERSION
  spec.date = ::Time.now
  spec.authors = ["Inaki Baz Castillo"]
  spec.email = ["ibc@aliax.net"]
  spec.homepage = "https://github.com/versatica/oversip-mod-postgresql"
  spec.summary = "PostgreSQL connector module for OverSIP"
  spec.description = "oversip-mod-postgresql provides an easy to use PostgreSQL connector for OverSIP proxy."

  spec.required_ruby_version = ">= 1.9.2"
  spec.add_dependency "oversip", ">= 1.3.0"
  spec.add_dependency "em-pg-client", ">= 0.2.0"

  spec.files = ::Dir.glob %w{
    lib/oversip-mod-postgresql.rb
    lib/oversip-mod-postgresql/*.rb

    README.md
    AUTHORS
    LICENSE
  }

  spec.has_rdoc = false
end
