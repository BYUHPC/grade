# Example Makefile

# Variables
VERSION := $(shell head -n 1 VERSION.txt)
DATE := $(shell date +%F)
DOCS := README.md INTERNALS.md HOOKS.md VERSION.txt
BIN_FILES := bin/grade
LIBEXEC_FILES := libexec/add_grade libexec/print_grade libexec/grade_utils.py libexec/grade_hooks
MAN_PAGE_MD := share/man/man1/grade.1.md
MAN_PAGE := share/man/man1/grade.1
MAN_PAGE_BUILD := pandoc -s -f markdown -t man <(sed "s/@DATE/$(DATE)/g; s/@VERSION/$(VERSION)/g" $(MAN_PAGE_MD)) -o $(MAN_PAGE)
DESTDIR ?= /
DIST_DIR := grade-$(VERSION)
distrib: DESTDIR := $(DIST_DIR)
TARBALL := $(DIST_DIR).tar.gz

# Default target
all: $(MAN_PAGE) $(SCRIPTS)

# Generate man page from markdown
$(MAN_PAGE): $(MAN_PAGE_MD)
	$(MAN_PAGE_BUILD)

# Install target
install:
	mkdir -p $(DESTDIR)/bin $(DESTDIR)/libexec
	-@[ -f $(MAN_PAGE) ] || $(MAN_PAGE_BUILD)
	@[ -f $(MAN_PAGE) ] && install -D -m 644 $(MAN_PAGE) $(DESTDIR)/$(MAN_PAGE)
	@[ -f $(MAN_PAGE) ] || echo "Man page generation failed (probably due to missing pandoc)"
	cp $(BIN_FILES) $(DESTDIR)/bin
	cp -r $(LIBEXEC_FILES) $(DESTDIR)/libexec

# Distrib target
distrib: install
	cp -r test Makefile $(DOCS) $(DESTDIR)
	cp $(MAN_PAGE_MD) $(DESTDIR)/$(MAN_PAGE_MD)
	tar -czf $(TARBALL) $(DESTDIR)

test:
	test/test.sh

# Clean target
clean:
	rm -f $(MAN_PAGE) $(TARBALL)
	rm -rf $(DIST_DIR)
	@echo "Clean complete."

.PHONY: all distrib install clean test
