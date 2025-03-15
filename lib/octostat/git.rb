require "open3"


module Octostat
  class Git
    include Enumerable

    LOG_FORMAT = <<~FORMAT.strip
      %h
      %ae
      %an
      %aI
      %P
      %s
    FORMAT

    ENTRY_LENGTH = LOG_FORMAT.lines.size

    COMMAND = ["git", "log", "--pretty=format:#{LOG_FORMAT}"]

    def initialize path
      @path = path
    end

    def env
      {"GIT_DIR" => path}
    end

    def each
      return enum_for(:each) unless block_given?
      Open3.popen2e(*COMMAND, chdir: path) do |input, output, wait_thr|
        output.each_slice(ENTRY_LENGTH) do |commit|
          commit.each(&:strip!)
          hash, email, name, date, parents, subject = commit
          merge_commit = parents.split(" ").size > 1
          yield({
            hash:,
            email:,
            name:,
            date:,
            merge_commit:,
            subject:
          })
        end
      end
    end

    private

    attr_reader :path
  end
end
