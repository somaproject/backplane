#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUFLEN 5
#define NPACK 10
#define PORT 5000

void diep(char *s)
{
    perror(s);
    exit(1);
}

int main(void)
{
   struct sockaddr_in si_me, si_other;
   int s, i, slen=sizeof(si_other);
   char buf[BUFLEN];

   if ((s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1)
     diep("socket");
   memset((char *) &si_me, sizeof(si_me), 0);
   si_me.sin_family = AF_INET;
   si_me.sin_port = htons(PORT);
   si_me.sin_addr.s_addr = htonl(INADDR_ANY);
   if (bind(s, (sockaddr *)&si_me, sizeof(si_me))==-1)
     diep("bind");
    
   for (i=0; i<NPACK; i++) {
     if (recvfrom(s, buf, BUFLEN, 0,(sockaddr *)&si_other,(socklen_t*) &slen)==-1)
              diep("recvfrom()");
     printf("Received packet from %s:%d\n", 
     inet_ntoa(si_other.sin_addr), ntohs(si_other.sin_port));
     printf("  SEQ = %d\n", htonl(*((int *) buf ))); 
   }
   
   close(s);
   return 0;
}
