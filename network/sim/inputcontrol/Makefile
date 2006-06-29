VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/inputcontrol/_behavioral.var 

comp: 

$(WORKDIR)/inputcontroltest/_behavioral.var: inputcontroltest.vhd
	$(VHDLC) inputcontroltest.vhd

sim: $(WORKDIR)/inputcontroltest/_behavioral.var 
runsim: all
	$(VHDLS) inputcontrol


clean:
	rm -Rf $(WORKDIR)$

