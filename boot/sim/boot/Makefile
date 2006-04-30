VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/xilinxcfg/_behavioral.var: ../../cpld/xilinxcfg.vhd
	$(VHDLC) ../../cpld/xilinxcfg.vhd

$(WORKDIR)/boot/_behavioral.var: ../../cpld/boot.vhd
	$(VHDLC) ../../cpld/boot.vhd

$(WORKDIR)/byteio/_behavioral.var: ../../vhdl/byteio.vhd
	$(VHDLC) ../../vhdl/byteio.vhd

$(WORKDIR)/mmcio/_behavioral.var: ../../vhdl/mmcio.vhd
	$(VHDLC) ../../vhdl/mmcio.vhd

hw: $(WORKDIR)/xilinxcfg/_behavioral.var $(WORKDIR)/boot/_behavioral.var $(WORKDIR)/byteio/_behavioral.var $(WORKDIR)/mmcio/_behavioral.var 

$(WORKDIR)/mmc/_behavioral.var: ../components/mmc/mmc.vhd
	$(VHDLC) ../components/mmc/mmc.vhd

comp: $(WORKDIR)/mmc/_behavioral.var 

$(WORKDIR)/boottest/_behavioral.var: boottest.vhd
	$(VHDLC) boottest.vhd

sim: $(WORKDIR)/boottest/_behavioral.var 
runsim: all
	$(VHDLS) boottest


clean:
	rm -Rf $(WORKDIR)$

