#include <iostream>
#include <list>
#include <map>
#include <boost/program_options.hpp>
#include <somanetwork/network.h>
#include <somanetwork/event.h>
#include <somanetwork/eventtx.h>
#include <boost/format.hpp>
#include <boost/array.hpp>

using boost::format;
using boost::io::group;

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
	if (pe->cmd != 0x10) {
	  std::cout << boost::format("cmd :%2.2x src: %2.2d %4.4x %4.4x %4.4x %4.4x %4.4x") 
	    % (int)pe->cmd  % (int)pe->src 
	    % (int)pe->data[0] % (int)pe->data[1]
	    % (int)pe->data[2] % (int)pe->data[3] % (int)pe->data[4]
		    << std::endl; 
	  targets++; 
	}
      }
    if (targets >0 ) {
      return targets; 
    }
    
  }
      

}

using namespace std; 
namespace po = boost::program_options;


int main(int argc, char * argv[])
{
  
  std::string SOMAIP("10.0.0.2"); 

  Network somanetwork(SOMAIP); 

  somanetwork.run(); 
  sleep(1); 
  // send a test event! 
  EventTXList_t etxl; 
  EventTX_t etx; 
  etx.destaddr[8] = true; 
  etx.destaddr[9] = true; 
  etx.destaddr[10] = true; 
  etx.destaddr[11] = true; 
  etx.event.cmd = 0x30; 
  etx.event.src = 0x3; 
  etx.event.data[0] = 0x9876; 
  
  
  etxl.push_back(etx); 
  somanetwork.sendEvents(etxl); 
    
    
  int cnt = loopTillEvent(0x30, 0x8, &somanetwork); 

  somanetwork.shutdown(); 

}
   
  
