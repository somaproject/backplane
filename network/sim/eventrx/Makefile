VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/_networkstack.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/eventrxbusoutput/_behavioral.var: ../../vhdl/eventrxbusoutput.vhd
	$(VHDLC) ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/_behavioral.var: ../../vhdl/eventrxresponsewr.vhd
	$(VHDLC) ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/_behavioral.var: ../../vhdl/eventrx.vhd
	$(VHDLC) ../../vhdl/eventrx.vhd

hw: $(WORKDIR)/networkstack/_networkstack.var $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var 

comp: 

$(WORKDIR)/eventrxtest/_behavioral.var: eventrxtest.vhd
	$(VHDLC) eventrxtest.vhd

sim: $(WORKDIR)/eventrxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventrxtest


clean:
	rm -Rf $(WORKDIR)$

