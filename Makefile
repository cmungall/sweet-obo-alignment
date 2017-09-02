## Makefile for building alignment tsvs
## Please consult README.md

# ----------------------------------------
# CONSTANTS
# ----------------------------------------
SWEET_REPO = sweet
CAT = $(SWEET_REPO)/catalog-v001.xml
SRC = $(SWEET_REPO)/sweetAll.ttl

# ontology list (OBO IDs)
ONTS = envo pato pco ro to po chebi

# ----------------------------------------
# TOP LEVEL TARGET
# ----------------------------------------
all: align_all
setup: sweet owltools

# ----------------------------------------
# INPUT FILES
# ----------------------------------------
# Currently we get OBOs via ontobio, no need to download.
# For sweet we build a json file. This requires the sweet
# repo as AFAICT complete import chain not available via
# web yet

# clone sweet into this repo.
# you can place this anywhere and symlink if you prefer
sweet:
	git clone https://github.com/ESIPFed/sweet.git

# use owltools to convert
sweet.json:
	owltools --catalog-xml $(CAT) $(SRC) --merge-imports-closure -o -f json $@
.PRECIOUS: sweet.json

align_all: $(patsubst %,align-sweet-obo-%.tsv,$(ONTS))

align-sweet-obo-%.tsv: sweet.json
	ontobio-lexmap.py -vvv -c conf.yaml -l True $< $*  > $@.tmp && cut -f2-999 $@.tmp > $@

owltools:
	curl -L http://build.berkeleybop.org/userContent/owltools/owltools -o $@ && chmod +x $@

