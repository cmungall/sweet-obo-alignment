# Alignment between SWEET and OBOs

This repo contains a pipeline and results for aligning the various ESIP SWEET ontologies with OBOs.

Currently this is automated but the goal is to learn from a seed of initial curated equivalence axioms using kboom

## Running the pipeline


```
make setup
. env.sh
make
```

On subsequent runs, you do not need `make setup`. This clones SWEET into this repo and downloads owltools.

In the same terminal session you only need to do `. env.sh` once

## Results

Each file is the export of a python dataframe with a mapping and a variety of scores and information. Consult ontobio docs for explanation (TODO)

