require "open3"
require "tmpdir"

module Octostat
  class Git
    include Enumerable

    def initialize path, long_hash: false
      @path = Dir.exist?(path) ? path : clone_repo(path)
      @long_hash = long_hash
    end

    def env
      {"GIT_DIR" => path}
    end

    def count
      return @count if @count
      @count ||= Open3.capture2(*count_command, chdir: path).first.to_i
    end

    def each
      return enum_for(:each) unless block_given?
      Open3.popen2e(*list_command, chdir: path) do |input, output, wait_thr|
        output.each_slice(log_entry_length) do |commit|
          commit.map!(&:chomp)
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

    def clone_command = ["git", "clone"]

    def count_command = ["git", "rev-list", "--count", "HEAD"]

    def list_command = ["git", "log", "--pretty=format:#{log_format}"]

    def log_format
      @log_format ||= [
        (long_hash ? "%H" : "%h"),
        "%ae",
        "%an",
        "%aI",
        "%P",
        "%s"
      ].join("\n")
    end

    def log_entry_length
      @log_entry_length ||= log_format.lines.size
    end

    def clone_repo upstream
      puts "Cloning #{upstream}"
      repo_path = Dir.mktmpdir
      status = Open3.capture2(*clone_command, upstream, repo_path)[1]
      raise Octostat::Error.new("Error cloning '#{upstream}'") unless status.success?
      repo_path
    end

    attr_reader :path, :long_hash
  end
end
