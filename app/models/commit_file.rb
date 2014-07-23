class CommitFile
  def initialize(file, &contents_block)
    @file = file
    @contents_block = contents_block
  end

  def filename
    @file.filename
  end

  def contents
    @contents ||= begin
      if removed?
        nil
      else
        @contents_block.call
      end
    end
  end

  def relevant_line?(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
  end

  def removed?
    @file.status == 'removed'
  end

  def ruby?
    filename.match(/.*\.rb$/)
  end

  def modified_lines
    @modified_lines ||= patch.additions
  end

  def modified_line_at(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
  end

  private

  def patch
    Patch.new(@file.patch)
  end
end
