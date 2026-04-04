# frozen_string_literal: true

require_relative 'mime_type/version'
require_relative 'mime_type/extensions'
require_relative 'mime_type/magic'

module Philiprehberger
  module MimeType
    class Error < StandardError; end

    @custom_extensions = {}

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

      nil
    end

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

      type.match?(%r{\A[a-zA-Z0-9][a-zA-Z0-9!\#$\-^_.+]*/[a-zA-Z0-9][a-zA-Z0-9!\#$\-^_.+]*\z})
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
      mime.to_s.strip.downcase.start_with?('text/')
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
  end
end
