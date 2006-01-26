VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/sample/_behavioral.var: ../../rx.vhdl/sample.vhd
	$(VHDLC) ../../rx.vhdl/sample.vhd

$(WORKDIR)/datamux/_behavioral.var: ../../rx.vhdl/datamux.vhd
	$(VHDLC) ../../rx.vhdl/datamux.vhd

$(WORKDIR)/recover/_behavioral.var: ../../tests/recover/recover.vhd
	$(VHDLC) ../../tests/recover/recover.vhd

hw: $(WORKDIR)/sample/_behavioral.var $(WORKDIR)/datamux/_behavioral.var $(WORKDIR)/recover/_behavioral.var 

comp: 

$(WORKDIR)/recovertest/_behavior.var: recovertest.vhd
	$(VHDLC) recovertest.vhd

sim: $(WORKDIR)/recovertest/_behavior.var 
runsim: all
	$(VHDLS) recovertest.vhd


clean:
	rm -Rf $(WORKDIR)$

