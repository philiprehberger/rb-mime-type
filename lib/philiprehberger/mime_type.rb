# frozen_string_literal: true

require_relative 'mime_type/version'
require_relative 'mime_type/extensions'
require_relative 'mime_type/magic'

module Philiprehberger
  module MimeType
    class Error < StandardError; end

    # Detect MIME type from a file extension
    #
    # @param ext [String] file extension (with or without leading dot)
    # @return [String, nil] MIME type or nil if unknown
    def self.for_extension(ext)
      normalized = ext.to_s.strip.downcase
      normalized = ".#{normalized}" unless normalized.start_with?('.')
      EXTENSION_MAP[normalized]
    end

    # Detect MIME type from a filename
    #
    # @param name [String] filename with extension
    # @return [String, nil] MIME type or nil if unknown
    def self.for_filename(name)
      ext = File.extname(name.to_s.strip).downcase
      return nil if ext.empty?

      EXTENSION_MAP[ext]
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

      type.match?(%r{\A[a-zA-Z0-9][a-zA-Z0-9!#$&\-^_.+]*\/[a-zA-Z0-9][a-zA-Z0-9!#$&\-^_.+]*\z})
    end
  end
end
