run:
	docker run --rm -v $(CURDIR):/srv/jekyll -p 4000:4000 -it jekyll/jekyll

.PHONY: run
