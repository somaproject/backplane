######################################################################
#
#
#   make PROJECTNAME: works through to the P&R
#   make bitfile: generate bitfile
#   make entity: tries to synth the entity
#   make parsim: post-place-and-route simulation 
######################################################################
PROJECT = linktest

bitfile: $(PROJECT).bit

SOURCES = *.vhd encode8b10b.edn decode8b10b.edn
UCFTGT = B
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

encode8b10b.edn: ../../../vhdl/encode8b10b.xco
	coregen -b ../../../vhdl/encode8b10b.xco

decode8b10b.edn: ../../../vhdl/decode8b10b.xco
	coregen -b ../../../vhdl/decode8b10b.xco

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
build/$(PROJECT).ngd: build/$(PROJECT).ngc $(PROJECT).$(UCFTGT).ucf 
	ngdbuild -p $(PART) -uc $(PROJECT).$(UCFTGT).ucf -dd build build/$(PROJECT).ngc build/$(PROJECT).ngd


# third stage: map: produces pcf, map.ncd

build/$(PROJECT).pcf: build/$(PROJECT).ngd
	map -p $(PART) -ol $(OPTIMIZE) -timing -cm speed  -xe n -pr b -k 4  -o build/map.ncd build/$(PROJECT).ngd build/$(PROJECT).pcf

build/$(PROJECT).ncd: build/$(PROJECT).pcf
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE) -xe n -t 1  build/map.ncd build/$(PROJECT).ncd build/$(PROJECT).pcf

build/$(PROJECT).bit: build/$(PROJECT).pcf build/$(PROJECT).ncd
	bitgen -w build/$(PROJECT).ncd build/$(PROJECT).bit build/$(PROJECT).pcf
	cp build/$(PROJECT).bit $(PROJECT).$(UCFTGT).bit

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
