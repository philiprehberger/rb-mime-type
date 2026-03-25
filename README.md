# philiprehberger-mime_type

[![Tests](https://github.com/philiprehberger/rb-mime-type/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-mime-type/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-mime_type.svg)](https://rubygems.org/gems/philiprehberger-mime_type)
[![License](https://img.shields.io/github/license/philiprehberger/rb-mime-type)](LICENSE)

MIME type detection from file extensions and magic bytes with 200+ mappings

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-mime_type"
```

Or install directly:

```bash
gem install philiprehberger-mime_type
```

## Usage

```ruby
require "philiprehberger/mime_type"

Philiprehberger::MimeType.for_extension('.pdf')   # => "application/pdf"
Philiprehberger::MimeType.for_filename('photo.jpg')  # => "image/jpeg"
```

### Magic Byte Detection

```ruby
content = File.binread('image.png', 16)
Philiprehberger::MimeType.for_content(content)  # => "image/png"
```

### Reverse Lookup

```ruby
Philiprehberger::MimeType.extensions('text/html')  # => [".html", ".htm"]
```

### Category

```ruby
Philiprehberger::MimeType.category('image/png')   # => :image
Philiprehberger::MimeType.category('audio/mpeg')   # => :audio
Philiprehberger::MimeType.category('video/mp4')    # => :video
```

### Validation

```ruby
Philiprehberger::MimeType.valid?('text/plain')     # => true
Philiprehberger::MimeType.valid?('not valid')      # => false
```

## API

| Method | Description |
|--------|-------------|
| `MimeType.for_extension(ext)` | Detect MIME type from a file extension |
| `MimeType.for_filename(name)` | Detect MIME type from a filename |
| `MimeType.for_content(bytes)` | Detect MIME type from magic bytes |
| `MimeType.extensions(mime)` | Get file extensions for a MIME type |
| `MimeType.category(mime)` | Get the category of a MIME type |
| `MimeType.valid?(mime)` | Check if a MIME type string is valid |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
