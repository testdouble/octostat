require "test_helper"

class DatabaseTest < Minitest::Test
  def setup
    tempfile = Tempfile.new
    @db_path = tempfile.path
    tempfile.close
    tempfile.unlink
  end

  def test_database_creates_the_database_with_pragmas
    db = Octostat::Database.new(@db_path)
    assert_equal true, db.foreign_keys
    assert_equal "wal", db.journal_mode
    assert_equal 1, db.synchronous
    assert_equal 134217728, db.mmap_size
    assert_equal 67108864, db.journal_size_limit
    assert_equal 2000, db.cache_size
  end

  def test_database_creates_the_commits_table
    Octostat::Database.new(@db_path)

    db = SQLite3::Database.new(@db_path)
    table = db.table_info("commits")
    refute table.empty?
    table = table.to_h {|field| [field["name"], field["type"]] }

    assert_equal "boolean", table["merge_commit"]
    assert_equal "text", table["hash"]
    assert_equal "text", table["email"]
    assert_equal "text", table["name"]
    assert_equal "text", table["subject"]
    assert_equal "text", table["date"]
  end

  def test_reopen_db_if_exists
    Octostat::Database.new(@db_path)
    Octostat::Database.new(@db_path)
  end

  def test_insert_commit
    db = Octostat::Database.new(@db_path)

    db.insert_commit hash: "123", name: "Joe", email: "joe@dupuis.io", subject: "super commit", date: "2024-03-14T15:30:45-07:00", merge_commit: false

    results = db.execute("select * from commits;")
    assert_equal 1, results.size
    hash, email, name, date, merge_commit, subject = results.first
    assert_equal "123", hash
    assert_equal "joe@dupuis.io", email
    assert_equal "Joe", name
    assert_equal "2024-03-14T15:30:45-07:00", date
    assert_equal 0, merge_commit
    assert_equal "super commit", subject
  end
end
