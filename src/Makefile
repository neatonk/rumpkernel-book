
PAPER=	rumpkernel
DATE:=	$(shell git show -s --format="%ci" HEAD | sed 's/-//g;s/ .*//')
TARGET=	${PAPER}-bookv2-${DATE}

SUBS=	introduction.tex
SUBS+=	concept.tex
SUBS+=	implementation.tex
SUBS+=	ecosystem.tex
SUBS+=	history.tex
SUBS+=	conclusions.tex

IMGS=	$(basename $(notdir $(wildcard figures/*.pdf)))

all: pdf

imgs:
	mkdir -p imgs

# these *must* contain .pdf, otherwise latex can't find the files
.PHONY: imgs.pdf
imgs.pdf: imgs
	( cd imgs && for p in ${IMGS} ; do \
		ln -sf ../figures/$${p}.pdf . ; \
	done )

# these *must not* contain .png, otherwise pandoc can't find the files
.PHONY: imgs.png
imgs.png: imgs
	for p in ${IMGS} ; do \
		convert figures/$${p}.pdf imgs/$${p} ; \
	done

inputs.tex: ${SUBS}
	rm -f inputs.tex
	for s in ${SUBS}; do \
		echo \\input{$${s}} >> $@ ; \
	done

.PHONY: rev.tex
rev.tex:
	printf '\\begin{verbatim}\n' > rev.tex
	printf 'Build information\n' >> rev.tex
	printf 'Revision: ' >> rev.tex
	git rev-parse HEAD >> rev.tex
	printf 'Date:     %s\n' ${DATE} >> rev.tex
	printf '\\end{verbatim}\n' >> rev.tex

pdf: ${PAPER}.tex thebibs.bib inputs.tex rev.tex imgs.pdf
	rm -f ${PAPER}.pdf

	pdflatex ${PAPER}.tex
	bibtex ${PAPER}
	makeindex ${PAPER}.nlo -s nomencl.ist -o ${PAPER}.nls
	pdflatex ${PAPER}.tex
	mv ${PAPER}.pdf ${TARGET}.pdf

epub: ${PAPER}.tex thebibs.bib inputs.tex rev.tex imgs.png
	pandoc -S -o ${TARGET}.epub \
	    --epub-cover-image=cover6.png \
	    --epub-metadata=metadata \
	    --natbib --bibliography=thebibs.bib \
	    --citation-abbreviations=abbr.tex \
	    ${PAPER}.tex

clean:
	rm -f dummy *aux *bbl *blg *dvi *log *.ps *lof *lot *.toc *.ilg *.nls *.nlo ${PAPER}-*.pdf *.mof inputs.tex rev.tex ${PAPER}.out *.epub
	rm -rf imgs

cleandir: clean
