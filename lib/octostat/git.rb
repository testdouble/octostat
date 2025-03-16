require "open3"
require "tmpdir"

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

    LIST_COMMAND = ["git", "log", "--pretty=format:#{LOG_FORMAT}"]
    COUNT_COMMAND = ["git", "rev-list", "--count", "HEAD"]
    CLONE_COMMAND = ["git", "clone"]

    def initialize path
      @path = Dir.exist?(path) ? path : clone_repo(path)
    end

    def env
      {"GIT_DIR" => path}
    end

    def count
      @count ||= Open3.capture2(*COUNT_COMMAND, chdir: path).first.to_i
    end

    def each
      return enum_for(:each) unless block_given?
      Open3.popen2e(*LIST_COMMAND, chdir: path) do |input, output, wait_thr|
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

    def clone_repo upstream
      repo_path = Dir.mktmpdir
      status = Open3.capture2(*CLONE_COMMAND, upstream, repo_path)[1]
      raise Octostat::Error.new("Error cloning '#{upstream}'") unless status.success?
      repo_path
    end

    attr_reader :path
  end
end
