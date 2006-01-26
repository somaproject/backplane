######################################################################
#
#
#   make PROJECTNAME: works through to the P&R
#   make bitfile: generate bitfile
#   make entity: tries to synth the entity
#   make parsim : generate post-place-and-route sim model

######################################################################
PROJECT = linktest

bitfile: $(PROJECT).bit

SOURCES = *.vhd
OPTIMIZE = high
PART = xc3s200-pq208-4
SPEED = 4

$(PROJECT): build/$(PROJECT).ncd

$(PROJECT).bit: build/$(PROJECT).bit
	rm -rf $(PROJECT).bit
	cp build/$(PROJECT).bit . 

$(PROJECT).rbt: build/$(PROJECT).rbt
	rm -rf $(PROJECT).rbt
	cp build/$(PROJECT).rbt . 

# coregen files:
%.edn : %.xco
	coregen -b $<

# first stage : xst, produces ngc

build/$(PROJECT).ngc: $(SOURCES) $(PROJECT).xst $(PROJECT).prj
	mkdir -p build
	xst -ifn $(PROJECT).xst
	mv $(PROJECT).ngc build/

%.syn : %.vhd
	sed "s/-top $(PROJECT)/-top $(subst .vhd,,$<)/" $(PROJECT).xst > .$<.xst
	xst -ifn .$<.xst

#second stage : ngdbuild, produces .ngd
build/$(PROJECT).ngd: build/$(PROJECT).ngc $(PROJECT).ucf 
	ngdbuild -p $(PART) -uc $(PROJECT).ucf -dd build build/$(PROJECT).ngc build/$(PROJECT).ngd


# third stage: map: produces pcf, map.ncd

build/$(PROJECT).pcf: build/$(PROJECT).ngd
	map -p $(PART) -ol $(OPTIMIZE) -timing -cm speed  -o build/map.ncd build/$(PROJECT).ngd build/$(PROJECT).pcf

build/$(PROJECT).ncd: build/$(PROJECT).pcf
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE)  build/map.ncd build/$(PROJECT).ncd build/$(PROJECT).pcf

build/$(PROJECT).bit: build/$(PROJECT).pcf build/$(PROJECT).ncd
	bitgen -w build/$(PROJECT).ncd build/$(PROJECT).bit build/$(PROJECT).pcf
build/$(PROJECT).rbt: build/$(PROJECT).pcf build/$(PROJECT).ncd
	bitgen -b -w build/$(PROJECT).ncd build/$(PROJECT).bit build/$(PROJECT).pcf

# timing reports
timing: build/$(PROJECT).twr
	less build/$(PROJECT).twr


build/$(PROJECT).twr: build/$(PROJECT).ncd build/$(PROJECT).pcf
	trce -intstyle ise -e 3 -l 3 -s $(SPEED) -xml $(PROJECT) build/$(PROJECT).ncd -o build/$(PROJECT).twr build/$(PROJECT).pcf

parsim: build/$(PROJECT).pcf build/$(PROJECT).ncd 
	netgen -intstyle ise -s $(SPEED) -pcf build/$(PROJECT).pcf -rpw 100 -tpw 0 -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ncd $(PROJECT)_timesim.vhd  

clean:
	rm -Rf build xst
