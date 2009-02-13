VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/dqalign/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/vhdl/memddr2.vhd

$(WORKDIR)/retxbuffer/behavioral.dat: $(WORKDIR)/touched ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/retxbuffer.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/retxbuffer.vhd

hw: $(WORKDIR)/dqalign/behavioral.dat $(WORKDIR)/bootddr2/behavioral.dat $(WORKDIR)/readddr2/behavioral.dat $(WORKDIR)/refreshddr2/behavioral.dat $(WORKDIR)/writeddr2/behavioral.dat $(WORKDIR)/memcontmux/behavioral.dat $(WORKDIR)/memddr2/behavioral.dat $(WORKDIR)/retxbuffer/behavioral.dat 

comp: 

fmf/conversions/body.dat: fmf/touched ../../../memory/sim/components/freemodel/conversions.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/conversions.vhd

fmf/ecl_package/body.dat: fmf/touched ../../../memory/sim/components/freemodel/ecl_package.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/ecl_package.vhd

fmf/ecl_utils/body.dat: fmf/touched ../../../memory/sim/components/freemodel/ecl_utils.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/ecl_utils.vhd

fmf/ff_package/body.dat: fmf/touched ../../../memory/sim/components/freemodel/ff_package.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/ff_package.vhd

fmf/gen_utils/body.dat: fmf/touched ../../../memory/sim/components/freemodel/gen_utils.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/gen_utils.vhd

fmf/memory/body.dat: fmf/touched ../../../memory/sim/components/freemodel/memory.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/memory.vhd

fmf/state_tab_package/body.dat: fmf/touched ../../../memory/sim/components/freemodel/state_tab_package.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/state_tab_package.vhd

fmf/TRI_BUF/behavior.dat: fmf/touched ../../../memory/sim/components/freemodel/switch_pkg.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../../../memory/sim/components/freemodel/switch_pkg.vhd

$(WORKDIR)/mt47h64m16/vhdl_behavioral.dat: $(WORKDIR)/touched ../../../memory/sim/components/freemodel/mt47h64m16.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../memory/sim/components/freemodel/mt47h64m16.vhd

$(WORKDIR)/retxbuffertest/behavioral.dat: $(WORKDIR)/touched ../../../memory/sim/components/freemodel/mt47h64m16.vhd retxbuffertest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) retxbuffertest.vhd

sim: fmf/conversions/body.dat fmf/ecl_package/body.dat fmf/ecl_utils/body.dat fmf/ff_package/body.dat fmf/gen_utils/body.dat fmf/memory/body.dat fmf/state_tab_package/body.dat fmf/TRI_BUF/behavior.dat $(WORKDIR)/mt47h64m16/vhdl_behavioral.dat $(WORKDIR)/retxbuffertest/behavioral.dat 
runsim: all
	$(VHDLS) retxbuffertest


clean:
	rm -Rf fmf work 

fmf/touched:
	vlib  fmf
	touch  fmf/touched
work/touched:
	vlib  work
	touch  work/touched
