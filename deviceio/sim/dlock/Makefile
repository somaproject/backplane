VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dlock/_behavioral.var: ../../rx.vhdl/dlock.vhd
	$(VHDLC) ../../rx.vhdl/dlock.vhd

hw: $(WORKDIR)/dlock/_behavioral.var 

comp: 

$(WORKDIR)/dlocktest/_behavior.var: dlocktest.vhd
	$(VHDLC) dlocktest.vhd

sim: $(WORKDIR)/dlocktest/_behavior.var 
runsim: all
	$(VHDLS) dlocktest.vhd


clean:
	rm -Rf $(WORKDIR)$

