DIRS=eval models parsed
MALT?=malt

# TODO
.PHONY: all clean

# This makes make keep intermediate files generated by wildcard rules when
# make exits. We actually want to keep intermediate files (like parser models)
# even if we instruct make to create the parsed file.
.SECONDARY:

all:

# Corpora munging:
## The first 90% of the corpus take up 97470 lines.
corpora/norwegian.conll: corpora/norwegian-full.conll
	head -n 97470 $< > $@

## Thus, the last 10% start on line 97471.
corpora/norwegian-test.conll: corpora/norwegian-full.conll
	tail -n +97471 $< > $@

%-preproc.conll: parsed/%-danish.conll parsed/%-norwegian.conll parsed/%-swedish.conll parsed/%-caterpillar.conll
	./scripts/merge-corpora.pl $^ > $@

# Training and parsing:
models/%.mco: corpora/%.conll | models
	cd models && $(MALT) -m learn -c $* -l liblinear -a nivreeager -i ../$<

parsed/%-danish.conll: corpora/%.conll models/danish.mco | parsed
	./scripts/single-root.pl <(cd models && $(MALT) -m parse -c danish -i ../$<) | awk -f scripts/no-nobj.awk > $@

parsed/%-norwegian.conll: corpora/%.conll models/norwegian.mco | parsed
	./scripts/single-root.pl <(cd models && $(MALT) -m parse -c norwegian -i ../$<) | awk -f scripts/no-nobj.awk > $@

parsed/%-swedish.conll: corpora/%.conll models/swedish.mco | parsed
	./scripts/single-root.pl <(cd models && $(MALT) -m parse -c swedish -i ../$<) | awk -f scripts/no-nobj.awk > $@

parsed/%-caterpillar.conll: scripts/make-caterpillar.awk corpora/%.conll | parsed
	awk -f $< corpora/$*.conll > $@

eval/caterpillar.conll: scripts/make-caterpillar.awk corpora/norwegian-test.conll | eval
	awk -f $< corpora/norwegian-test.conll > $@

eval/%.conll: corpora/norwegian-test.conll models/%.mco | eval
	./scripts/single-root.pl <(cd models && $(MALT) -m parse -c $* -i ../$<) | awk -f scripts/no-nobj.awk > $@

# Data synthesis:
%.dat: %-preproc.conll data/%.conll
	paste $^ | awk '/^#/ { print gensub(/^.+(caterpillar|danish|norwegian|swedish).+$$/, "\\1", "", $$2), $$4, $$5}' > $@

dagbladet_013-odin.dat: data/dagbladet_013-odin.conll dagbladet_013-preproc.conll
	paste $^ | head -n 6180 | \
		awk '/^#/ { print gensub(/^.+(caterpillar|danish|norwegian|swedish).+$$/, "\\1", "", $$5), $$2, $$3}' > $@

odin.dat: aftenposten_006.dat dagbladet_012.dat dagbladet_013-odin.dat
	cat $^ | sort -k 1 | awk 'prev != $$1 { if(prev) print "\n"; prev = $$1 } {print}' > $@

thor.dat: aftenposten_008.dat dagbladet_013.dat
	cat $^ | sort -k 1 | awk 'prev != $$1 { if(prev) print "\n"; prev = $$1 } {print}' > $@

medians-odin.dat medians-thor.dat: scripts/medians.r scripts/timingdata.r odin.dat thor.dat
	R --slave -f $<

# Utility stuff:
$(DIRS):
	mkdir $@

clean:
	rm -rf $(DIRS)
