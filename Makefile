# This file is part of CWEB-in-Go.
# It is distributed WITHOUT ANY WARRANTY, express or implied.
# Version 0.1 --- Marth 2012

# Copyright (C) 2012 Alexander Sychev

# Permission is granted to make and distribute verbatim copies of this
# document provided that the copyright notice and this permission notice
# are preserved on all copies.

# Permission is granted to copy and distribute modified versions of this
# document under the conditions for verbatim copying, provided that the
# entire resulting derived work is given a different name and distributed
# under the terms of a permission notice identical to this one.

# 
# Read the README file, then edit this file to reflect local conditions
#

# 
# Read the README file, then edit this file to reflect local conditions
#

# directory for TeX inputs (cwebmac.tex goes here)
MACROSDIR= /usr/share/texmf/tex/generic

# directory for CWEB inputs in @i files
CWEBINPUTS= /usr/local/lib/cweb

# extension for manual pages ("l" distinguishes local from system stuff)
MANEXT= l
#MANEXT= 1

# directory for manual pages (cweb.1 goes here)
MANDIR= /usr/share/man/man$(MANEXT)

# destination directory for executables; must end in /
DESTDIR= /usr/local/bin/

# directory for GNU EMACS Lisp code (cweb.el goes here)
EMACSDIR= /usr/share/emacs/site-lisp

# Set DESTPREF to null if you want to call the executables "tangle" and "weave"
# (probably NOT a good idea; we recommend leaving DESTPREF=c)
DESTPREF=c

# Set CCHANGES to comm-foo.ch if you need changes to common.w
CCHANGES=

# Set TCHANGES to ctang-foo.ch if you need changes to ctangle.w
TCHANGES=

# Set WCHANGES to cweav-foo.ch if you need changes to cweave.w
WCHANGES=

# RM and CP are used below in case rm and cp are aliased
RM= /bin/rm
CP= /bin/cp

# uncomment the second line if you use pdftex to bypass .dvi files
PDFTEX = dvipdfm
#PDFTEX = pdftex

##########  You shouldn't have to change anything after this point #######

CWEAVE = cweave/cweave
CTANGLE = ctangle/ctangle
SOURCES = cweave.w common.w ctangle.w
ALL =  common.w ctangle.w cweave.w prod.w \
	Makefile ctangle/ctangle.go \
	cwebman.tex cwebmac.tex \
	comm-man.ch ctang-man.ch cweav-man.ch \
	cweb.1 cweb.el c++lib.w README

.SUFFIXES: .dvi .tex .w .pdf

.w.tex:  $(CWEAVE)
	$(CWEAVE) $*

.tex.dvi:.tex
	tex $<

.w.dvi: .tex
	make $*.tex
	make $*.dvi

.w.pdf:
	make $*.tex
	case "$(PDFTEX)" in \
	 dvipdfm ) tex "\let\pdf+ \input $*"; dvipdfm $* ;; \
	 pdftex ) pdftex $* ;; \
	esac

all: $(CTANGLE) $(CWEAVE)

cautiously: ctangle
	$(CP) ctangle/ctangle.go ctangle/ctangle.go.backup
	$(CTANGLE) ctangle $(TCHANGES)
	diff ctangle.go SAVEctangle.go
	$(RM) SAVEctangle.go

doc: $(SOURCES:.w=.dvi)

usermanual: cwebman.tex cwebmac.tex
	tex cwebman

fullmanual: usermanual $(SOURCES) comm-man.ch ctang-man.ch cweav-man.ch
	make cweave
	$(CWEAVE) common.w comm-man.ch
	tex common.tex
	$(CWEAVE) ctangle.w ctang-man.ch
	tex ctangle.tex
	$(CWEAVE) cweave.w cweav-man.ch
	tex cweave.tex

# be sure to leave ctangle.c and common.c for bootstrapping
clean:
	$(RM) -f -r *~ *.o common.tex cweave.tex cweave.c ctangle.tex \
	  *.log *.dvi *.toc *.idx *.scn *.pdf core cweave ctangle

install: all
	- mkdir $(DESTDIR)
	$(CP) $(CWEAVE) $(DESTDIR)$(DESTPREF)weave
	chmod 755 $(DESTDIR)$(DESTPREF)weave
	$(CP) $(CTANGLE) $(DESTDIR)$(DESTPREF)tangle
	chmod 755 $(DESTDIR)$(DESTPREF)tangle
	- mkdir $(MANDIR)
	$(CP) cweb.1 $(MANDIR)/cweb.$(MANEXT)
	chmod 644 $(MANDIR)/cweb.$(MANEXT)
	- mkdir $(MACROSDIR)
	$(CP) cwebmac.tex $(MACROSDIR)
	chmod 644 $(MACROSDIR)/cwebmac.tex
	- mkdir $(EMACSDIR)
	$(CP) cweb.el $(EMACSDIR)
	chmod 644 $(EMACSDIR)/cweb.el
	- mkdir $(CWEBINPUTS)
	$(CP) c++lib.w $(CWEBINPUTS)
	chmod 644 $(CWEBINPUTS)/c++lib.w

tarfile: $(ALL) examples
	tar czvhf /tmp/cweb.tar.gz $(ALL) examples

$(CTANGLE): ctangle/ctangle.go
	(cd ctangle;go build)

$(CWEAVE): cweave/cweave.go
	(cd cweave;go build)

ctangle/ctangle.go: ctangle.w common.w
	-mkdir ctangle
	ctangle ctangle.w - $@
	sed -i 's:\#line\ \([0-9]*\) \"\([^"]*\)\"://line \2\:\1:g' $@

cweave/cweave.go: cweave.w common.w
	-mkdir cweave
	ctangle cweave.w - $@
	sed -i 's:\#line\ \([0-9]*\) \"\([^"]*\)\"://line \2\:\1:g' $@
