require 'optparse'


module Octostat
  class Command
    def initialize *args
      @db_path = "octostat.sqlite"
      args = parser.parse!(args)
      @path = args.first || Dir.pwd
    end

    def call
      db = Database.new(db_path)
      Git.new(path).each do |commit|
        db.insert_commit(**commit)
      end
    end

    private

    attr_reader :db_path, :path

    def parser
      OptionParser.new do |opts|
        opts.on("-dDB", "--db=DB", "Path to the SQLite db") { |db| @db_path = db }
      end
    end
  end
end
