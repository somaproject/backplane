VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../../memory/vhdl/dqalign.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/memddr2.vhd

$(WORKDIR)/retxbuffer/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/retxbuffer.vhd
	$(VHDLC) -vital2000 ../../vhdl/retxbuffer.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var $(WORKDIR)/retxbuffer/_behavioral.var 

comp: 

fmf.sym/conversions/prim.var: ../../../memory/sim/components/freemodel/conversions.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/conversions.vhd

fmf.sym/ecl_package/prim.var: ../../../memory/sim/components/freemodel/ecl_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/ecl_package.vhd

fmf.sym/ecl_utils/prim.var: ../../../memory/sim/components/freemodel/ecl_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/ecl_utils.vhd

fmf.sym/ff_package/prim.var: ../../../memory/sim/components/freemodel/ff_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/ff_package.vhd

fmf.sym/gen_utils/prim.var: ../../../memory/sim/components/freemodel/gen_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/gen_utils.vhd

fmf.sym/memory/prim.var: ../../../memory/sim/components/freemodel/memory.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/memory.vhd

fmf.sym/state_tab_package/prim.var: ../../../memory/sim/components/freemodel/state_tab_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/state_tab_package.vhd

fmf.sym/switch_pkg/_behavior.var: ../../../memory/sim/components/freemodel/switch_pkg.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/switch_pkg.vhd

$(WORKDIR)/mt47h64m16/_vhdl_behavioral.var: ../../../memory/sim/components/freemodel/mt47h64m16.vhd
	$(VHDLC) -vital2000 ../../../memory/sim/components/freemodel/mt47h64m16.vhd

$(WORKDIR)/retxbuffertest/_behavioral.var: ../../../memory/sim/components/freemodel/mt47h64m16.vhd retxbuffertest.vhd
	$(VHDLC) -vital2000 retxbuffertest.vhd

sim: fmf.sym/conversions/prim.var fmf.sym/ecl_package/prim.var fmf.sym/ecl_utils/prim.var fmf.sym/ff_package/prim.var fmf.sym/gen_utils/prim.var fmf.sym/memory/prim.var fmf.sym/state_tab_package/prim.var fmf.sym/switch_pkg/_behavior.var $(WORKDIR)/mt47h64m16/_vhdl_behavioral.var $(WORKDIR)/retxbuffertest/_behavioral.var 
runsim: all
	$(VHDLS) retxbuffertest


clean:
	rm -Rf *.sym

