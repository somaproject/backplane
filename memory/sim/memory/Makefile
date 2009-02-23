VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/dqalign/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/memcontmux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/behavioral.dat: $(WORKDIR)/touched ../../vhdl/dqalign.vhd ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/memcontmux.vhd ../../vhdl/memcontmux.vhd ../../vhdl/memddr2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/memddr2.vhd

hw: $(WORKDIR)/dqalign/behavioral.dat $(WORKDIR)/bootddr2/behavioral.dat $(WORKDIR)/readddr2/behavioral.dat $(WORKDIR)/refreshddr2/behavioral.dat $(WORKDIR)/writeddr2/behavioral.dat $(WORKDIR)/memcontmux/behavioral.dat $(WORKDIR)/memddr2/behavioral.dat 

comp: 

fmf/conversions/body.dat: fmf/touched ../components/freemodel/conversions.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/conversions.vhd

fmf/ecl_package/body.dat: fmf/touched ../components/freemodel/ecl_package.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/ecl_package.vhd

fmf/ecl_utils/body.dat: fmf/touched ../components/freemodel/ecl_utils.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/ecl_utils.vhd

fmf/ff_package/body.dat: fmf/touched ../components/freemodel/ff_package.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/ff_package.vhd

fmf/gen_utils/body.dat: fmf/touched ../components/freemodel/gen_utils.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/gen_utils.vhd

fmf/memory/body.dat: fmf/touched ../components/freemodel/memory.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/memory.vhd

fmf/state_tab_package/body.dat: fmf/touched ../components/freemodel/state_tab_package.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/state_tab_package.vhd

fmf/TRI_BUF/behavior.dat: fmf/touched ../components/freemodel/switch_pkg.vhd
	mkdir -p fmf
	$(VHDLC) -work fmf  ../components/freemodel/switch_pkg.vhd

$(WORKDIR)/mt47h64m16/vhdl_behavioral.dat: $(WORKDIR)/touched ../components/freemodel/mt47h64m16.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/freemodel/mt47h64m16.vhd

$(WORKDIR)/hy5ps121621f_pack/body.dat: $(WORKDIR)/touched ../components/freemodel/mt47h64m16.vhd ../components/hynix/HY5PS121621F_PACK.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/HY5PS121621F/behavioral_model_hy5ps121621f.dat: $(WORKDIR)/touched ../components/freemodel/mt47h64m16.vhd ../components/hynix/HY5PS121621F_PACK.vhd ../components/hynix/HY5PS121621F.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/hynix/HY5PS121621F.vhd

work/memddr2test/behavioral.dat: work/touched ../components/freemodel/mt47h64m16.vhd ../components/hynix/HY5PS121621F_PACK.vhd ../components/hynix/HY5PS121621F.vhd memddr2test.vhd
	mkdir -p work
	$(VHDLC) -work work  memddr2test.vhd

sim: fmf/conversions/body.dat fmf/ecl_package/body.dat fmf/ecl_utils/body.dat fmf/ff_package/body.dat fmf/gen_utils/body.dat fmf/memory/body.dat fmf/state_tab_package/body.dat fmf/TRI_BUF/behavior.dat $(WORKDIR)/mt47h64m16/vhdl_behavioral.dat $(WORKDIR)/hy5ps121621f_pack/body.dat $(WORKDIR)/HY5PS121621F/behavioral_model_hy5ps121621f.dat work/memddr2test/behavioral.dat 
runsim: all
	$(VHDLS) memddr2test


clean:
	rm -Rf fmf work 

fmf/touched:
	vlib  fmf
	touch  fmf/touched
work/touched:
	vlib  work
	touch  work/touched
