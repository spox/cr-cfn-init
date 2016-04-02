require "tempfile"
require "http/client"

module CrCfnInit
  # Collection of files
  class Files

    # Singile file unit
    #
    # @note authentication not currently supported
    class File

      @encoding : String
      @owner : String
      @group : String
      @mode : String
      @authentication : Hash(String, Hash(String, String))

      getter path
      getter content
      getter source
      getter encoding
      getter group
      getter owner
      getter mode
      getter authentication

      # Create a new file instance
      #
      # @param path [String]
      # @param content [String]
      # @param source [String]
      # @param encoding [String] "plain" or "base64"
      # @param owner [String]
      # @param group [String]
      # @param mode [String]
      # @param authentication [Hash(String, Hash(String, String))]
      #
      # @return [self]
      def initialize(
            @path : String,
            @content : String? = nil,
            @source : String? = nil,
            encoding : String? = nil,
            owner : String? = nil,
            group : String? = nil,
            mode : String? = nil,
            authentication : Hash(String, Hash(String, String))? = nil
          )
        @encoding = encoding.nil? ? "plain" : encoding.to_s
        @group = group.nil? ? ENV.fetch("USER", "root") : group.to_s
        @owner = owner.nil? ? ENV.fetch("USER", "root") : owner.to_s
        @mode = mode.nil? ? "000644" : mode.to_s
        @written = false
        if(@content && @source)
          raise Error::FileDefinitionInvalid.new("File cannot contain both `content` and `source`!")
        end
      end

      # Write the file to disk
      #
      # @return [Bool]
      def write!
        unless(@written)
          if((mode = @mode) && mode[0, 3] == "120")
            generate_symlink
          else
            file = @content ? write_from_content : write_from_source
            set_file_owner(file)
            set_file_mode(file)
            move_to_destination(file)
          end
          @written = true
        else
          raise Error::FileWriteAlreadyPerformed.new("Write action already performed! (`#{@path}`)")
        end
      end

      # Create symlink
      #
      # @return [Nil]
      def generate_symlink : Nil
        if(::File.exists?(@path))
          ::File.delete(@path)
        end
        ::File.symlink(@content as String, @path)
        nil
      end

      # Move file from temporary location to path destination
      #
      # @param file [Tempfile]
      # @return [Bool]
      def move_to_destination(file) : Bool
        result = Process.run(
          "mv #{file.path} #{@path}",
          nil, nil, false, true
        ).success?
        unless(result)
          raise Error::FileWriteFailure.new "Failed to write file to defined path! (`#{@path}`)"
        end
        result
      end

      # Set the group and owner for the file
      #
      # @param file [Tempfile]
      # @return [Bool]
      # @note shelling out for now until methods are in stdlib
      def set_file_owner(file) : Bool
        result = Process.run(
          "chown #{@owner}:#{@group} #{file.path}",
          nil, nil, false, true
        ).success?
        unless(result)
          raise Error::FileAttributeFailure.new "Failed to set owner/group! (`#{@path}`)"
        end
        result
      end

      # Set the permission for the file
      #
      # @param file [Tempfile]
      # @return [Bool]
      # @note shelling out for now until methods are in stdlib
      def set_file_mode(file) : Bool
        result = Process.run(
          "chmod #{@mode[3, 3]} #{file.path}",
          nil, nil, false, true
        ).success?
        unless(result)
          raise Error::FileAttributeFailure.new "Failed to set mode! (`#{@path}`)"
        end
        result
      end

      # Write the file using provided content
      #
      # @return [Tempfile]
      def write_from_content : Tempfile
        file = Tempfile.open("cr-cfn-init") do |f|
          f.print content
        end
        file
      end

      # Write the file using content from provided source
      #
      # @return [Tempfile]
      # @todo enable authentication usage
      def write_from_source : Tempfile
        response = HTTP::Client.get(@source.to_s)
        if(response.success?)
          file = Tempfile.open("cr-cfn-init") do |f|
            f.print response.body
          end
        else
          raise Error::FileSourceDownloadFailed.new "Failed to download file from source. Error code: `#{response.status_code}` (`#{@path}`)"
        end
        file
      end

    end

  end
end
