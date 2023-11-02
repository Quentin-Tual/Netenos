gem_update:
	gem build netenos.gemspec
	gem install --local Netenos-*.gem

push: gem_update
	git add .
	git commit -m $1
	git push

clean:
	rm *.gem
	rm -r exp*