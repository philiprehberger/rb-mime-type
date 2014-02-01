# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::MimeType do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.for_extension' do
    it 'detects PNG' do
      expect(described_class.for_extension('.png')).to eq('image/png')
    end

    it 'detects without leading dot' do
      expect(described_class.for_extension('png')).to eq('image/png')
    end

    it 'detects JPEG' do
      expect(described_class.for_extension('.jpg')).to eq('image/jpeg')
    end

    it 'detects PDF' do
      expect(described_class.for_extension('.pdf')).to eq('application/pdf')
    end

    it 'detects HTML' do
      expect(described_class.for_extension('.html')).to eq('text/html')
    end

    it 'detects CSS' do
      expect(described_class.for_extension('.css')).to eq('text/css')
    end

    it 'detects JSON' do
      expect(described_class.for_extension('.json')).to eq('application/json')
    end

    it 'detects ZIP' do
      expect(described_class.for_extension('.zip')).to eq('application/zip')
    end

    it 'detects MP3' do
      expect(described_class.for_extension('.mp3')).to eq('audio/mpeg')
    end

    it 'detects MP4' do
      expect(described_class.for_extension('.mp4')).to eq('video/mp4')
    end

    it 'is case insensitive' do
      expect(described_class.for_extension('.PNG')).to eq('image/png')
    end

    it 'returns nil for unknown extension' do
      expect(described_class.for_extension('.xyz123')).to be_nil
    end

    it 'returns nil for empty string' do
      expect(described_class.for_extension('')).to be_nil
    end
  end

  describe '.for_filename' do
    it 'detects from full filename' do
      expect(described_class.for_filename('photo.jpg')).to eq('image/jpeg')
    end

    it 'detects from filename with path' do
      expect(described_class.for_filename('path/to/file.pdf')).to eq('application/pdf')
    end

    it 'returns nil for no extension' do
      expect(described_class.for_filename('README')).to be_nil
    end

    it 'is case insensitive' do
      expect(described_class.for_filename('IMAGE.PNG')).to eq('image/png')
    end

    it 'handles multiple dots' do
      expect(described_class.for_filename('archive.tar.gz')).to eq('application/gzip')
    end
  end

  describe '.for_content' do
    it 'detects PNG by magic bytes' do
      bytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00].pack('C*')
      expect(described_class.for_content(bytes)).to eq('image/png')
    end

    it 'detects JPEG by magic bytes' do
      bytes = [0xFF, 0xD8, 0xFF, 0xE0].pack('C*')
      expect(described_class.for_content(bytes)).to eq('image/jpeg')
    end

    it 'detects GIF87a by magic bytes' do
      bytes = [0x47, 0x49, 0x46, 0x38, 0x37, 0x61].pack('C*')
      expect(described_class.for_content(bytes)).to eq('image/gif')
    end

    it 'detects GIF89a by magic bytes' do
      bytes = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61].pack('C*')
      expect(described_class.for_content(bytes)).to eq('image/gif')
    end

    it 'detects PDF by magic bytes' do
      bytes = [0x25, 0x50, 0x44, 0x46, 0x2D].pack('C*')
      expect(described_class.for_content(bytes)).to eq('application/pdf')
    end

    it 'detects ZIP by magic bytes' do
      bytes = [0x50, 0x4B, 0x03, 0x04].pack('C*')
      expect(described_class.for_content(bytes)).to eq('application/zip')
    end

    it 'detects GZIP by magic bytes' do
      bytes = [0x1F, 0x8B, 0x08].pack('C*')
      expect(described_class.for_content(bytes)).to eq('application/gzip')
    end

    it 'detects BMP by magic bytes' do
      bytes = [0x42, 0x4D, 0x00, 0x00].pack('C*')
      expect(described_class.for_content(bytes)).to eq('image/bmp')
    end

    it 'detects FLAC by magic bytes' do
      bytes = [0x66, 0x4C, 0x61, 0x43].pack('C*')
      expect(described_class.for_content(bytes)).to eq('audio/flac')
    end

    it 'detects OGG by magic bytes' do
      bytes = [0x4F, 0x67, 0x67, 0x53].pack('C*')
      expect(described_class.for_content(bytes)).to eq('audio/ogg')
    end

    it 'detects WASM by magic bytes' do
      bytes = [0x00, 0x61, 0x73, 0x6D, 0x01].pack('C*')
      expect(described_class.for_content(bytes)).to eq('application/wasm')
    end

    it 'returns nil for empty content' do
      expect(described_class.for_content('')).to be_nil
    end

    it 'returns nil for nil content' do
      expect(described_class.for_content(nil)).to be_nil
    end

    it 'returns nil for unrecognized content' do
      expect(described_class.for_content('hello world')).to be_nil
    end
  end

  describe '.extensions' do
    it 'returns extensions for text/html' do
      exts = described_class.extensions('text/html')
      expect(exts).to include('.html', '.htm')
    end

    it 'returns extensions for image/jpeg' do
      exts = described_class.extensions('image/jpeg')
      expect(exts).to include('.jpg', '.jpeg')
    end

    it 'returns empty array for unknown MIME' do
      expect(described_class.extensions('unknown/type')).to eq([])
    end

    it 'is case insensitive' do
      expect(described_class.extensions('TEXT/HTML')).to include('.html')
    end
  end

  describe '.category' do
    it 'returns :image for image types' do
      expect(described_class.category('image/png')).to eq(:image)
    end

    it 'returns :text for text types' do
      expect(described_class.category('text/plain')).to eq(:text)
    end

    it 'returns :audio for audio types' do
      expect(described_class.category('audio/mpeg')).to eq(:audio)
    end

    it 'returns :video for video types' do
      expect(described_class.category('video/mp4')).to eq(:video)
    end

    it 'returns :application for application types' do
      expect(described_class.category('application/json')).to eq(:application)
    end

    it 'returns :font for font types' do
      expect(described_class.category('font/woff2')).to eq(:font)
    end

    it 'returns nil for empty string' do
      expect(described_class.category('')).to be_nil
    end
  end

  describe '.valid?' do
    it 'returns true for standard MIME types' do
      expect(described_class.valid?('text/plain')).to be true
    end

    it 'returns true for complex MIME types' do
      expect(described_class.valid?('application/vnd.openxmlformats-officedocument.wordprocessingml.document')).to be true
    end

    it 'returns true for MIME types with plus' do
      expect(described_class.valid?('application/json+ld')).to be true
    end

    it 'returns false for empty string' do
      expect(described_class.valid?('')).to be false
    end

    it 'returns false for string without slash' do
      expect(described_class.valid?('textplain')).to be false
    end

    it 'returns false for string with spaces' do
      expect(described_class.valid?('text/ plain')).to be false
    end
  end

  describe 'EXTENSION_MAP' do
    it 'contains at least 200 entries' do
      expect(described_class::EXTENSION_MAP.size).to be >= 200
    end
  end
end
