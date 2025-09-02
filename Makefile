# Find all .md files in methodology/ and convert to .pdf paths
DOCS = $(patsubst methodology/%.md,methodology/%.pdf,$(wildcard methodology/*.md))

all: $(DOCS)

# Pattern rule: convert any .md to .pdf
methodology/%.pdf: methodology/%.md
	pandoc $< -o $@

commit: all
	git add methodology/*.md methodology/*.pdf
	git commit -m "Update documentation"
	git push

clean:
	rm -f methodology/*.pdf

.PHONY: all commit clean