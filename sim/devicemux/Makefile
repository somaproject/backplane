VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

soma/somabackplane/body.dat: soma/touched ../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/somabackplane.vhd

soma/regfile/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/regfile.vhd

soma/devicemuxtx/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemuxtx.vhd

soma/devicemuxeventrx2/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemuxeventrx2.vhd

soma/devicemuxrx/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemuxrx.vhd

soma/devicemux/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemux.vhd

hw: soma/somabackplane/body.dat soma/regfile/behavioral.dat soma/devicemuxtx/behavioral.dat soma/devicemuxeventrx2/behavioral.dat soma/devicemuxrx/behavioral.dat soma/devicemux/behavioral.dat 

comp: 

$(WORKDIR)/devicemuxtest/behavioral.dat: $(WORKDIR)/touched devicemuxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) devicemuxtest.vhd

sim: $(WORKDIR)/devicemuxtest/behavioral.dat 
runsim: all
	$(VHDLS) devicemuxtest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
