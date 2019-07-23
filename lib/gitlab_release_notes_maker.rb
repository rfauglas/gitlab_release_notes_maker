require "gitlab_release_notes_maker/version"
require "rest-client"
require "gitlab"
require 'json'
require 'optparse'


module GitlabReleaseNotesMaker
  Issue = Struct.new(:iid, :title, :labels)
  Commit = Struct.new(:id, :title, :message)

  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: listopro/listo [options]"
    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
    opts.on("--project PROJECT", "The Gitlab complete project name <group>/<repository>") do |p|
      options[:project] = p
    end
    opts.on("--token TOKEN", "The Gitlab access token") do |t|
      options[:token] = t
    end
    opts.on("--tag-start TAG1", "Tag1") do |t|
      options[:tag1] = t
    end
    opts.on("--tag-end [TAG2]", "Tag1") do |t|
      options[:tag2] = t
    end
    opts.on("--branch BRANCH", "Branch name default master") do |b|
      options[:branch] = b || 'master'
    end
    opts.on("--verbose", "Verbose mode") do |v|
      options[:verbose] = true;
    end
  end.parse!


  g = Gitlab.client(endpoint: 'https://gitlab.com/api/v4', private_token: options[:token])

  project = g.project(options[:project])
  date1 = g.tag(options[:project], options[:tag1]).commit.created_at
  date2 = options[:tag2] ? g.tag(options[:project], options[:tag2]).commit.created_at : Time.now.utc.iso8601

  commits = g.commits(options[:project], :since => date1, :until => date2, :ref_name => options[:branch])

  issue_commmits = {}
  discarded_commits = []

  issues = Set.new

  def self.findIssue(msg, g, project_id)
    m = /Closes #(\d+)/.match(msg)

    if (m)
      issue_number = m.captures[0]
      issue = g.issue(project_id, issue_number)

      #TODO should be an array...
      return Issue.new(issue.iid, issue.title, issue.labels)
    end
  end

  def self.convertCommit(commit)
    return Commit.new(commit.id, commit.title, commit.message)
  end

  commits.each do |c|
    commit = convertCommit(c)
    discarded_commits << commit

    if (options[:verbose])
      puts "Commit - #{commit.id}: #{commit.title}"
      puts "->#{commit.message}"
    end
    mrs = g.commit_merge_requests(project.id, commit.id)
    mrs.each do |mr|
      next unless mr.state == "merged"

      g.merge_request_closes_issues(project.id, mr.iid).each do |i|
        issue = Issue.new(i.iid, i.title, i.labels)
        issue_commmits[issue] ||= []
        issue_commmits[issue] << commit
        discarded_commits.delete commit
        issues.add(issue.iid)

      end
    end
    if (mrs.empty? && (i = findIssue(commit.message, g, project.id)))
      issue = Issue.new(i.iid, i.title, i.labels)
      issue_commmits[issue] ||= []
      issue_commmits[issue] << commit
      discarded_commits.delete commit
      issues.add(issue.iid)
    end
  end

  puts "Release notes pour #{options[:tag2]}"

  print <<-HEREDOC
  
|labels | issue | description | commits |
|-------|-------|-------------|---------|
  HEREDOC

  issue_commmits.sort_by {|issue, commits| issue.labels.sort.join(", ")}
      .each do |issue, issue_commits|
    print "| #{issue.labels.sort.join(", ")}| [##{issue.iid}](https://gitlab.com/listopro/listo/issues/#{issue.iid}) | #{issue.title} |"
    print issue_commits
              .collect {|commit| "[#{commit.id}](https://gitlab.com/listopro/listo/commit/#{commit.id})"}
              .join("<br/> ")
    puts "|\n"
  end
  puts "\nCommit non rattachés à des issues:"
  print <<-HEREDOC

|ID     | description |
|-------|-------------|
  HEREDOC

  resolved = 0


  discarded_commits.each do |commit|
    puts "| [#{commit.id}](https://gitlab.com/listopro/listo/commit/#{commit.id}) | #{commit.title} | "
  end


end
