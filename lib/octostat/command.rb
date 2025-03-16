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
      puts_progress git.count
      puts "\nDone!"
    end

    private

    attr_reader :db_path, :path, :batch_size, :git

    def puts_progress processed
      print "\r#{(processed.to_f / git.count.to_f * 100).ceil}%"
      $stdout.flush
    end

    def parser
      OptionParser.new do |opts|
        opts.on("-dDB", "--db=DB", "Path to the SQLite db") { |db| @db_path = db }
      end
    end
  end
end
