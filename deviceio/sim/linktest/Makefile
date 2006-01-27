VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/ioclocks/_behavioral.var: ../../vhdl/ioclocks.vhd
	$(VHDLC) ../../vhdl/ioclocks.vhd

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: ../../vhdl/decode8b10b.vhd
	$(VHDLC) ../../vhdl/decode8b10b.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: ../../vhdl/encode8b10b.vhd
	$(VHDLC) ../../vhdl/encode8b10b.vhd

$(WORKDIR)/sample/_behavioral.var: ../../vhdl/sample.vhd
	$(VHDLC) ../../vhdl/sample.vhd

$(WORKDIR)/datamux/_behavioral.var: ../../vhdl/datamux.vhd
	$(VHDLC) ../../vhdl/datamux.vhd

$(WORKDIR)/dlock/_behavioral.var: ../../vhdl/dlock.vhd
	$(VHDLC) ../../vhdl/dlock.vhd

$(WORKDIR)/serialrx/_behavioral.var: ../../vhdl/serialrx.vhd
	$(VHDLC) ../../vhdl/serialrx.vhd

$(WORKDIR)/serialize/_behavioral.var: ../../vhdl/serialize.vhd
	$(VHDLC) ../../vhdl/serialize.vhd

$(WORKDIR)/serialtx/_behavioral.var: ../../vhdl/serialtx.vhd
	$(VHDLC) ../../vhdl/serialtx.vhd

$(WORKDIR)/linktest/_behavioral.var: ../../tests/linktest/vhdl/linktest.vhd
	$(VHDLC) ../../tests/linktest/vhdl/linktest.vhd

hw: $(WORKDIR)/ioclocks/_behavioral.var $(WORKDIR)/decode8b10b/_decode8b10b_a.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/sample/_behavioral.var $(WORKDIR)/datamux/_behavioral.var $(WORKDIR)/dlock/_behavioral.var $(WORKDIR)/serialrx/_behavioral.var $(WORKDIR)/serialize/_behavioral.var $(WORKDIR)/serialtx/_behavioral.var $(WORKDIR)/linktest/_behavioral.var 

comp: 

$(WORKDIR)/linktesttest/_behavior.var: linktesttest.vhd
	$(VHDLC) linktesttest.vhd

sim: $(WORKDIR)/linktesttest/_behavior.var 
runsim: all
	$(VHDLS) linktesttest


clean:
	rm -Rf $(WORKDIR)$

