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

    COMMIT_INSERT = "INSERT OR IGNORE INTO commits (hash, email, name, date, merge_commit, subject) VALUES (?, ?, ?, ?, ?, ?)"

    def initialize file
      @db = SQLite3::Database.new file
      apply_pragma
      create_tables
      @commit_statement = db.prepare(COMMIT_INSERT)
    end

    def insert_commit hash:, name:, email:, subject:, date:, merge_commit:
      commit_statement.execute([
        hash,
        email,
        name,
        date,
        (merge_commit ? 1 : 0),
        subject
      ])
    end

    def_delegators :@db, :execute, :foreign_keys, :journal_mode, :synchronous, :mmap_size, :journal_size_limit, :cache_size, :table_info

    private

    def create_tables
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS commits (
          hash TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          merge_commit BOOLEAN,
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

    attr_reader :db, :commit_statement
  end
end
