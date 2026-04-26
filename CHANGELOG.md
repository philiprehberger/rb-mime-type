# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-25

### Added
- `MimeType.canonical(mime)` mapping legacy MIME aliases (`image/jpg`, `text/xml`, `application/x-javascript`, ...) to their canonical form
- `MimeType.valid?` now accepts known aliases
- Magic-byte detection for HEIC, HEIF, AVIF, and JPEG XL via ISOBMFF `ftyp` brand inspection

### Fixed
- Gemspec author/email metadata now match the standardized values

## [0.3.0] - 2026-04-16

### Added
- Category predicates: `image?`, `text?`, `audio?`, `video?`, `application?`, `font?`, `multipart?`, `message?`

### Changed
- `required_ruby_version` tightened to `'>= 3.1.0'` to match the Ruby package guide

## [0.2.0] - 2026-04-03

### Added
- Add `MimeType.register(extension, mime_type)` for custom MIME type registration
- Add `MimeType.unregister(extension)` to remove custom registrations
- Add `MimeType.charset(mime)` for default charset detection (utf-8 for text types)
- Add `MimeType.parse_accept(header)` for HTTP Accept header parsing with quality factors
- Add `MimeType.best_match(available, accept_header)` for content negotiation
- Add `MimeType.text?(mime)` predicate for text MIME types
- Add `MimeType.binary?(mime)` predicate for non-text MIME types

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.3] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-23

### Fixed
- Standardize README description to match template guide
- Update gemspec summary to match README description

## [0.1.1] - 2026-03-22

### Added
- Add bug_tracker_uri metadata to gemspec

## [0.1.0] - 2026-03-22

### Added
- Initial release
- MIME type detection from file extensions (200+ mappings)
- MIME type detection from filenames
- Magic byte content detection (30+ file formats)
- Reverse lookup from MIME type to extensions
- Category classification for MIME types
- MIME type format validation
