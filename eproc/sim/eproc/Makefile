VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../../backplane/vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../../backplane/vhdl/somabackplane.vhd

$(WORKDIR)/alu/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd
	$(VHDLC) -vital2000 ../../vhdl/alu.vhd

$(WORKDIR)/regfile/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd
	$(VHDLC) -vital2000 ../../vhdl/regfile.vhd

$(WORKDIR)/ecore/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd
	$(VHDLC) -vital2000 ../../vhdl/ecore.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventtx.vhd

$(WORKDIR)/evtdnd/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd ../../vhdl/evtdnd.vhd
	$(VHDLC) -vital2000 ../../vhdl/evtdnd.vhd

$(WORKDIR)/txeventbuffer/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd ../../vhdl/evtdnd.vhd ../../vhdl/txeventbuffer.vhd
	$(VHDLC) -vital2000 ../../vhdl/txeventbuffer.vhd

$(WORKDIR)/eproc/_behavioral.var: ../../../backplane/vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd ../../vhdl/evtdnd.vhd ../../vhdl/txeventbuffer.vhd ../../vhdl/eproc.vhd
	$(VHDLC) -vital2000 ../../vhdl/eproc.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/alu/_behavioral.var $(WORKDIR)/regfile/_behavioral.var $(WORKDIR)/ecore/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/evtdnd/_behavioral.var $(WORKDIR)/txeventbuffer/_behavioral.var $(WORKDIR)/eproc/_behavioral.var 

$(WORKDIR)/iram/_behavioral.var: ../components/iram/iram.vhd
	$(VHDLC) -vital2000 ../components/iram/iram.vhd

comp: $(WORKDIR)/iram/_behavioral.var 

$(WORKDIR)/eproctest/_behavioral.var: ../components/iram/iram.vhd eproctest.vhd
	$(VHDLC) -vital2000 eproctest.vhd

sim: $(WORKDIR)/eproctest/_behavioral.var 
runsim: all
	$(VHDLS) eproctest


clean:
	rm -Rf *.sym

