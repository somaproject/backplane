VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/alu/_behavioral.var: ../../vhdl/alu.vhd
	$(VHDLC) -vital2000 ../../vhdl/alu.vhd

$(WORKDIR)/regfile/_behavioral.var: ../../vhdl/alu.vhd ../../vhdl/regfile.vhd
	$(VHDLC) -vital2000 ../../vhdl/regfile.vhd

$(WORKDIR)/ecore/_behavioral.var: ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd
	$(VHDLC) -vital2000 ../../vhdl/ecore.vhd

hw: $(WORKDIR)/alu/_behavioral.var $(WORKDIR)/regfile/_behavioral.var $(WORKDIR)/ecore/_behavioral.var 

$(WORKDIR)/iram/_behavioral.var: ../components/iram/iram.vhd
	$(VHDLC) -vital2000 ../components/iram/iram.vhd

$(WORKDIR)/outverify/_behavioral.var: ../components/iram/iram.vhd ../components/outverify/outverify.vhd
	$(VHDLC) -vital2000 ../components/outverify/outverify.vhd

comp: $(WORKDIR)/iram/_behavioral.var $(WORKDIR)/outverify/_behavioral.var 

$(WORKDIR)/jumptest/_behavioral.var: ../components/iram/iram.vhd ../components/outverify/outverify.vhd jumptest.vhd
	$(VHDLC) -vital2000 jumptest.vhd

sim: $(WORKDIR)/jumptest/_behavioral.var 
runsim: all
	$(VHDLS) jumptest


clean:
	rm -Rf *.sym

