Window detection: 

       The window detection module looks through the array of bits
presented with a pipelined mux-like interface and finds 

1. the start of the longest sequence of zeros
2. the length of that sequence

If there are two identical-length sequences, the first
found-one is used. 

If there are no zeros, FAIL is asserted along with DONE. 

