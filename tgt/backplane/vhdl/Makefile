######################################################################
#
#
#   make PROJECTNAME: works through to the P&R
#   make bitfile: generate bitfile
#   make entity: tries to synth the entity
#   targets:
#   make synth: perform synthesis
#   make tran : translation
#   make map : mapping
#   make par : place-and-route
#   make synthsim: post-synthesis model
#   make parsim: post-place-and-route simulation 
#   make multipar : multiple attemt place and route
######################################################################
PROJECT = backplane

#export XIL_PLACE_ALLOW_LOCAL_BUFG_ROUTING=TRUE
export  XIL_MAP_SKIP_LOGICAL_DRC=TRUE
export XIL_PAR_DESIGN_CHECK_VERBOSE=1
SOURCES := $(shell sed -n 's/^vhdl\s\+\w\+\s*"\([^[:blank:]]\+\)"/\1/p' < $(PROJECT).prj | xargs)


OPTIMIZE = high
PART = xc4vlx25-10-ff668
SPEED = 10

bitfile: $(PROJECT).bit $(PROJECT).postmem.bit 

$(PROJECT): build/$(PROJECT).ncd
	echo $(SOURCES)
$(PROJECT).bit: $(PROJECT).postmem.bit
	rm -rf $(PROJECT).bit
	cp $(PROJECT).postmem.bit $(PROJECT).bit

$(PROJECT).rbt: build/$(PROJECT).rbt 
	rm -rf $(PROJECT).rbt
	cp build/$(PROJECT).rbt . 

# coregen files:
%.edn : %.xco
	coregen -b $<

# first stage : xst, produces ngc
synth: build/$(PROJECT).ngc

build/$(PROJECT).ngc: $(SOURCES) $(PROJECT).xst $(PROJECT).prj
	mkdir -p build
	xst -ifn $(PROJECT).xst
	mv $(PROJECT).ngc build/

%.syn : 
	sed "s/-top $(PROJECT)/-top $(subst .vhd,,$<)/" $(PROJECT).xst > tmp.xst
	xst -ifn .$<.xst

#second stage : ngdbuild, produces .ngd
trans: build/$(PROJECT).ngd

build/$(PROJECT).ngd: build/$(PROJECT).ngc $(PROJECT).ucf 
	ngdbuild -p $(PART) -uc $(PROJECT).ucf -bm $(PROJECT).bmm -dd build build/$(PROJECT).ngc build/$(PROJECT).ngd


# third stage: map: produces pcf, map.ncd

map: build/$(PROJECT)_map.ncd

build/$(PROJECT)_map.ncd: build/$(PROJECT).ngd
	map -p $(PART) -ol $(OPTIMIZE) -timing -logic_opt on -cm speed  -xe n \
	-register_duplication  -pr b -o build/$(PROJECT)_map.ncd build/$(PROJECT).ngd build/$(PROJECT).pcf

build/$(PROJECT).pcf: build/$(PROJECT)_map.ncd


# forth stage: par

build/$(PROJECT).ncd: build/$(PROJECT).pcf
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE)  build/$(PROJECT)_map.ncd build/$(PROJECT).ncd build/$(PROJECT).pcf

build/$(PROJECT).bit: build/$(PROJECT).pcf build/$(PROJECT).ncd
	bitgen -w build/$(PROJECT).ncd build/$(PROJECT).bit build/$(PROJECT).pcf
build/$(PROJECT).rbt: build/$(PROJECT).pcf build/$(PROJECT).ncd
	bitgen -b -w build/$(PROJECT).ncd build/$(PROJECT).bit build/$(PROJECT).pcf


# multiple runs
multipar: build/$(PROJECT)_map.ncd
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE) -xe n -n 0 -t 1  build/$(PROJECT)_map.ncd build/$(PROJECT).dir build/$(PROJECT).pcf



# timing reports
timing: build/$(PROJECT).twr
	less build/$(PROJECT).twr


build/$(PROJECT).twr: build/$(PROJECT).ncd build/$(PROJECT).pcf
	trce -intstyle ise -e 3 -l 3 -u 20 -s $(SPEED) -xml $(PROJECT) build/$(PROJECT).ncd -o build/$(PROJECT).twr build/$(PROJECT).pcf


# simulations

parsim: build/$(PROJECT).pcf build/$(PROJECT).ncd 
	netgen -intstyle ise -s $(SPEED) -pcf build/$(PROJECT).pcf -rpw 100 -tpw 0 -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ncd $(PROJECT)_timesim.vhd  

synthsim: build/$(PROJECT).ngc
	netgen -intstyle ise -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ngc  $(PROJECT)_synthsim.vhd

transsim: build/$(PROJECT).ngd
	netgen -intstyle ise -rpw 100 -tpw 0 -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ngd $(PROJECT)_transsim.vhd


# update roms
# It's not clear how we handle mutliple roms? 

$(PROJECT).postmem.bit: $(PROJECT).mem build/$(PROJECT).bit $(PROJECT).syscontrol.mem $(PROJECT).netcontrol.mem
	data2mem  -bm $(PROJECT)_bd.bmm  -bd $(PROJECT).mem  -bt build/$(PROJECT).bit  -o h $(PROJECT)_mem.vhd -o b $(PROJECT).postmem.bit
	python ../../../eproc/assemble/genrom.py $(PROJECT).bmm $(PROJECT).syscontrol.imem $(PROJECT).netcontrol.imem

forceromupdate: $(PROJECT).mem  $(PROJECT).syscontrol.mem $(PROJECT).netcontrol.mem
	data2mem  -bm $(PROJECT)_bd.bmm  -bd $(PROJECT).mem  -bt build/$(PROJECT).bit  -o h $(PROJECT)_mem.vhd -o b $(PROJECT).postmem.bit
	python ../../../eproc/assemble/genrom.py $(PROJECT).bmm $(PROJECT).syscontrol.imem $(PROJECT).netcontrol.imem
	cp $(PROJECT).postmem.bit $(PROJECT).bit

$(PROJECT).syscontrol.mem:  backplane.asmpy
	python ../../../eproc/assemble/assemble.py backplane.asmpy \
	$(PROJECT).syscontrol.imem $(PROJECT).syscontrol.mem > $(PROJECT).syscontrol.log

$(PROJECT).netcontrol.mem:  ../../../vhdl/netcontrol/netcontrol.asmpy
	python ../../../eproc/assemble/assemble.py  ../../../vhdl/netcontrol/netcontrol.asmpy \
	$(PROJECT).netcontrol.imem $(PROJECT).netcontrol.mem > $(PROJECT).netcontrol.log

$(PROJECT).mem: $(PROJECT).syscontrol.mem $(PROJECT).netcontrol.mem
	echo "@00000000" > $(PROJECT).mem
	cat $(PROJECT).syscontrol.mem >> $(PROJECT).mem
	echo "@10000000" >> $(PROJECT).mem
	cat $(PROJECT).netcontrol.mem >> $(PROJECT).mem

clean:
	rm -Rf xst build $(PROJECT).bit $(PROJECT).postmem.bit
