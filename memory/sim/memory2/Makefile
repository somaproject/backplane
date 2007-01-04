VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../vhdl/dqalign.vhd
	$(VHDLC) -vital2000 ../../vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd
	$(VHDLC) -vital2000 ../../vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd
	$(VHDLC) -vital2000 ../../vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd
	$(VHDLC) -vital2000 ../../vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd
	$(VHDLC) -vital2000 ../../vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/memcontmux.vhd
	$(VHDLC) -vital2000 ../../vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/memcontmux.vhd ../../vhdl/memddr2.vhd
	$(VHDLC) -vital2000 ../../vhdl/memddr2.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var 

comp: 

fmf.sym/conversions/prim.var: ../components/freemodel/conversions.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/conversions.vhd

fmf.sym/ecl_package/prim.var: ../components/freemodel/ecl_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/ecl_package.vhd

fmf.sym/ecl_utils/prim.var: ../components/freemodel/ecl_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/ecl_utils.vhd

fmf.sym/ff_package/prim.var: ../components/freemodel/ff_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/ff_package.vhd

fmf.sym/gen_utils/prim.var: ../components/freemodel/gen_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/gen_utils.vhd

fmf.sym/memory/prim.var: ../components/freemodel/memory.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/memory.vhd

fmf.sym/state_tab_package/prim.var: ../components/freemodel/state_tab_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/state_tab_package.vhd

fmf.sym/switch_pkg/_behavior.var: ../components/freemodel/switch_pkg.vhd
	$(VHDLC) -vital2000 -work fmf  ../components/freemodel/switch_pkg.vhd

$(WORKDIR)/mt47h64m16/_vhdl_behavioral.var: ../components/freemodel/mt47h64m16.vhd
	$(VHDLC) -vital2000 ../components/freemodel/mt47h64m16.vhd

$(WORKDIR)/hy5ps121621f_pack/prim.var: ../components/freemodel/mt47h64m16.vhd ../components/hynix/HY5PS121621F_PACK.vhd
	$(VHDLC) -vital2000 ../components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var: ../components/freemodel/mt47h64m16.vhd ../components/hynix/HY5PS121621F_PACK.vhd ../components/hynix/HY5PS121621F.vhd
	$(VHDLC) -vital2000 ../components/hynix/HY5PS121621F.vhd

work.sym/memddr2test/_behavioral.var: ../components/freemodel/mt47h64m16.vhd ../components/hynix/HY5PS121621F_PACK.vhd ../components/hynix/HY5PS121621F.vhd memddr2test.vhd
	$(VHDLC) -vital2000 -work work  memddr2test.vhd

sim: fmf.sym/conversions/prim.var fmf.sym/ecl_package/prim.var fmf.sym/ecl_utils/prim.var fmf.sym/ff_package/prim.var fmf.sym/gen_utils/prim.var fmf.sym/memory/prim.var fmf.sym/state_tab_package/prim.var fmf.sym/switch_pkg/_behavior.var $(WORKDIR)/mt47h64m16/_vhdl_behavioral.var $(WORKDIR)/hy5ps121621f_pack/prim.var $(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var work.sym/memddr2test/_behavioral.var 
runsim: all
	$(VHDLS) memddr2test


clean:
	rm -Rf *.sym

