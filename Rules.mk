all :: unittest

PERL ?= /usr/bin/perl
INST_LIB = lib/
CORE_LIB = ../backend-core/lib/
PERL_LIB_DIRS = $(patsubst %,../%/lib/ ../%/t/lib,$(DEPENDENCIES))
PERL_INCLUDES = -I $(INST_LIB) -I $(NIKE_HOME)/lib $(patsubst %,-I %,$(PERL_LIB_DIRS))
FULLPERLRUN = $(PERL) $(PERL_INCLUDES)

# work only on files, where string 'Test::Doctest' is used
TEST_FILES = $(shell find lib -name "*.pm" | xargs grep -l Test::Doctest | xargs grep -h -E '^package ' | perl -pe 's/^package\s+(.*?);.*/\$\1/g' | sort)

ALL_PERL_SCRIPTS = $(shell find bin lib t -name '*.pl' -o -name '*.t' | sort)
ALL_PERL_MODULES = $(shell find bin lib t -name '*.pm' | sort)
ALL_PERL_FILES = $(ALL_PERL_MODULES) $(ALL_PERL_SCRIPTS)

PROVE := $(shell command -v prove 2> /dev/null)
COVER := $(shell command -v cover 2> /dev/null)
# Workaround for /usr/bin/prove342 vs /usr/bin/cover
ifndef PROVE
PROVE := $(shell command -v prove342 2> /dev/null)
endif

unittest: check podchecker prove
        PERL_DL_NONLAZY=1 $(FULLPERLRUN) -MTest::Doctest -e run $(TEST_FILES) 2>&1 | grep -v -E '^Subroutine .*? redefined'

prove:
ifndef PROVE
	$(error "prove is not available")
endif
	$(PROVE) -r t/

cover:
ifndef COVER
	$(error "cover is not available, please install perl-Devel-Cover:   sudo yum install perl-Devel-Cover || sudo apt-get install libdevel-cover-perl")
endif
	$(COVER) -t +ignore '^/'

#check pod syntax - if problems exist, some Doctests won't be executed
podchecker:
	-@find lib bin \( -name '*.pl' -o -name '*.pm' -o -name '*.t' \) \
		| xargs grep -l "^=" \
		| xargs podchecker --warnings 2>&1 \
		| perl -n -e 'BEGIN { my $$rc = 0 }; if ($$_ !~ /pod syntax OK\.$$/) { $$rc = 1 ; print $$_; } END { exit $$rc };' # XXX: grep returns wrong exit code: "| grep -v -e 'pod syntax OK\.$$'"

check:
	@for f in $(ALL_PERL_MODULES); do $(FULLPERLRUN) -c $$f; done
	@for f in $(ALL_PERL_SCRIPTS); do $(PERL) -c $$f; done
