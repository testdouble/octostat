require "optparse"

module Octostat
  class Command
    def initialize *args
      @db_path = "octostat.sqlite"
      args = parser.parse!(args)
      @path = args.first || Dir.pwd
      @batch_size = 1000
    end

    def call
      db = Database.new(db_path)
      @git = Git.new(path)
      git.each_slice(batch_size).with_index do |commits, batch|
        puts_progress batch * batch_size
        commits.each { |commit| db.insert_commit(**commit) }
      end
      puts_progress(git.count) and puts if progress
      puts "Done!"
    rescue Octostat::Error => e
      warn e.message
      exit 1
    end

    private

    attr_reader :db_path, :path, :batch_size, :git, :progress

    def puts_progress processed
      return unless progress
      print "\r#{(processed.to_f / git.count.to_f * 100).ceil}%"
      $stdout.flush
    end

    def parser
      OptionParser.new do |opts|
        opts.banner = <<~HELP
          Usage: octostat [options] [REPO]

            REPO:
              - A local path to a Git repository, or
              - A Git URL (e.g., https://github.com/user/repo.git)

            If REPO is a URL, octostat will clone it into a temporary directory.
            If REPO is omitted, octostat will use the current directory.

            Output:
              - Octostat stores repository statistics in an SQLite database.
              - By default, it writes to `./octostat.sqlite`.
              - Use `--db` to specify a custom database path.

        HELP

        opts.on("-v", "--version", "Show version information") do
          puts "Octostat version #{VERSION}"
          exit
        end

        opts.on("-dDB", "--db=DB", "Path to the SQLite db (default: ./octostat.sqlite)") { |db| @db_path = db }

        opts.on("-S", "--no-progress", "Disable progress messages. (Faster if you don't care about the output)") { @progress = false }
      end
    end
  end
end
