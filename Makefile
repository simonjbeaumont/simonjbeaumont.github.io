run:
	docker run --rm -v $(CURDIR):/srv/jekyll -p 4000:4000 -it jekyll/jekyll:4.2.0 jekyll serve

.PHONY: run
