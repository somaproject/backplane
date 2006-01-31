VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/datatx/_behavioral.var: ../../vhdl/datatx.vhd
	$(VHDLC) ../../vhdl/datatx.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

$(WORKDIR)/devicetx/_behavioral.var: ../../vhdl/devicetx.vhd
	$(VHDLC) ../../vhdl/devicetx.vhd

hw: $(WORKDIR)/datatx/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/devicetx/_behavioral.var 

comp: 

$(WORKDIR)/devicetxtest/_behavior.var: devicetxtest.vhd
	$(VHDLC) devicetxtest.vhd

sim: $(WORKDIR)/devicetxtest/_behavior.var 
runsim: all
	$(VHDLS) devicetxtest


clean:
	rm -Rf $(WORKDIR)$

