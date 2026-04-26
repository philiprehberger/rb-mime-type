# frozen_string_literal: true

require_relative 'mime_type/version'
require_relative 'mime_type/extensions'
require_relative 'mime_type/magic'

module Philiprehberger
  module MimeType
    class Error < StandardError; end

    # Maps legacy / non-standard MIME types to their canonical form.
    ALIASES = {
      'image/jpg' => 'image/jpeg',
      'image/pjpeg' => 'image/jpeg',
      'image/x-png' => 'image/png',
      'application/x-javascript' => 'text/javascript',
      'application/javascript' => 'text/javascript',
      'text/xml' => 'application/xml',
      'application/x-yaml' => 'application/yaml',
      'text/yaml' => 'application/yaml',
      'audio/mp3' => 'audio/mpeg'
    }.freeze

    @custom_extensions = {}

    # Returns the canonical MIME type for `mime`. Legacy or non-standard aliases
    # (e.g. `image/jpg`) are mapped to their canonical form (`image/jpeg`). Any
    # input that is not a known alias is returned unchanged after lowercasing.
    #
    # @param mime [String]
    # @return [String]
    def self.canonical(mime)
      return mime if mime.nil?

      normalized = mime.to_s.downcase
      ALIASES.fetch(normalized, normalized)
    end

    # Register a custom MIME type mapping for an extension
    #
    # @param ext [String] file extension (with or without leading dot)
    # @param mime_type [String] MIME type string
    # @return [void]
    def self.register(ext, mime_type)
      normalized = ext.to_s.strip.downcase
      normalized = ".#{normalized}" unless normalized.start_with?('.')
      @custom_extensions[normalized] = mime_type
    end

    # Remove a custom registration for an extension
    #
    # @param ext [String] file extension (with or without leading dot)
    # @return [void]
    def self.unregister(ext)
      normalized = ext.to_s.strip.downcase
      normalized = ".#{normalized}" unless normalized.start_with?('.')
      @custom_extensions.delete(normalized)
    end

    # Detect MIME type from a file extension
    #
    # @param ext [String] file extension (with or without leading dot)
    # @return [String, nil] MIME type or nil if unknown
    def self.for_extension(ext)
      normalized = ext.to_s.strip.downcase
      normalized = ".#{normalized}" unless normalized.start_with?('.')
      @custom_extensions[normalized] || EXTENSION_MAP[normalized]
    end

    # Detect MIME type from a filename
    #
    # @param name [String] filename with extension
    # @return [String, nil] MIME type or nil if unknown
    def self.for_filename(name)
      ext = File.extname(name.to_s.strip).downcase
      return nil if ext.empty?

      @custom_extensions[ext] || EXTENSION_MAP[ext]
    end

    # Detect MIME type from file content using magic bytes
    #
    # @param bytes [String] binary content (first 300+ bytes recommended)
    # @return [String, nil] MIME type or nil if unrecognized
    def self.for_content(bytes)
      return nil if bytes.nil? || bytes.empty?

      raw = bytes.b

      MAGIC_SIGNATURES.each do |offset, pattern, mime|
        next if raw.length < offset + pattern.length

        match = pattern.each_with_index.all? do |byte, i|
          raw.getbyte(offset + i) == byte
        end

        return mime if match
      end

      isobmff_mime_for(raw)
    end

    # Detect ISOBMFF-based formats (HEIC/HEIF/AVIF/JXL/MP4 variants) by
    # inspecting the `ftyp` brand at bytes 8..11.
    #
    # @param raw [String] binary content (ASCII-8BIT)
    # @return [String, nil]
    def self.isobmff_mime_for(raw)
      return nil if raw.length < 12
      return nil unless raw.byteslice(4, 4) == 'ftyp'

      ISOBMFF_BRANDS[raw.byteslice(8, 4)]
    end
    private_class_method :isobmff_mime_for

    # Get file extensions for a MIME type
    #
    # @param mime [String] MIME type
    # @return [Array<String>] list of extensions (empty if unknown)
    def self.extensions(mime)
      MIME_TO_EXTENSIONS[mime.to_s.strip.downcase] || []
    end

    # Get the category of a MIME type
    #
    # @param mime [String] MIME type
    # @return [Symbol, nil] category (:text, :image, :audio, :video, :application, :font, :message)
    def self.category(mime)
      type = mime.to_s.strip.downcase
      return nil if type.empty?

      major = type.split('/').first
      case major
      when 'text' then :text
      when 'image' then :image
      when 'audio' then :audio
      when 'video' then :video
      when 'application' then :application
      when 'font' then :font
      when 'message' then :message
      when 'multipart' then :multipart
      when 'model' then :model
      end
    end

    # Check if a MIME type string is valid
    #
    # @param mime [String] MIME type to validate
    # @return [Boolean] true if the format is valid
    def self.valid?(mime)
      type = mime.to_s.strip
      return false if type.empty?

      canonical_type = canonical(type)
      canonical_type.match?(%r{\A[a-zA-Z0-9][a-zA-Z0-9!\#$\-^_.+]*/[a-zA-Z0-9][a-zA-Z0-9!\#$\-^_.+]*\z})
    end

    # Return the default charset for a MIME type
    #
    # @param mime [String] MIME type
    # @return [String, nil] "utf-8" for text types, nil for binary types
    def self.charset(mime)
      type = mime.to_s.strip.downcase
      return nil if type.empty?

      type.start_with?('text/') ? 'utf-8' : nil
    end

    # Check if a MIME type is a text type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for text/* MIME types
    def self.text?(mime)
      category_prefix?(mime, 'text')
    end

    # Check if a MIME type is an image type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for image/* MIME types
    def self.image?(mime)
      category_prefix?(mime, 'image')
    end

    # Check if a MIME type is an audio type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for audio/* MIME types
    def self.audio?(mime)
      category_prefix?(mime, 'audio')
    end

    # Check if a MIME type is a video type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for video/* MIME types
    def self.video?(mime)
      category_prefix?(mime, 'video')
    end

    # Check if a MIME type is an application type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for application/* MIME types
    def self.application?(mime)
      category_prefix?(mime, 'application')
    end

    # Check if a MIME type is a font type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for font/* MIME types
    def self.font?(mime)
      category_prefix?(mime, 'font')
    end

    # Check if a MIME type is a multipart type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for multipart/* MIME types
    def self.multipart?(mime)
      category_prefix?(mime, 'multipart')
    end

    # Check if a MIME type is a message type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for message/* MIME types
    def self.message?(mime)
      category_prefix?(mime, 'message')
    end

    # Check if a MIME type is a binary (non-text) type
    #
    # @param mime [String] MIME type
    # @return [Boolean] true for non-text MIME types
    def self.binary?(mime)
      type = mime.to_s.strip.downcase
      return false if type.empty?

      !type.start_with?('text/')
    end

    # Parse an HTTP Accept header string
    #
    # @param header [String] Accept header value
    # @return [Array<Hash>] array of { type: String, q: Float } sorted by quality descending
    def self.parse_accept(header)
      return [] if header.nil? || header.strip.empty?

      entries = header.split(',').map do |part|
        segments = part.strip.split(';').map(&:strip)
        type = segments.first
        q = 1.0

        segments[1..].each do |param|
          key, value = param.split('=', 2).map(&:strip)
          if key == 'q'
            q = value.to_f
          end
        end

        { type: type, q: q }
      end

      entries.sort_by { |e| -e[:q] }
    end

    # Content negotiation: find the best matching MIME type
    #
    # @param available [Array<String>] available MIME types
    # @param accept_header [String] Accept header value
    # @return [String, nil] best matching MIME type or nil
    def self.best_match(available, accept_header)
      return nil if available.nil? || available.empty?

      parsed = parse_accept(accept_header)
      return nil if parsed.empty?

      parsed.each do |entry|
        accepted = entry[:type]

        if accepted == '*/*'
          return available.first
        end

        # Check for type/* wildcard
        if accepted.end_with?('/*')
          prefix = accepted.split('/').first
          match = available.find { |a| a.start_with?("#{prefix}/") }
          return match if match
        elsif available.include?(accepted)
          return accepted
        end
      end

      nil
    end

    # Check whether a MIME type string starts with the given top-level type.
    # Handles nil, trailing parameters (e.g. "; charset=utf-8"), and casing.
    #
    # @param mime [String, nil] MIME type
    # @param prefix [String] top-level type (e.g. "image", "text")
    # @return [Boolean]
    def self.category_prefix?(mime, prefix)
      return false if mime.nil?

      type = mime.to_s.split(';').first.to_s.strip.downcase
      return false if type.empty?

      type.start_with?("#{prefix}/")
    end
    private_class_method :category_prefix?
  end
end
