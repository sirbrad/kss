module Kss
  # Public: The main KSS parser. Takes a directory full of SASS / SCSS / CSS
  # files and parses the KSS within them.
  class Parser

    # Public: Returns a hash of Sections.
    attr_accessor :sections

    # Public: Initializes a new parser based on a directory of files. Scans
    # within the directory recursively for any comment blocks that look like
    # KSS.
    #
    # paths - Each path String where style files are located.
    def initialize(*paths)
      @sections = {}

      paths.each do |path|
        Dir["#{path}/**/*.*"].each do |filename|
          parser = CommentParser.new(filename)
          parser.blocks.each do |comment_block|
            add_section comment_block, filename if self.class.kss_block?(comment_block)
          end
        end
      end
    end

    def add_section comment_text, filename
      base_path = current_directory_path(File.dirname(filename))
      base_name = File.basename(filename)
      section = Section.new(comment_text, base_path, base_name)
      @sections[section.section] = section
    end

    # Public: Takes a cleaned (no comment syntax like // or /* */) comment
    # block and determines whether it is a KSS documentation block.
    #
    # Returns a boolean indicating whether the block conforms to KSS.
    def self.kss_block?(cleaned_comment)
      return false unless cleaned_comment.is_a? String

      possible_reference = cleaned_comment.split("\n\n").last
      possible_reference =~ /Styleguide \d/
    end

    # Public: Finds the Section for a given styleguide reference.
    #
    # Returns a Section for a reference, or a blank Section if none found.
    def section(reference)
      @sections[reference] || Section.new
    end

    # Public: Removes current working directory from absolute path
    #
    # Returns a string of the current file's relative path
    def current_directory_path(file)
      file.gsub(`pwd`.chomp, "")
    end

  end
end
