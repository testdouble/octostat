require "test_helper"

class CommandTest < Minitest::Test
  def setup
    @repo_path = Dir.mktmpdir
    @work_dir = Dir.mktmpdir
    `git clone "test/fixtures/repo" #{@repo_path}`
  end

  def teardown
    FileUtils.rm_rf(@repo_path)
    FileUtils.rm_rf(@work_dir)
  end

  def test_read_from_given_path
    Dir.chdir(@work_dir) do
      Octostat::Command.new(@repo_path).call
      db = SQLite3::Database.new("octostat.sqlite")

      results = db.execute("select hash from commits order by hash limit 1;")

      assert_equal "4034bcd", results.first.first
    end
  end

  def test_read_from_current_path_if_arg_omitted
    Dir.chdir(@repo_path) do
      Octostat::Command.new.call
      db = SQLite3::Database.new("octostat.sqlite")

      results = db.execute("select hash from commits order by hash limit 1;")

      assert_equal "4034bcd", results.first.first
    end
  end

  def test_db_long_arg_change_the_db_name
    Dir.chdir(@repo_path) do
      Octostat::Command.new("--db=new_name.sqlite").call
      db = SQLite3::Database.new("new_name.sqlite")

      results = db.execute("select hash from commits order by hash limit 1;")

      assert_equal "4034bcd", results.first.first
    end
  end

  def test_db_short_arg_change_the_db_name
    Dir.chdir(@repo_path) do
      Octostat::Command.new("-d", "new_name.sqlite").call
      db = SQLite3::Database.new("new_name.sqlite")

      results = db.execute("select hash from commits order by hash limit 1;")

      assert_equal "4034bcd", results.first.first
    end
  end

  def test_mixing_positional_arg_with_named_arg
    Dir.chdir(@work_dir) do
      Octostat::Command.new(@repo_path, "-d", "new_name.sqlite").call
      db = SQLite3::Database.new("new_name.sqlite")

      results = db.execute("select hash from commits order by hash limit 1;")

      assert_equal "4034bcd", results.first.first
    end
  end

  def test_error_on_invalid_repo
    stderr_output = StringIO.new
    $stderr = stderr_output

    assert_raises(SystemExit) do
      Octostat::Command.new("invalid repo").call
    end

    $stderr = STDERR
    assert_equal "Error cloning 'invalid repo'\n", stderr_output.string
  end
end
