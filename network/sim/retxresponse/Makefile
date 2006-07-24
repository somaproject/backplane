VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/retxresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/retxresponse.vhd
	$(VHDLC) ../../vhdl/retxresponse.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/retxresponse/_behavioral.var 

comp: 

$(WORKDIR)/retxresponsetest/_behavioral.var: retxresponsetest.vhd
	$(VHDLC) retxresponsetest.vhd

sim: $(WORKDIR)/retxresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) retxresponsetest.vhd


clean:
	rm -Rf $(WORKDIR)$

