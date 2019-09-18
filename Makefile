MAKEFLAGS += --silent

.PHONY: deps site

default:
	echo "No default target"

make deps:
	gem install jekyll bundler

site:
	bundle exec jekyll serve
