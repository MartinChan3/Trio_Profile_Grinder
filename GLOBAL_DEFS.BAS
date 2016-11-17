'VR variables
'***************************************************************************
DIM temp_asc_stored,txt_start_pos,txt_range_pos AS INTEGER
DIM encode_start_pos,encode_range_pos,mov_start_pos,mov_range_pos AS INTEGER
DIM encode_real_end_pos,mov_real_end_pos AS INTEGER
DIM encode_finished_flag_pos,mov_finished_flag_pos AS INTEGER
DIM encode_all_finished_flag_pos AS INTEGER'Record whether u reach txt end
DIM txt_last_start_position AS INTEGER'In multi-thread,it could store
'**************************************all where did u stored the txt
DIM multi_thread_num_once AS INTEGER'Control the number of multi thread
'************************************encode numbers at one time
DIM encode_times_pos AS INTEGER 'Record the encode times
DIM encode_offset_pos,mov_offset_pos AS INTEGER
DIM flag_coordinate_pos AS INTEGER
DIM x_of_last_thread_pos,y_of_last_thread_pos,z_of_last_thread_pos AS INTEGER
DIM txt_reach_end_pos AS INTEGER 'A flag to define whether it reach txt end
'***************************************************************************

'Not VR or TABLE
'***************************************************************************
DIM first_time_mov AS BOOLEAN'A flag to define whether it runs first time

DIM thread_encode_1,thread_encode_2 AS INTEGER
DIM thread_mov_1,thread_mov_2 AS INTEGER
DIM thread_ctrl,thread_txt_instream AS INTEGER
DIM txt_instream_asc_num AS INTEGER
'***************************************************************************

'Constant variables
'***************************************************************************
DIM const_offset_zero AS INTEGER
DIM const_offset_million AS INTEGER
'***************************************************************************


'***************************************************************************
'***************************************************************************
'Definition of the above variables
'***************************************************************************
'***************************************************************************
temp_asc_stored=0
txt_start_pos=1
txt_range_pos=11
txt_last_start_position=21
encode_start_pos=2
encode_range_pos=12
encode_real_end_pos=22
mov_start_pos=3
mov_range_pos=13
mov_real_end_pos=23
encode_finished_flag_pos=102
encode_all_finished_flag_pos=42
mov_finished_flag_pos=103
multi_thread_num_once=77
encode_times_pos=7

encode_offset_pos=8
mov_offset_pos=9
flag_coordinate_pos=10
first_time_mov=FALSE


thread_encode_1=15
thread_encode_2=16
thread_mov_1=17
thread_mov_2=18
thread_txt_instream=0
thread_ctrl=13

x_of_last_thread_pos=201
y_of_last_thread_pos=202
z_of_last_thread_pos=203
txt_reach_end_pos=50

const_offset_zero=0
const_offset_million=100000
