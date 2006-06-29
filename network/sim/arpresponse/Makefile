VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/arpresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/arpresponse.vhd
	$(VHDLC) ../../vhdl/arpresponse.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/arpresponse/_behavioral.var 

comp: 

$(WORKDIR)/arpresponsetest/_behavioral.var: arpresponsetest.vhd
	$(VHDLC) arpresponsetest.vhd

sim: $(WORKDIR)/arpresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) arpresponsetest


clean:
	rm -Rf $(WORKDIR)$

