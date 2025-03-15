require 'forwardable'

module Octostat
  class Database
    extend Forwardable

    PRAGMAS = {
      "foreign_keys"        => true,
      "journal_mode"        => :wal,
      "synchronous"         => :normal,
      "mmap_size"           => 134217728, # 128 megabytes
      "journal_size_limit"  => 67108864, # 64 megabytes
      "cache_size"          => 2000
    }

    def initialize file
      @db = SQLite3::Database.new file
      apply_pragma
      create_tables
    end

    def_delegators :@db, :execute, :foreign_keys, :journal_mode, :synchronous, :mmap_size, :journal_size_limit, :cache_size, :table_info


    private

    def create_tables
      db.execute <<-SQL
  create table commits (
    hash TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    date TEXT NOT NULL,
    merge_commit BOOLEAN ,
    subject TEXT NOT NULL
  );


CREATE INDEX IF NOT EXISTS idx_commits_name ON commits(name);
CREATE INDEX IF NOT EXISTS idx_commits_email ON commits(email);
SQL
    end

    def apply_pragma
      PRAGMAS.each do |pragma, value|
        db.public_send("#{pragma}=", value)
      end
    end

    attr_reader :db
  end
end
