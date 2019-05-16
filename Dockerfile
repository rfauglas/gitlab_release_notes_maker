FROM ruby:2.5

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y vim

COPY Gemfile Gemfile.lock *.gemspec ./
COPY ./lib/gitlab_release_notes_maker/version.rb ./lib/gitlab_release_notes_maker/
RUN bundle install

COPY . .

CMD  ["bundle", "exec", "gitlab_release_notes_maker"]