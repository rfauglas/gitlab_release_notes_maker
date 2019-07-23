require "gitlab_release_notes_maker/version"
require "rest-client"
require "gitlab"
require 'json'
require 'optparse'

module GitlabJobExporter

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
  end.parse!

  g = Gitlab.client(endpoint: 'https://gitlab.com/api/v4', private_token: options[:token])


  # pipelines = g.pipelines(options[:project], :page=>2);
  pipelines = g.pipelines(options[:project], :per_page=>2000);

  CSV.open("jobs.csv", "wb") do |csv|
    csv << ["stage", "Job name", "Duration", "start date"]

    pipelines.each do |pipeline|
      puts "pipeline #{pipeline}";
      jobs = g.pipeline_jobs(options[:project], pipeline.id, :scope => "success");
      jobs.each { |job|
        csv << [ job.stage, job.name, job.duration, job.created_at];
      }
    end
  end
end