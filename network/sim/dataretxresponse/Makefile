VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/dataretxresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/dataretxresponse.vhd
	$(VHDLC) ../../vhdl/dataretxresponse.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/dataretxresponse/_behavioral.var 

comp: 

$(WORKDIR)/dataretxresponsetest/_behavioral.var: dataretxresponsetest.vhd
	$(VHDLC) dataretxresponsetest.vhd

sim: $(WORKDIR)/dataretxresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) dataretxresponsetest.vhd


clean:
	rm -Rf $(WORKDIR)$

