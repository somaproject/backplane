VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/byteio/_behavioral.var: ../../vhdl/somabackplane.vhd ../../boot/vhdl/byteio.vhd
	$(VHDLC) ../../boot/vhdl/byteio.vhd

$(WORKDIR)/mmcio/_behavioral.var: ../../vhdl/somabackplane.vhd ../../boot/vhdl/byteio.vhd ../../boot/vhdl/mmcio.vhd
	$(VHDLC) ../../boot/vhdl/mmcio.vhd

$(WORKDIR)/bootserialize/_behavioral.var: ../../vhdl/somabackplane.vhd ../../boot/vhdl/byteio.vhd ../../boot/vhdl/mmcio.vhd ../../vhdl/bootserialize.vhd
	$(VHDLC) ../../vhdl/bootserialize.vhd

$(WORKDIR)/mmcfpgaboot/_behavioral.var: ../../vhdl/somabackplane.vhd ../../boot/vhdl/byteio.vhd ../../boot/vhdl/mmcio.vhd ../../vhdl/bootserialize.vhd ../../vhdl/mmcfpgaboot.vhd
	$(VHDLC) ../../vhdl/mmcfpgaboot.vhd

$(WORKDIR)/bootdeserialize/_behavioral.var: ../../vhdl/somabackplane.vhd ../../boot/vhdl/byteio.vhd ../../boot/vhdl/mmcio.vhd ../../vhdl/bootserialize.vhd ../../vhdl/mmcfpgaboot.vhd ../../sim/components/bootdeser/bootdeserialize.vhd
	$(VHDLC) ../../sim/components/bootdeser/bootdeserialize.vhd

$(WORKDIR)/mmc/_behavioral.var: ../../vhdl/somabackplane.vhd ../../boot/vhdl/byteio.vhd ../../boot/vhdl/mmcio.vhd ../../vhdl/bootserialize.vhd ../../vhdl/mmcfpgaboot.vhd ../../sim/components/bootdeser/bootdeserialize.vhd ../../boot/sim/components/mmc/mmc.vhd
	$(VHDLC) ../../boot/sim/components/mmc/mmc.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/byteio/_behavioral.var $(WORKDIR)/mmcio/_behavioral.var $(WORKDIR)/bootserialize/_behavioral.var $(WORKDIR)/mmcfpgaboot/_behavioral.var $(WORKDIR)/bootdeserialize/_behavioral.var $(WORKDIR)/mmc/_behavioral.var 

comp: 

$(WORKDIR)/simplefpga/_behavioral.var: simplefpga.vhd
	$(VHDLC) simplefpga.vhd

$(WORKDIR)/mmcfpgaboottest/_behavioral.var: simplefpga.vhd mmcfpgaboottest.vhd
	$(VHDLC) mmcfpgaboottest.vhd

sim: $(WORKDIR)/simplefpga/_behavioral.var $(WORKDIR)/mmcfpgaboottest/_behavioral.var 
runsim: all
	$(VHDLS) mmcfpgaboottest


clean:
	rm -Rf $(WORKDIR)$

