# Alignment between SWEET and OBOs

__ALPHA__ DO NOT TRUST THE RESULTS HERE YET

This repo contains a pipeline and results for aligning the various ESIP SWEET ontologies with OBOs.

Currently this is automated but the goal is to learn from a seed of initial curated equivalence axioms using kboom.

## Running the pipeline

```
make setup
. env.sh
mv catalog-v001.xml sweet/src/
make
```

On subsequent runs, you do not need `make setup`. This clones SWEET into this repo and downloads owltools.

In the same terminal session you only need to do `. env.sh` once

## Results

Each file is the export of a python dataframe with a mapping and a variety of scores and information. Consult ontobio docs for explanation (TODO)

Note that at this stage it is expected the results include false positives, e.g:

```
http://sweetontology.net/realmCryo#Calf,,UBERON:0003823,hindlimb zeugopod
```

clearly an ice calf is not the same as the "calf" of your leg. We will add high level axioms as 'training' and iterate improving results

## Methods

We use ontobio-lexmap

sweet classes typically do not have rdfs:labels (some do). We take the
URI fragment and split the camel case to generate tokenized labels for
each class (this is done automatically by lexmap.py).

Note that sweet classes do not have synonyms - instead sweet has
equivalence axioms linking two concepts deemed identical. This is in
contrast to OBOs, where we would merge equivalent classes and make the
label from one be a synonym of the other.

When attempting to map, we treat each sweet class as distinct, even if
they are connected by equivalence axioms. We opt not to do a
pre-merging step. This means that we will have some apparent false
negatives, but these will be incorporated at the reasoning stage.

