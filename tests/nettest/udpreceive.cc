#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <iostream> 
#include <vector>
#include <list>
#include <sys/time.h>
#include <time.h>
#include <map>


const int BUFLEN = 1500; 

using namespace std; 
int main(void)
{
  struct sockaddr_in si_me, si_other;
  int s, i, slen=sizeof(si_other);
  char buf[BUFLEN];

  s = socket(AF_INET, SOCK_DGRAM, 17); 
  cout << s << endl; 

  memset((char *) &si_me, sizeof(si_me), 0);

  si_me.sin_family = AF_INET;
  si_me.sin_port = htons(5000);

  si_me.sin_addr.s_addr = INADDR_ANY; 

  int optval = 1; 

  cout << (setsockopt (s, SOL_SOCKET, SO_BROADCAST, 
		       (const void *) &optval, sizeof(optval))) << endl; 

  optval = 1; 
   cout << setsockopt(s, SOL_SOCKET, SO_REUSEADDR, 
       &optval, sizeof (optval)) 
      << endl; 

  int res=  bind(s, (sockaddr*)&si_me, sizeof(si_me)); 
  cout << res << endl; 
  
  int N = 10000000; 

  vector<unsigned int> rxpackets(N);

  timeval t1, t2; 
  gettimeofday(&t1, NULL); 

  for (int i = 0; i < N; i++) {
    int n = recv(s, buf, 100, 0); 
    int newid; 
    if (i % 1000000 == 0)
      cout << "received " << i << "packets" << endl; 

    memcpy(&newid, &buf[2], 4); 
    newid =  ntohl(newid); 
    rxpackets[i] = newid; 
    
  }; 
  gettimeofday(&t2, NULL); 
  
  long t1u = t1.tv_sec * 1000000 + t1.tv_usec; 
  long t2u = t2.tv_sec * 1000000 + t2.tv_usec; 
  cout << "Received N=" << N << " packets in " << float(t2u-t1u )/1e6
       << " seconds (" <<  N/(float(t2u-t1u )/1e6) << " packets/sec)" << endl; 
  
  // verification
  rxpackets[i]; 
  sort(rxpackets.begin(), rxpackets.end()); 
  
  int misses = 0; 
  int dupes = 0; 
  int correct = 0; 
  for (int i = 1; i < rxpackets.size(); i++) {
    if (rxpackets[i] == rxpackets[i-1]) {
      dupes += 1; 
    } else if (rxpackets[i] == rxpackets[i-1] + 1) {
      correct += 1; 
    }  else {
      misses += 1; 
    }
  }
  
  cout << "correct = " << correct << endl; 
  cout << "misses = " << misses << endl; 
  cout << "dupes = " << dupes << endl; 

  
  

}
