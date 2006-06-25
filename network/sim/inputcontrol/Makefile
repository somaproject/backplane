VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

hw: $(WORKDIR)/inputcontrol/_behavioral.var 

comp: 

$(WORKDIR)/inputcontroltest/_behavioral.var: inputcontroltest.vhd
	$(VHDLC) inputcontroltest.vhd

sim: $(WORKDIR)/inputcontroltest/_behavioral.var 
runsim: all
	$(VHDLS) inputcontrol


clean:
	rm -Rf $(WORKDIR)$

