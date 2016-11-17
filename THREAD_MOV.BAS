INCLUDE "GLOBAL_DEFS"
'Move part,including the code translation
DIM i_control AS INTEGER
DIM count_command AS INTEGER
DIM run_speed,start_speed,end_speed AS FLOAT'volecity of each short line
DIM x,y,z AS FLOAT
DIM i_of_center,k_of_center AS FLOAT
DIM x_abs,y_abs,z_abs AS FLOAT
DIM ii AS INTEGER
'this ii is for the compensated statistics,count the num of compensated mov
i_control=1
count_command=VR(txt_range_pos)
ii=VR(encode_real_end_pos)
'resolution_encoder=2^20
'pitch_leadscrew=5
'UNITS=resolution_encoder/pitch_leadscrew

'run_speed=100
'start_speed=100
'end_speed=100
'
'FORCE_SPEED AXIS(1)=run_speed
'FORCE_SPEED AXIS(3)=run_speed
'STARTMOVE_SPEED AXIS(1)=start_speed
'STARTMOVE_SPEED AXIS(3)=start_speed
'ENDMOVE_SPEED AXIS(1)=end_speed
'ENDMOVE_SPEED AXIS(3)=end_speed

BASE(1,3)
UNITS AXIS(1)=400
UNITS AXIS(3)=400
SPEED AXIS(1)=7
SPEED AXIS(3)=7

'To solve the problem of CIRC
IF VR(encode_times_pos)>0 AND TABLE(30000+VR(mov_offset_pos))<>1 THEN
    TABLE(31000+VR(mov_offset_pos),VR(x_of_last_thread_pos))
    TABLE(32000+VR(mov_offset_pos),VR(y_of_last_thread_pos))
    TABLE(33000+VR(mov_offset_pos),VR(z_of_last_thread_pos))
ENDIF
'i_control=1
''The ORIGINAL trace move
'REPEAT
'    IF VR(10000+i_control+VR(mov_offset_pos))=0 THEN
'        x=TABLE(11000+i_control+VR(mov_offset_pos))
'        z=TABLE(13000+i_control+VR(mov_offset_pos))
'        GOSUB g00
'    ENDIF
'    IF VR(10000+i_control+VR(mov_offset_pos))=1 THEN
'        x=TABLE(11000+i_control+VR(mov_offset_pos))
'        z=TABLE(13000+i_control+VR(mov_offset_pos))
'        GOSUB g01
'    ENDIF
'    IF VR(10000+i_control+VR(mov_offset_pos))=2 THEN
'        x=TABLE(11000+i_control+VR(mov_offset_pos))-TABLE(11000+i_control-1+VR(mov_offset_pos))
'        z=TABLE(13000+i_control+VR(mov_offset_pos))-TABLE(13000+i_control-1+VR(mov_offset_pos))
'        i_of_center=VR(14000+i_control+VR(mov_offset_pos))
'        k_of_center=VR(15000+i_control+VR(mov_offset_pos))
'        GOSUB g02
'    ENDIF
'    IF VR(10000+i_control+VR(mov_offset_pos))=3 THEN
'        x=TABLE(11000+i_control+VR(mov_offset_pos))-TABLE(11000+i_control-1+VR(mov_offset_pos))
'        z=TABLE(13000+i_control+VR(mov_offset_pos))-TABLE(13000+i_control-1+VR(mov_offset_pos))
'        i_of_center=VR(14000+i_control+VR(mov_offset_pos))
'        k_of_center=VR(15000+i_control+VR(mov_offset_pos))
'        GOSUB g03
'    ENDIF
'    i_control=i_control+1
'UNTIL i_control>count_command

'The COMPENSATED Trace
i_control=1'Start from the first one
REPEAT
    IF TABLE(30000+i_control+VR(mov_offset_pos))=0 THEN
        x=TABLE(31000+i_control+VR(mov_offset_pos))
        z=TABLE(33000+i_control+VR(mov_offset_pos))
        GOSUB g00
    ENDIF
    IF TABLE(30000+i_control+VR(mov_offset_pos))=1 THEN
        x=TABLE(31000+i_control+VR(mov_offset_pos))
        z=TABLE(33000+i_control+VR(mov_offset_pos))
        GOSUB g01
    ENDIF
    IF TABLE(30000+i_control+VR(mov_offset_pos))=2 THEN
        x=TABLE(31000+i_control+VR(mov_offset_pos))-TABLE(31000+i_control-1+VR(mov_offset_pos))
        z=TABLE(33000+i_control+VR(mov_offset_pos))-TABLE(33000+i_control-1+VR(mov_offset_pos))
        i_of_center=TABLE(34000+i_control+VR(mov_offset_pos))-TABLE(31000+i_control-1+VR(mov_offset_pos))
        k_of_center=TABLE(35000+i_control+VR(mov_offset_pos))-TABLE(33000+i_control-1+VR(mov_offset_pos))
        GOSUB g02
    ENDIF
    IF TABLE(30000+i_control+VR(mov_offset_pos))=3 THEN
        x=TABLE(31000+i_control+VR(mov_offset_pos))-TABLE(31000+i_control-1+VR(mov_offset_pos))
        z=TABLE(33000+i_control+VR(mov_offset_pos))-TABLE(33000+i_control-1+VR(mov_offset_pos))
        i_of_center=TABLE(34000+i_control+VR(mov_offset_pos))-TABLE(31000+i_control-1+VR(mov_offset_pos))
        k_of_center=TABLE(35000+i_control+VR(mov_offset_pos))-TABLE(33000+i_control-1+VR(mov_offset_pos))
        GOSUB g03
    ENDIF
    i_control=i_control+1
UNTIL i_control>ii

'IF VR(encode_all_finished_flag_pos)=0 THEN
'    WAIT UNTIL PROC_STATUS PROC(thread_ctrl)=0
'    RUN "THREAD_CTRL",thread_ctrl
'ENDIF

STOP


'*********************Function Part**************************
'*********************Function Part**************************
'*********************Function Part**************************
g00:
'GOSUB velocity_look_ahead
MOVEABS(x,z)
RETURN

g01:
'GOSUB velocity_look_ahead
MOVEABS(x,z)
RETURN

g02:
'GOSUB velocity_look_ahead
MOVECIRC(x,z,i_of_center,k_of_center,0)
RETURN

g03:
'GOSUB velocity_look_aheFad
MOVECIRC(x,z,i_of_center,k_of_center,1)
RETURN
