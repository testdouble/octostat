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

    commit = commits[1]
    assert_equal "joe@dupuis.io", commit[:email]
    assert_equal "Joé Dupuis", commit[:name]
    assert_equal "2025-03-14T20:47:50-07:00", commit[:date]
    assert_equal true, commit[:merge_commit]
    assert_equal "Merge branch 'main' into HEAD", commit[:subject]
  end
end
