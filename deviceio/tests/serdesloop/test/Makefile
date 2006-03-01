VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/serdesloop/_behavioral.var: ../vhdl/serdesloop.vhd
	$(VHDLC) ../vhdl/serdesloop.vhd

hw: $(WORKDIR)/serdesloop/_behavioral.var 

comp: 

$(WORKDIR)/serdeslooptest/_behavioral.var: serdeslooptest.vhd
	$(VHDLC) serdeslooptest.vhd

sim: $(WORKDIR)/serdeslooptest/_behavioral.var 
runsim: all
	$(VHDLS) serdeslooptest


clean:
	rm -Rf $(WORKDIR)$

