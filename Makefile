# Makefile for VHDL Language
# Compiler: GHDL
# Wave Analysis: gtk-wave

CC=ghdl
CFLAGS=
ANALYSIS=gtkwave

# You should change source name, executable name and testunit name

SOURCES=constants.vhd memory.vhd cache.vhd bus.vhd cpu.vhd mips.vhd tb_mips.vhd
OBJECTS=$(SOURCES:.vhd=.o)
EXECUTABLE=$(TESTUNIT)
TESTUNIT=tb_mips
TESTUNITFILE=$(TESTUNIT).vcd

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) -r $(TESTUNIT) --vcd=$(TESTUNIT).vcd --stop-time=5000ns

$(OBJECTS): $(SOURCES)
	$(CC) -a --ieee=synopsys $(SOURCES)
	$(CC) -e --ieee=synopsys $(TESTUNIT)

wave:
	# If you use gtk-wave.app, use line below
	# open $(TESTUNIT).vcd
	$(ANALYSIS) $(TESTUNIT).vcd &

clean:
	rm -rf *.o $(TESTUNITFILE) $(TESTUNIT) work-obj93.cf
