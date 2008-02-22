#include <iostream>
#include <list>
#include <map>
#include <boost/program_options.hpp>
#include <somanetwork/network.h>
#include <somanetwork/event.h>
#include <somanetwork/eventtx.h>

#include <fstream>

int loopTillEvent(eventcmd_t cmd, eventsource_t src, Network* network)
{
  int eventpipe = network->getEventFifoPipe(); 
  while(1) {
    char dummy; 
    read(eventpipe, &dummy, 1);  // will block
    pEventList_t pel =  network->getNewEvents(); 
    int targets = 0; 

    for (EventList_t::iterator pe = pel->begin(); 
	 pe != pel->end(); ++pe)
      {
	if (pe->cmd == cmd and pe->src == src) {
	  targets++; 
	}
      }
    if (targets >0 ) {
      return targets; 
    }
    
  }
      

}

using namespace std; 

int main(void)
{

  std::string SOMAIP("10.0.0.2"); 

  Network somanetwork(SOMAIP); 
  std::list < pEventList_t > pell; 
  std::cout << "Network object created" << std::endl; 
  // now, try and get events: 
  
  ifstream bitFile ("/home/jonas/soma/dspboard/tgt/dspboard/vhdl/dspboard.bit",
		   ios::in | ios::binary);
  
  if (!bitFile) {
    cerr << "Error reading file" << std::endl;
    exit(1); 
  }
  somanetwork.run(); 
  int pos = 0; 
  while (!bitFile.eof()) {
    
    // send a test event! 
    EventTXList_t etxl; 
    EventTX_t etx; 
    etx.destaddr[1] = 1; 
    etx.event.cmd = 0xA2; 
    etx.event.src = 0x03; 
    
    for(int i = 0; i < 4; i++) {
      uint8_t data1, data2; 
      bitFile.read((char *)&data1, 1); 
      bitFile.read((char *)&data2, 1); 
      etx.event.data[i] = (data1 << 8) | data2; 
    }
    
    pos += 8; 
    etxl.push_back(etx); 
    somanetwork.sendEvents(etxl); 
    
    
    int cnt = loopTillEvent(0xA2, 0x1, &somanetwork); 
    std::cout << "received " << cnt << " target events, pos = " 
	      << pos << std::endl;
  }
  somanetwork.shutdown(); 

}
   
  
