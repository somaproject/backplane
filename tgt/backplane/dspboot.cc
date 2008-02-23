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
namespace po = boost::program_options;


int main(int argc, char * argv[])
{
  
  po::options_description desc("Allowed options");
  desc.add_options()
    ("help", "produce help message")
    ("somaip", po::value<string>()->default_value("10.0.0.2"), "soma device IP")
    ("file", po::value<string>(), "bitfile to load")
    ;

  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify(vm);    

  std::string SOMAIP(vm["somaip"].as<string>()); 

  Network somanetwork(SOMAIP); 
  std::list < pEventList_t > pell; 
  std::cout << "Network object created" << std::endl; 
  // now, try and get events: 
  
  ifstream bitFile (vm["file"].as<string>().c_str(), 
		    ios::in | ios::binary);
  
  if (!bitFile) {
    cerr << "Error reading file" << std::endl;
    exit(1); 
  }
  somanetwork.run(); 

  // first, send the 


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
   
  
