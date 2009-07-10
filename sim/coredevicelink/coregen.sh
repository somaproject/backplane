#!/bin/bash

coregen -b ../../vhdl/devicelink/encode8b10b.xco
coregen -b ../../vhdl/devicelink/decode8b10b.xco
coregen -b ../../../dspboard/vhdl/serial-deviceio/vhdl/encode8b10b.xco
coregen -b ../../../dspboard/vhdl/serial-deviceio/vhdl/decode8b10b.xco

