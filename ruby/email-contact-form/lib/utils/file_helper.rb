class FileHelper
    def self.get_static_file(filename)
      path = File.join(File.dirname(__FILE__), '..', 'static', filename)
      puts "Attempting to read file: #{path}"
      raise "File not found: #{filename}" unless File.exist?(path)
      File.read(path)
    end
  end