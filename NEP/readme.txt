General design notes and overview:

We're using the Triton-ECO embedded linux board -- it's the smallest, cheapest xscale board available. We're connecting to the backplane via a vertical 68-pin connector like we've been using. 

The goal here is to have the NEP potentially be... 5 Triton-ECOs. 

It looks like we'll have to program, boot the things via jtag. Which sucks. Although if we bring out the RS-232 connector, it doesn't suck -as much-

Goal: NEP carrier board for two tritons. Suggests we'll need 16 data + 8 addr + 5 jtag + reset + 4 GPIO = 34 pins for each one, plus 30 for the Event Bus == 98 pins, which is a lot. 

But we should / could maybe make this fit in a PQ144. But then, how do we do debugging? 

I'm beginning to think the RS-232 interface isn't such a bad idea. It wouldn't be too hard to mate to the event bus, would take up fewer lines, etc. etc. 

We could optionally stick some flash on the board too, and it would end up booting decently. So, ditch the 5 jtag lines. 

We're going to try and have the ability to use the Sync interface, because wow, it'll be hella faster. 

 
So each interface will have:

MD[15:0]
CS2
OE
PWE
NADV
SDCLK0
MA[7:0]
DQM[1:0]
RDY
UART_RX
UART_TX
GPIO[1:0]
RESET

Total: 36

Additionally, there's the connection to the serial drivers, of which there are 2. so + 2. And add on 2 debug LEDs. 

Total: 40

Now, how to then do the RS-232 dance? How badly do we want a board that stands on its own ? I would argue "not very". Stick some flash on it, stick a debug-mode jumper, and let's be done with it!

The "Event" interface is also rather small, with maybe 30 pins max. Internal clock to power interfaces, which means we use the other clock in debug mode something something. 

so 40*2 + 30 for event + 5 for boot == 115 total. Plus extras for the DCI stuff, because that's a dance we obviously want to do. 

Connector is 54142-1440


7 July 2004
In reality, it looks like each triton ECO is going to run at around 44 pins, which gives us:

44 per ECO
2 serial output per ECO
4 LEDs/ECO 
 == 50

+ 30 for event, + 5 for boot

135

Which hopefully will still not suck. 


Oh look, we've not really addressed the both-boot-modes problem. 

Okay, size constraints mean we're going to have one, yes, one triton module for this thing. Damn. 

