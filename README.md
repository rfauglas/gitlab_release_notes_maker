# GitlabReleaseNotesMaker

This Gem lets you create markdown release notes based on commits found between to tags (or a unique start-tag).
Commits are attached to issues based on Gitlab mode which let you find a  merge request/attached issue linked to commit.
In case no merge request is found an attempt is made to find an issue number pattern."^\s*#?(\d+)\s*-"

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gitlab_release_notes_maker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gitlab_release_notes_maker

## Build 
docker build -t rfauglas/gitlab_release_notes_maker  -t registry.gitlab.com/listopro/listo/gitlab-release-notes-maker:latest . 

## Deploy
docker login registry.gitlab.com
docker push registry.gitlab.com/listopro/listo/gitlab-release-notes-maker:latest

## Usage

docker run --rm -t registry.gitlab.com/listopro/listo/gitlab-release-notes-maker:latest bundle exec ./exe/gitlab_release_notes_maker  --project 3004858 --branch develop --token ${GITLAB_ADMIN_TOKEN} --tag-start ${currentVersionTag}

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gitlab_release_notes_maker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GitlabReleaseNotesMaker project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/gitlab_release_notes_maker/blob/master/CODE_OF_CONDUCT.md).


