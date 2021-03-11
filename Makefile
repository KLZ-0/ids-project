TARGET = ids

.PHONY: all pack clean

all: $(TARGET).pdf

$(TARGET).pdf: $(TARGET).tex
	pdflatex $<

clean:
	rm -f $(TARGET){.dvi,.aux,.log,.out.ps,.ps,.pdf}
