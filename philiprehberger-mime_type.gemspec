# frozen_string_literal: true

require_relative 'lib/philiprehberger/mime_type/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-mime_type'
  spec.version = Philiprehberger::MimeType::VERSION
  spec.authors = ['philiprehberger']
  spec.email = ['philiprehberger@users.noreply.github.com']

  spec.summary = 'MIME type detection from file extensions and magic bytes'
  spec.description = 'Detect MIME types from file extensions, filenames, and binary content using magic ' \
                     'byte signatures. Includes 200+ extension mappings and 30+ magic byte patterns for ' \
                     'common file formats.'
  spec.homepage = 'https://github.com/philiprehberger/rb-mime-type'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
