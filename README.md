# philiprehberger-mime_type

[![Tests](https://github.com/philiprehberger/rb-mime-type/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-mime-type/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-mime_type.svg)](https://rubygems.org/gems/philiprehberger-mime_type)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-mime-type)](https://github.com/philiprehberger/rb-mime-type/commits/main)

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

### Custom Registration

```ruby
Philiprehberger::MimeType.register('.custom', 'application/x-custom')
Philiprehberger::MimeType.for_extension('.custom')  # => "application/x-custom"

Philiprehberger::MimeType.unregister('.custom')
Philiprehberger::MimeType.for_extension('.custom')  # => nil
```

### Charset Detection

```ruby
Philiprehberger::MimeType.charset('text/html')        # => "utf-8"
Philiprehberger::MimeType.charset('application/json')  # => nil
```

### Type Predicates

```ruby
Philiprehberger::MimeType.text?('text/plain')       # => true
Philiprehberger::MimeType.binary?('image/png')      # => true
```

### Category Predicates

```ruby
Philiprehberger::MimeType.image?('image/png')                   # => true
Philiprehberger::MimeType.text?('text/html; charset=utf-8')     # => true
Philiprehberger::MimeType.audio?('audio/mpeg')                  # => true
Philiprehberger::MimeType.video?('video/mp4')                   # => true
Philiprehberger::MimeType.application?('application/json')       # => true
Philiprehberger::MimeType.font?('font/woff2')                   # => true
Philiprehberger::MimeType.multipart?('multipart/form-data')      # => true
Philiprehberger::MimeType.message?('message/rfc822')             # => true
Philiprehberger::MimeType.image?(nil)                           # => false
```

### Accept Header Parsing

```ruby
Philiprehberger::MimeType.parse_accept('text/html;q=0.9, application/json')
# => [{ type: "application/json", q: 1.0 }, { type: "text/html", q: 0.9 }]
```

### Content Negotiation

```ruby
available = ['application/json', 'text/html']
Philiprehberger::MimeType.best_match(available, 'text/*;q=0.5, application/json')
# => "application/json"
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
| `MimeType.register(ext, mime)` | Register a custom MIME type mapping |
| `MimeType.unregister(ext)` | Remove a custom registration |
| `MimeType.charset(mime)` | Get default charset for a MIME type |
| `MimeType.parse_accept(header)` | Parse HTTP Accept header string |
| `MimeType.best_match(available, header)` | Content negotiation for best match |
| `MimeType.text?(mime)` | Check if MIME type is text |
| `MimeType.binary?(mime)` | Check if MIME type is binary |
| `MimeType.image?(mime)` | Check if MIME type is `image/*` |
| `MimeType.audio?(mime)` | Check if MIME type is `audio/*` |
| `MimeType.video?(mime)` | Check if MIME type is `video/*` |
| `MimeType.application?(mime)` | Check if MIME type is `application/*` |
| `MimeType.font?(mime)` | Check if MIME type is `font/*` |
| `MimeType.multipart?(mime)` | Check if MIME type is `multipart/*` |
| `MimeType.message?(mime)` | Check if MIME type is `message/*` |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-mime-type)

🐛 [Report issues](https://github.com/philiprehberger/rb-mime-type/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-mime-type/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
