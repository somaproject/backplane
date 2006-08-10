VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/memtest/_behavioral.var: ../vhdl/memtest.vhd
	$(VHDLC) ../vhdl/memtest.vhd

hw: $(WORKDIR)/memtest/_behavioral.var 

comp: 

$(WORKDIR)/memtesttest/_behavioral.var: memtesttest.vhd
	$(VHDLC) memtesttest.vhd

sim: $(WORKDIR)/memtesttest/_behavioral.var 
runsim: all
	$(VHDLS) memtesttest


clean:
	rm -Rf $(WORKDIR)$

