VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd
	$(VHDLC) ../../../vhdl/rxeventfifo.vhd

$(WORKDIR)/byteio/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd
	$(VHDLC) ../../../boot/vhdl/byteio.vhd

$(WORKDIR)/mmcio/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd
	$(VHDLC) ../../../boot/vhdl/mmcio.vhd

$(WORKDIR)/bootdeser/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd
	$(VHDLC) ../../../deviceio/vhdl/bootdeser.vhd

$(WORKDIR)/bootserialize/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd
	$(VHDLC) ../../../vhdl/bootserialize.vhd

$(WORKDIR)/mmcfpgaboot/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd
	$(VHDLC) ../../../vhdl/mmcfpgaboot.vhd

$(WORKDIR)/bootcontrol/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd
	$(VHDLC) ../../../vhdl/bootcontrol.vhd

$(WORKDIR)/eventrouter/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd
	$(VHDLC) ../../../vhdl/core/eventrouter.vhd

$(WORKDIR)/timer/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd
	$(VHDLC) ../../../vhdl/timer.vhd

$(WORKDIR)/boot/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd
	$(VHDLC) ../../../vhdl/boot.vhd

$(WORKDIR)/jtagesend/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd
	$(VHDLC) ../../../jtag/vhdl/jtagesend.vhd

$(WORKDIR)/jtagereceive/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd
	$(VHDLC) ../../../jtag/vhdl/jtagereceive.vhd

$(WORKDIR)/nicserialio/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd ../../../vhdl/ether/nicserialio.vhd
	$(VHDLC) ../../../vhdl/ether/nicserialio.vhd

$(WORKDIR)/ethercontrol/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd ../../../vhdl/ether/nicserialio.vhd ../../../vhdl/ether/ethercontrol.vhd
	$(VHDLC) ../../../vhdl/ether/ethercontrol.vhd

$(WORKDIR)/ether/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd ../../../vhdl/ether/nicserialio.vhd ../../../vhdl/ether/ethercontrol.vhd ../../../vhdl/ether/ether.vhd
	$(VHDLC) ../../../vhdl/ether/ether.vhd

$(WORKDIR)/timer/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd ../../../vhdl/ether/nicserialio.vhd ../../../vhdl/ether/ethercontrol.vhd ../../../vhdl/ether/ether.vhd ../../../vhdl/timer.vhd
	$(VHDLC) ../../../vhdl/timer.vhd

$(WORKDIR)/syscontrol/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd ../../../vhdl/ether/nicserialio.vhd ../../../vhdl/ether/ethercontrol.vhd ../../../vhdl/ether/ether.vhd ../../../vhdl/timer.vhd ../../../vhdl/syscontrol.vhd
	$(VHDLC) ../../../vhdl/syscontrol.vhd

$(WORKDIR)/nettest/_behavioral.var: ../../../vhdl/somabackplane.vhd ../../../vhdl/rxeventfifo.vhd ../../../boot/vhdl/byteio.vhd ../../../boot/vhdl/mmcio.vhd ../../../deviceio/vhdl/bootdeser.vhd ../../../vhdl/bootserialize.vhd ../../../vhdl/mmcfpgaboot.vhd ../../../vhdl/bootcontrol.vhd ../../../vhdl/core/eventrouter.vhd ../../../vhdl/timer.vhd ../../../vhdl/boot.vhd ../../../jtag/vhdl/jtagesend.vhd ../../../jtag/vhdl/jtagereceive.vhd ../../../vhdl/ether/nicserialio.vhd ../../../vhdl/ether/ethercontrol.vhd ../../../vhdl/ether/ether.vhd ../../../vhdl/timer.vhd ../../../vhdl/syscontrol.vhd ../vhdl/nettest.vhd
	$(VHDLC) ../vhdl/nettest.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/byteio/_behavioral.var $(WORKDIR)/mmcio/_behavioral.var $(WORKDIR)/bootdeser/_behavioral.var $(WORKDIR)/bootserialize/_behavioral.var $(WORKDIR)/mmcfpgaboot/_behavioral.var $(WORKDIR)/bootcontrol/_behavioral.var $(WORKDIR)/eventrouter/_behavioral.var $(WORKDIR)/timer/_behavioral.var $(WORKDIR)/boot/_behavioral.var $(WORKDIR)/jtagesend/_behavioral.var $(WORKDIR)/jtagereceive/_behavioral.var $(WORKDIR)/nicserialio/_behavioral.var $(WORKDIR)/ethercontrol/_behavioral.var $(WORKDIR)/ether/_behavioral.var $(WORKDIR)/timer/_behavioral.var $(WORKDIR)/syscontrol/_behavioral.var $(WORKDIR)/nettest/_behavioral.var 

$(WORKDIR)/bootdeserialize/_behavioral.var: ../../../sim/components/bootdeser/bootdeserialize.vhd
	$(VHDLC) ../../../sim/components/bootdeser/bootdeserialize.vhd

$(WORKDIR)/mmc/_behavioral.var: ../../../sim/components/bootdeser/bootdeserialize.vhd ../../../boot/sim/components/mmc/mmc.vhd
	$(VHDLC) ../../../boot/sim/components/mmc/mmc.vhd

$(WORKDIR)/simplefpga/_behavioral.var: ../../../sim/components/bootdeser/bootdeserialize.vhd ../../../boot/sim/components/mmc/mmc.vhd ../../../sim/mmcfpgaboot/simplefpga.vhd
	$(VHDLC) ../../../sim/mmcfpgaboot/simplefpga.vhd

comp: $(WORKDIR)/bootdeserialize/_behavioral.var $(WORKDIR)/mmc/_behavioral.var $(WORKDIR)/simplefpga/_behavioral.var 

$(WORKDIR)/nettesttest/_behavioral.var: ../../../sim/components/bootdeser/bootdeserialize.vhd ../../../boot/sim/components/mmc/mmc.vhd ../../../sim/mmcfpgaboot/simplefpga.vhd nettesttest.vhd
	$(VHDLC) nettesttest.vhd

sim: $(WORKDIR)/nettesttest/_behavioral.var 
runsim: all
	$(VHDLS) nettesttest


clean:
	rm -Rf $(WORKDIR)$

