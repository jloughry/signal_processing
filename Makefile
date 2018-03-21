target := $(basename $(shell ls -b *paper.tex | head -1 \
    | sed -e "/_paper.tex/s///"))

paper_target = $(target)_paper
slides_target = $(target)_slides

documentation = README.md

paper_source = $(paper_target).tex
slides_source = $(slides_target).tex
latex_cmd = pdflatex
editor = vi

dvi_options = --output-format dvi

paper_counter_file = paper_build_counter.txt
slides_counter_file = slides_build_counter.txt

paper_pdf_file = $(paper_target).pdf
paper_dvi_file = $(paper_target).dvi
slides_pdf_file = $(slides_target).pdf

title = title.tex
abstract = abstract.tex

paper_sources = $(paper_source) $(bibtex_file) $(abstract) $(title)
slides_sources = $(slides_source)
graphics_dir = ./graphics

temporary_files = *.log *.aux *.out *.idx *.ilg *.bbl *.blg .pdf *.nav *.snm *.toc

all:: $(paper_pdf_file) $(slides_pdf_file)

Makefile: common.mk

common.mk:
	ln -s ../Makefiles/common.mk

graphics_for_paper =

graphics_for_slides =

$(paper_pdf_file): $(paper_sources) $(graphics_for_paper) Makefile
	@echo $$(($$(cat $(paper_counter_file)) + 1)) > $(paper_counter_file)
	make $(bibtex_file)
	$(latex_cmd) $(paper_source)
	bibtex $(paper_target)
	if (grep "Warning" $(paper_target).blg > /dev/null ) then false; fi
	@while grep "Rerun to get" $(paper_target).log ; do \
		$(latex_cmd) $(paper_target) ; \
	done
	chmod a-x,a+r $(paper_pdf_file)
	@echo "Build `cat $(paper_counter_file)`"

$(slides_pdf_file): $(slides_sources) $(graphics_for_slides) Makefile
	@echo $$(($$(cat $(slides_counter_file)) + 1)) > $(slides_counter_file)
	$(latex_cmd) $(slides_target)
	@while grep "Rerun to get" $(slides_target).log ; do \
		$(latex_cmd) $(slides_target) ; \
	done
	@echo "Build `cat $(slides_counter_file)`"
	chmod a-x,a+r $(slides_pdf_file)

title:
	$(editor) $(title)

abstract:
	$(editor) $(abstract)

vi: paper

paper:
	$(editor) $(paper_source)

slides:
	$(editor) $(slides_source)

spell::
	aspell --lang=en_GB check $(abstract)
	aspell --lang=en_GB check $(paper_source)
	aspell --lang=en_GB check $(slides_source)

wc:
	wc -w $(abstract)

clean::
	rm -vf $(temporary_files)

allclean: clean
	rm -vf $(paper_pdf_file) $(paper_dvi_file) $(slides_pdf_file)

include common.mk

