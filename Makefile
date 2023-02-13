# Draft Makefile. You will need:
# - mmark (https://github.com/miekg/mmark)
# - xml2rfc (https://xml2rfc.tools.ietf.org/)

DRAFT=draft-dickinson-dnsop-efficient-zone-file
VERSION=00

XML=$(DRAFT).xml
HTML=$(DRAFT)-$(VERSION).html
TXT=$(DRAFT)-$(VERSION).txt

.PHONY: clean

all: $(HTML) $(TXT) 

$(XML): $(DRAFT).md; mmark $< > $@

$(HTML): $(XML) ; xml2rfc --html -o $@ $<
$(TXT): $(XML) ; xml2rfc --text -o $@ $<

clean: ; rm $(XML) $(HTML) $(TXT) 
