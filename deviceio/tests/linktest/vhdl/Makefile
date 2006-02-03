######################################################################
#
#
#   make PROJECTNAME: works through to the P&R
#   make bitfile: generate bitfile
#   make entity: tries to synth the entity
#   make parsim: post-place-and-route simulation 
#   make synthsim: post-synthesis simulation model 
#   make multipar : reiterative PAR 
######################################################################
PROJECT = linktest

bitfile: $(PROJECT).bit

SOURCES = *.vhd encode8b10b.edn decode8b10b.edn
UCFTGT = A
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
synth: build/$(PROJECT).ngc

build/$(PROJECT).ngc: $(SOURCES) $(PROJECT).xst $(PROJECT).prj
	mkdir -p build
	xst -ifn $(PROJECT).xst
	mv $(PROJECT).ngc build/

%.syn : %.vhd
	sed "s/-top $(PROJECT)/-top $(subst .vhd,,$<)/" $(PROJECT).xst > .$<.xst
	xst -ifn .$<.xst

#second stage : ngdbuild, produces .ngd
trans: build/$(PROJECT).ngd

build/$(PROJECT).ngd: build/$(PROJECT).ngc $(PROJECT).$(UCFTGT).ucf 
	ngdbuild -p $(PART) -uc $(PROJECT).$(UCFTGT).ucf -insert_keep_hierarchy -dd build build/$(PROJECT).ngc build/$(PROJECT).ngd


# third stage: map: produces pcf, map.ncd

build/$(PROJECT)_map.ncd: build/$(PROJECT).ngd
	map -p $(PART) -ol $(OPTIMIZE) -timing  -xe n -pr b -k 4  -o build/$(PROJECT)_map.ncd build/$(PROJECT).ngd build/$(PROJECT).pcf

build/$(PROJECT).pcf: build/$(PROJECT)_map.ncd

build/$(PROJECT).ncd: build/$(PROJECT)_map.ncd
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE) -xe n  -t 7  build/$(PROJECT)_map.ncd build/$(PROJECT) build/$(PROJECT).pcf

multipar: build/$(PROJECT)_map.ncd
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE) -xe n -n 0 -t 1  build/$(PROJECT)_map.ncd build/$(PROJECT).dir build/$(PROJECT).pcf


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
	netgen -intstyle ise -s $(SPEED) -pcf build/$(PROJECT).pcf -rpw 100 -tpw 0 -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ncd $(PROJECT)_parsim.vhd  

synthsim: build/$(PROJECT).ngc
	netgen -intstyle ise -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ngc  $(PROJECT)_synthsim.vhd

transsim: build/$(PROJECT).ngd
	netgen -intstyle ise -rpw 100 -tpw 0 -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ngd $(PROJECT)_transsim.vhd



clean:
	rm -Rf build xst
