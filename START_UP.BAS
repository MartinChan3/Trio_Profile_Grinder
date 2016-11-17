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

VR(txt_start_pos)=200000
VR(txt_range_pos)=300000
VR(txt_last_start_position)=0
VR(encode_start_pos)=10000
VR(encode_range_pos)=1000
VR(mov_start_pos)=31000
VR(mov_range_pos)=1000
VR(encode_finished_flag_pos)=0
VR(mov_finished_flag_pos)=0
VR(encode_all_finished_flag_pos)=0

VR(multi_thread_num_once)=4'Change this to change the encode numbers
VR(encode_times_pos)=0'Save the times of encoding
'*******************Moving Parameters Setting*******************'
BASE(1,3)
DEFPOS(0,0)
LIMIT_BUFFERED=64
MERGE=OFF
'*******************Moving Parameters Setting*******************'

RUN "TXT_INSTREAM",thread_txt_instream

