VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/byteio/_behavioral.var: ../../boot/vhdl/byteio.vhd
	$(VHDLC) ../../boot/vhdl/byteio.vhd

$(WORKDIR)/mmcio/_behavioral.var: ../../boot/vhdl/mmcio.vhd
	$(VHDLC) ../../boot/vhdl/mmcio.vhd

$(WORKDIR)/bootserialize/_behavioral.var: ../../vhdl/bootserialize.vhd
	$(VHDLC) ../../vhdl/bootserialize.vhd

$(WORKDIR)/mmcfpgaboot/_behavioral.var: ../../vhdl/mmcfpgaboot.vhd
	$(VHDLC) ../../vhdl/mmcfpgaboot.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/rxeventfifo.vhd
	$(VHDLC) ../../vhdl/rxeventfifo.vhd

$(WORKDIR)/boot/_behavioral.var: ../../vhdl/boot.vhd
	$(VHDLC) ../../vhdl/boot.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/byteio/_behavioral.var $(WORKDIR)/mmcio/_behavioral.var $(WORKDIR)/bootserialize/_behavioral.var $(WORKDIR)/mmcfpgaboot/_behavioral.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/boot/_behavioral.var 

comp: 

$(WORKDIR)/boottest/_behavioral.var: boottest.vhd
	$(VHDLC) boottest.vhd

sim: $(WORKDIR)/boottest/_behavioral.var 
runsim: all
	$(VHDLS) boottest


clean:
	rm -Rf $(WORKDIR)$

