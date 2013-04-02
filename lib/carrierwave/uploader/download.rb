# encoding: utf-8

require 'open-uri'

module CarrierWave
  module Uploader
    module Download

      depends_on CarrierWave::Uploader::Callbacks
      depends_on CarrierWave::Uploader::Configuration
      depends_on CarrierWave::Uploader::Cache

      class RemoteFile
        def initialize(uri)
          @uri = URI.parse(uri)
        end

        def original_filename
          File.basename((file.respond_to?(:base_uri) ? file.base_uri : @uri).path)
        end

        def respond_to?(*args)
          super or file.respond_to?(*args)
        end

        def http?
          @uri.scheme =~ /^https?$/
        end

      private

        def file
          if @file.blank?
            @file = Kernel.open(@uri.to_s)
            @file = @file.is_a?(String) ? StringIO.new(@file) : @file
          end
          @file

        rescue
          raise CarrierWave::DownloadError, "could not download file"
        end

        def method_missing(*args, &block)
          file.send(*args, &block)
        end
      end

      ##
      # Caches the file by downloading it from the given URL.
      #
      # === Parameters
      #
      # [url (String)] The URL where the remote file is stored
      #
      def download!(uri)
        unless uri.blank?
          file = RemoteFile.new(uri)
          raise CarrierWave::DownloadError, "trying to download a file which is not served over HTTP" unless file.http?
          cache!(file) 
        end
      end

    end # Download
  end # Uploader
end # CarrierWave

