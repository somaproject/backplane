VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

fmf.sym/conversions/prim.var: conversions.vhd
	$(VHDLC) -vital2000 -work fmf  conversions.vhd

fmf.sym/ecl_package/prim.var: ecl_package.vhd
	$(VHDLC) -vital2000 -work fmf  ecl_package.vhd

fmf.sym/ecl_utils/prim.var: ecl_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ecl_utils.vhd

fmf.sym/ff_package/prim.var: ff_package.vhd
	$(VHDLC) -vital2000 -work fmf  ff_package.vhd

fmf.sym/gen_utils/prim.var: gen_utils.vhd
	$(VHDLC) -vital2000 -work fmf  gen_utils.vhd

fmf.sym/memory/prim.var: memory.vhd
	$(VHDLC) -vital2000 -work fmf  memory.vhd

fmf.sym/state_tab_package/prim.var: state_tab_package.vhd
	$(VHDLC) -vital2000 -work fmf  state_tab_package.vhd

fmf.sym/switch_pkg/_behavior.var: switch_pkg.vhd
	$(VHDLC) -vital2000 -work fmf  switch_pkg.vhd

hw: fmf.sym/conversions/prim.var fmf.sym/ecl_package/prim.var fmf.sym/ecl_utils/prim.var fmf.sym/ff_package/prim.var fmf.sym/gen_utils/prim.var fmf.sym/memory/prim.var fmf.sym/state_tab_package/prim.var fmf.sym/switch_pkg/_behavior.var 

comp: 

$(WORKDIR)/mt47h64m16/_vhdl_behavioral.var: mt47h64m16.vhd
	$(VHDLC) -vital2000 mt47h64m16.vhd

sim: $(WORKDIR)/mt47h64m16/_vhdl_behavioral.var 
runsim: all
	$(VHDLS) mt47h64m16


clean:
	rm -Rf *.sym

