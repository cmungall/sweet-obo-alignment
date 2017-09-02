SWEET_REPO = sweet
CAT = $(SWEET_REPO)/catalog-v001.xml
SRC = $(SWEET_REPO)/sweetAll.ttl

ONTS = envo pato pco ro chebi

all: align_all

sweet.json:
	owltools --catalog-xml $(CAT) $(SRC) --merge-imports-closure -o -f json $@
.PRECIOUS: sweet.json

align_all: $(patsubst %,align-sweet-obo-%.tsv,$(ONTS))

align-sweet-obo-%.tsv: sweet.json
	ontobio-lexmap.py -vvv -c conf.yaml -l True $< $*  > $@.tmp && cut -f2-999 $@.tmp > $@

setup: fetch-sweet

# clone sweet into this repo.
# you can place this anywhere and symlink if you prefer
fetch-sweet:
	git clone https://github.com/ESIPFed/sweet.git
