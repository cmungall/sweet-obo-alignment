## Makefile for building alignment tsvs
## Please consult README.md

# ----------------------------------------
# CONSTANTS
# ----------------------------------------
SWEET_REPO = sweet
CAT = $(SWEET_REPO)/catalog-v001.xml
SRC = $(SWEET_REPO)/sweetAll.ttl

# ontology list (OBO IDs)
# To find out more about each ontology see obofoundry.org
# E.g. http://obofoundry.org/ontology/envo.html
# TODO: ecocore
ONTS = envo pato pco ro to po chebi go obi fao fix iao mop stato uo
ONTS_R = $(patsubst %,obo:%,$(ONTS))

VERBOSE = -v

# ----------------------------------------
# TOP LEVEL TARGET
# ----------------------------------------
all: align_all
setup: sweet owltools
clean:
	rm *.tsv
realclean: clean
	rm sweet.json

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

sweet.obo:
	owltools --catalog-xml $(CAT) $(SRC) --merge-imports-closure -o -f obo --no-check $@
.PRECIOUS: sweet.obo

# ----------------------------------------
# Alignment
# ----------------------------------------

align_all: $(patsubst %,align-sweet-obo-%.tsv,$(ONTS))

CONF = -c conf.yaml -X curated.csv

# use ontobio-lexmap
# filter results for ontology of interest
align-sweet-obo-%.tsv: sweet.json
	ontobio-lexmap.py $(VERBOSE) $(CONF) -u unmapped-$*.tsv $< $*  > $@.tmp && mv $@.tmp $@

align-sweet-obo-ALL.tsv: sweet.json
	ontobio-lexmap.py $(VERBOSE) $(CONF) -u unmapped-ALL.tsv $< $(ONTS) > $@.tmp && mv $@.tmp $@ && grep sweetontology.net unmapped-ALL.tsv | sort -u > sweet-unmatched.tsv

align-sweet-obo-%.obo: sweet.json
	ontobio-lexmap.py $(VERBOSE) $(CONF) -t obo $< $*  > $@.tmp && mv $@.tmp $@

owltools:
	curl -L http://build.berkeleybop.org/userContent/owltools/owltools -o $@ && chmod +x $@

align-sweet-odm.tsv:
	rdfmatch -f tsv -l -G $@.rdf  -A ~/repos/onto-mirror/void.ttl -i obo_prefixes -i sweet -i odm new_match > $@

# ----------------------------------------
# kBOOM
# ----------------------------------------
ptable.csv: align-sweet-obo-ALL.tsv
	cat $< | p.df  'df[["left", "right","pr_subClassOf","pr_superClassOf","pr_equivalentTo","pr_other"]]' -o csv -i tsv | grep -v '^"left' > $@
ptable.tsv: ptable.csv
	csv2tsv.py $< $@

all-%.obo:
	ogr --resources sweet.json $* -t obo % > $@
all-%.owl: all-%.obo
	owltools $< -o $@
#all.owl: $(OBOS)
#	owltools $^ --merge-support-ontologies -o $@

axioms-%.owl: ptable.tsv all-%.owl 
	kboom --experimental  --splitSize 50 --max 9 -m linked-$*-rpt.md -j linked-$*-rpt.json -n -o $@ -t $^

