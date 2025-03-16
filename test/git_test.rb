require "test_helper"
require "fileutils"

class GitTest < Minitest::Test
  def setup
    @repo_path = Dir.mktmpdir
    `git clone "test/fixtures/repo" #{@repo_path}`
  end

  def teardown
    FileUtils.rm_rf(@repo_path)
  end

  def test_enumerate_commits
    git = Octostat::Git.new(@repo_path)
    commits = git.to_a

    assert_equal 7, commits.size

    commit = commits[0]
    assert_equal "joe@dupuis.io", commit[:email]
    assert_equal "Joé Dupuis", commit[:name]
    assert_equal "2025-03-14T20:48:26-07:00", commit[:date]
    assert_equal false, commit[:merge_commit]
    assert_equal "Louder", commit[:subject]
    assert_equal "80fc624", commit[:hash]

    commit = commits[1]
    assert_equal "joe@dupuis.io", commit[:email]
    assert_equal "Joé Dupuis", commit[:name]
    assert_equal "2025-03-14T20:47:50-07:00", commit[:date]
    assert_equal true, commit[:merge_commit]
    assert_equal "Merge branch 'main' into HEAD", commit[:subject]
    assert_equal "d27afb1", commit[:hash]
  end

  def test_count
    git = Octostat::Git.new(@repo_path)
    assert_equal 7, git.count
  end

  def test_clone_repo_if_remote
    @repo_path = "https://github.com/testdouble/octostat"
    git = Octostat::Git.new(@repo_path)
    assert git.count > 0
  end

  def test_error_on_invalid_repo
    assert_raises(Octostat::Error) { Octostat::Git.new("invalid repo") }
  end

  def test_long_hash
    git = Octostat::Git.new(@repo_path, long_hash: true)
    assert_equal "80fc62409825cf45228f070c55a54d9e7f1d8cb6", git.first[:hash]
  end
end
