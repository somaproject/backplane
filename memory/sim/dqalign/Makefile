VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../vhdl/dqalign.vhd
	$(VHDLC) ../../vhdl/dqalign.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var 

comp: 

$(WORKDIR)/dqaligntest/_behavioral.var: dqaligntest.vhd
	$(VHDLC) dqaligntest.vhd

sim: $(WORKDIR)/dqaligntest/_behavioral.var 
runsim: all
	$(VHDLS) dqaligntest


clean:
	rm -Rf $(WORKDIR)$

