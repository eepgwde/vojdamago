
all: all-local
	cd docs; bundle exec jekyll serve --config _config.yml

all-local:
	cd docs; bundle install
