'Define some Some initialization paras
INCLUDE "GLOBAL_DEFS"
'Clear all the variables/VR/TABLE
DIM i AS INTEGER
FOR i=0 TO 65535
    VR(i)=0
NEXT i
FOR i=0 TO 500000
    TABLE(i,0)
NEXT i
