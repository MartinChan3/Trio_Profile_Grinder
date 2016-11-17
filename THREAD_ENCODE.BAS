INCLUDE "GLOBAL_DEFS"
'******************************************
DIM x,y,z,x0,y0,z0,i_of_center,k_of_center AS FLOAT
DIM v,vx,vy,vz AS FLOAT
DIM a,ax,ay,az AS FLOAT

DIM flag_coordinate AS INTEGER 'Absolute or relative
DIM flag_number_of_axis AS INTEGER'Reveal how many axis in a code sentence
DIM flag_cutter_compensation AS INTEGER 'left is 0,right is 1
DIM count_command AS INTEGER
count_command=0

DIM i,j,i1,i2,carriage_count AS INTEGER
DIM d_compensation AS FLOAT(100)'Store all the compensation value
FOR i =0 TO 99
    d_compensation(i)=i
NEXT i
i=0
j=-1
i1=0
i2=0
carriage_count=0
DIM m AS INTEGER
'*****************************************
'Read in the TABLE asc charcteristics
REPEAT
    DIM current_position_of_asc AS INTEGER
    current_position_of_asc=i+VR(txt_start_pos)+VR(txt_last_start_position)
    m=TABLE(current_position_of_asc)
    IF m=ASC("N") THEN
        count_command=count_command+1
        flag_number_of_axis=0
    ENDIF
    IF m=ASC("G") THEN
        GOSUB get_number
'*****Correct the mistake of G02 and G03*****
        IF VR(0)=2 THEN
            VR(0)=3
        ELSEIF VR(0)=3 THEN
            VR(0)=2
        ENDIF
'********************************************
        VR(10000+count_command)=VR(0)
        IF VR(0)=90 THEN
            flag_coordinate=0'absolute coordinate program
            VR(flag_coordinate_pos)=flag_coordinate
        ENDIF
        IF VR(0)=91 THEN
            flag_coordinate=1'relative coordinate program
            VR(flag_coordinate_pos)=flag_coordinate
        ENDIF
        IF VR(0)=41 THEN flag_cutter_compensation=0'left cutter compensation
        IF VR(0)=42 THEN flag_cutter_compensation=1'right cutter compensation
    ENDIF
    flag_coordinate=VR(flag_coordinate_pos)
    IF m=ASC("X") THEN
        GOSUB get_number
        VR(11000+count_command)=VR(0)
        flag_number_of_axis=flag_number_of_axis+1
    ENDIF
    IF m=ASC("Y") THEN
        GOSUB get_number
        VR(12000+count_command)=VR(0)
    ENDIF
    IF m=ASC("Z") THEN
        GOSUB get_number
        VR(13000+count_command)=VR(0)
        flag_number_of_axis=flag_number_of_axis+2
    ENDIF
    IF m=ASC("I") THEN
        GOSUB get_number
        VR(14000+count_command)=VR(0)
    ENDIF
    IF m=ASC("K") THEN
        GOSUB get_number
        VR(15000+count_command)=VR(0)
    ENDIF
    IF m=ASC("F") THEN
        GOSUB get_number
        VR(16000+count_command)=VR(0)
        VR(17000+count_command)=1'As the flag of whether velocity has changed
    ENDIF
    VR(9000+count_command)=flag_number_of_axis
    'Allow the G File to have one-line or two-line explanation
    'New line's asc is 10
    IF m=10 THEN
        i2=VR(10000+count_command)
        IF i2=41 OR i2=42 OR i2=90 OR i2=91 THEN
            IF flag_number_of_axis=0 THEN count_command=count_command-1
        ENDIF
    ENDIF
    'Judge if it reach an end or reach the range,the default range is up to VR(multi_thread_num_once)
    i=i+1
    DIM bool_whether_end AS BOOLEAN
    bool_whether_end=FALSE
    IF ((count_command>=VR(multi_thread_num_once)-1) AND TABLE(i+VR(txt_start_pos)+VR(txt_last_start_position))=_
        ASC("N")) THEN
        bool_whether_end=TRUE
        VR(encode_real_end_pos)=count_command'Record the real position of current encoding
        VR(txt_last_start_position)=i'********Record the real position of txt encoding to
        '*************************************prepare for the next time
    ENDIF
    IF (TABLE(i+VR(txt_start_pos))=0) THEN
        bool_whether_end=TRUE
        VR(encode_all_finished_flag_pos)=1
        VR(encode_real_end_pos)=count_command
        VR(txt_last_start_position)=i
        VR(txt_reach_end_pos)=1
    ENDIF
UNTIL bool_whether_end=TRUE
'****************************************************
'calculate the absolute coordinate of each axis
DIM i_control AS INTEGER
DIM ii AS INTEGER'ii is the data to remember the
DIM x_abs,y_abs,z_abs AS FLOAT
'DIM run_speed,start_speed,end_speed AS FLOAT'volecity of each short line
'run_speed=100
'start_speed=100
'end_speed=100

i_control=1
REPEAT
    IF (flag_coordinate=0 AND VR(9000+i_control)=3) THEN
        x_abs=VR(11000+i_control)
        y_abs=VR(12000+i_control)
        z_abs=VR(13000+i_control)
    ENDIF
    IF (flag_coordinate=0 AND VR(9000+i_control)=2) THEN
        z_abs=VR(13000+i_control)
        x_abs=TABLE(11000+i_control-1+VR(encode_offset_pos))
    ENDIF
    IF (flag_coordinate=0 AND VR(9000+i_control)=1) THEN
        x_abs=VR(11000+i_control)
        z_abs=TABLE(13000+i_control-1+VR(encode_offset_pos))
    ENDIF

    IF (flag_coordinate=1 AND VR(9000+i_control)=3) THEN
        x_abs=TABLE(11000+i_control+VR(encode_offset_pos)-1)+VR(11000+i_control)
        y_abs=TABLE(12000+i_control+VR(encode_offset_pos)-1)+VR(12000+i_control)
        z_abs=TABLE(13000+i_control+VR(encode_offset_pos)-1)+VR(13000+i_control)
    ENDIF
    IF (flag_coordinate=1 AND VR(9000+i_control)=2) THEN
        z_abs=TABLE(13000+i_control+VR(encode_offset_pos)-1)+VR(13000+i_control)
        x_abs=TABLE(11000+i_control+VR(encode_offset_pos)-1)
    ENDIF
    IF (flag_coordinate=1 AND VR(9000+i_control)=1) THEN
        x_abs=TABLE(11000+i_control+VR(encode_offset_pos)-1)+VR(11000+i_control)
        z_abs=TABLE(13000+i_control+VR(encode_offset_pos)-1)
    ENDIF

    TABLE(11000+i_control+VR(encode_offset_pos),x_abs)
    TABLE(12000+i_control+VR(encode_offset_pos),y_abs)
    TABLE(13000+i_control+VR(encode_offset_pos),z_abs)
    i_control=i_control+1
UNTIL i_control>count_command
'****************CorePart***************
GOSUB cutter_compensation
'****************CorePart***************
'IF first_time_mov=FALSE THEN
'    RUN "THREAD_CTRL",thread_ctrl
'ENDIF

'Delete the final one(if not the end)(!!!Caution here!!!)
IF VR(encode_all_finished_flag_pos)=0 THEN
    DIM i3 AS INTEGER
    DIM i4 AS FLOAT'i4 could be not a integer
    i4=0
    'This place 50 is determined by the real situation
    FOR i3=0 TO 20
        i4=TABLE(10000+count_command+VR(encode_offset_pos)+i3*1000)
        IF VR(encode_offset_pos)=const_offset_million THEN
            TABLE(10000+const_offset_zero+i3*1000,i4)
        ELSE
            TABLE(10000+const_offset_million+i3*1000,i4)
        ENDIF
    NEXT i3


    'Record the final data of last compensated point
    VR(x_of_last_thread_pos)=TABLE(31000+count_command+VR(encode_offset_pos)-1)
    VR(y_of_last_thread_pos)=TABLE(32000+count_command+VR(encode_offset_pos)-1)
    VR(z_of_last_thread_pos)=TABLE(33000+count_command+VR(encode_offset_pos)-1)


    FOR i3=0 TO 50
        TABLE(10000+count_command+VR(encode_offset_pos)+i3*1000,0)
    NEXT i3
    VR(10000)=VR(10000+count_command)
    count_command=count_command-1
ENDIF

'Store the real position of the compensated encoding result
VR(txt_range_pos)=count_command
VR(encode_real_end_pos)=ii-1
VR(encode_times_pos)=VR(encode_times_pos)+1

''Test'
'IF VR(encode_offset_pos)=const_offset_zero THEN
'    VR(encode_offset_pos)=const_offset_million
'ELSE
'    VR(encode_offset_pos)=const_offset_zero
'ENDIF
''Test'


STOP


'*********************Function Part**************************
'*********************Function Part**************************
'*********************Function Part**************************


'*********************Function Part**************************
'*********************Function Part**************************
'*********************Function Part**************************
get_number:
VR(0)=0
DIM i_get_number,flag_decimal_point,position_decimal_point,flag_negtive AS INTEGER
i_get_number=i
flag_decimal_point=0
position_decimal_point=0
flag_negtive=0
'Find if there is a negative
IF TABLE(i_get_number+1+VR(txt_start_pos)+VR(txt_last_start_position))=ASC("-") THEN
    flag_negtive=1
ENDIF
'Find if there is a decimal point
REPEAT
    DIM m_after AS INTEGER
    m_after=TABLE(i_get_number+1+VR(txt_start_pos)+VR(txt_last_start_position))
    IF m_after=ASC(".")THEN
        flag_decimal_point=1
        position_decimal_point=i_get_number+1
    ENDIF
    i_get_number=i_get_number+1
UNTIL (TABLE(i_get_number+VR(txt_start_pos)+VR(txt_last_start_position))=32 OR TABLE(i_get_number+_
VR(txt_start_pos)+VR(txt_last_start_position))=13)'32 is the ASC of Backspace

'If it doesn't have
IF flag_decimal_point=0 THEN
    i2=0
    FOR i1=(i_get_number-1) TO (i+1+flag_negtive) STEP -1
        VR(0)=VR(0)+VAL(CHR(TABLE(i1+VR(txt_start_pos)+VR(txt_last_start_position))))*10^i2
        i2=i2+1
    NEXT i1
ENDIF
'If it has
IF flag_decimal_point=1 THEN
    i2=-1
    FOR i1=(position_decimal_point+1)TO(i_get_number-1) STEP 1
        VR(0)=VR(0)+VAL(CHR(TABLE(i1+VR(txt_start_pos)+VR(txt_last_start_position))))*10^i2
        i2=i2-1
    NEXT i1
    i2=0
    FOR i1=(position_decimal_point-1)TO(i+1) STEP -1
        VR(0)=VR(0)+VAL(CHR(TABLE(i1+VR(txt_start_pos)+VR(txt_last_start_position))))*10^i2
        i2=i2+1
    NEXT i1
ENDIF

VR(0)=VR(0)*(-1)^flag_negtive

RETURN

'velocity look-ahead for setting velocity
velocity_look_ahead:
'FORCE_SPEED=run_speed
'STARTMOVE_SPEED=start_speed
'ENDMOVE_SPEED=end_speed
RETURN
'***********************************************************
'Calculate the cutter compensation
cutter_compensation:
DIM d AS FLOAT 'this is the radius of cutter
d=d_compensation(5)
DIM x1,y1,x2,y2,r AS FLOAT
GOSUB velocity_vector_calculation
RETURN

velocity_vector_calculation:
i=0
j=count_command
IF flag_cutter_compensation=1 THEN d=-d'Judge left or right
FOR i=1 TO j
    IF VR(10000+i)=0 THEN GOSUB line_unit_vector
    IF VR(10000+i)=1 THEN GOSUB line_unit_vector
    IF VR(10000+i)=2 THEN GOSUB cir_unit_vector
    IF VR(10000+i)=3 THEN GOSUB cir_unit_vector
    GOSUB cutter_vector
    GOSUB velocity_setting
NEXT i
ii=1

'!!!Consider the interval of threads here!!!
'The first time have the offset of the first point
IF VR(encode_times_pos)=0 THEN
'Start point,first time is to offset a tool radius vector
    TABLE(31000+VR(encode_offset_pos),TABLE(11000+VR(encode_offset_pos))+TABLE(16001+VR(encode_offset_pos)))'first x
'coordinate of
'compensated points
    TABLE(33000+VR(encode_offset_pos),TABLE(13000+VR(encode_offset_pos))+TABLE(17001+VR(encode_offset_pos)))
'first y coordinate of compensated points
'Manufacture point
    FOR i=1 TO j-1
        GOSUB cutter_point_calculation
    NEXT i
ELSE
    FOR i=0 TO j-1
        GOSUB cutter_point_calculation
    NEXT i
ENDIF


'End point
IF VR(10000+j)=0 OR VR(10000+j)=1 THEN
    TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+j+VR(encode_offset_pos))+TABLE(16000+j+VR(encode_offset_pos)))
    TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+j+VR(encode_offset_pos))+TABLE(17000+j+VR(encode_offset_pos)))
    TABLE(30000+ii+VR(encode_offset_pos),VR(10000+j))
ELSEIF VR(10000+j)=2 OR VR(10000+j)=3 THEN
    TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+j+VR(encode_offset_pos))+TABLE(22000+j+VR(encode_offset_pos))*(-d))
    TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+j+VR(encode_offset_pos))+TABLE(21000+j+VR(encode_offset_pos))*d)
    TABLE(30000+ii+VR(encode_offset_pos),VR(10000+j))
    TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+j+VR(encode_offset_pos)))
    TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+j+VR(encode_offset_pos)))
ENDIF
RETURN
'***************************************
'calculate the unit vector of each move
line_unit_vector:
x1=TABLE(11000+i-1+VR(encode_offset_pos))
x2=TABLE(11000+i+VR(encode_offset_pos))
y1=TABLE(13000+i-1+VR(encode_offset_pos))
y2=TABLE(13000+i+VR(encode_offset_pos))
TABLE(14000+i+VR(encode_offset_pos),(x2-x1)/SQR((x2-x1)^2+(y2-y1)^2))
TABLE(15000+i+VR(encode_offset_pos),(y2-y1)/SQR((x2-x1)^2+(y2-y1)^2))
RETURN
cir_unit_vector:
x=TABLE(11000+i-1+VR(encode_offset_pos))
y=TABLE(13000+i-1+VR(encode_offset_pos))
x0=TABLE(11000+i-1+VR(encode_offset_pos))+VR(14000+i)
y0=TABLE(13000+i-1+VR(encode_offset_pos))+VR(15000+i)
r=SQR((y0-y)^2+(x0-x)^2)
IF VR(10000+i)=2 THEN r=-r
TABLE(14000+i+VR(encode_offset_pos),(y-y0)/r)
TABLE(15000+i+VR(encode_offset_pos),(x0-x)/r)
TABLE(18000+i+VR(encode_offset_pos),x0)'Remember the absolute coordinate of the cir center
TABLE(19000+i+VR(encode_offset_pos),y0)
x=TABLE(11000+i+VR(encode_offset_pos))
y=TABLE(13000+i+VR(encode_offset_pos))
TABLE(21000+i+VR(encode_offset_pos),(y-y0)/r)'Calculate the final point velocity vector of cir
TABLE(22000+i+VR(encode_offset_pos),(x0-x)/r)
RETURN
'***************************************
cutter_vector:
TABLE(16000+i+VR(encode_offset_pos),TABLE(15000+i+VR(encode_offset_pos))*(-d))
TABLE(17000+i+VR(encode_offset_pos),TABLE(14000+i+VR(encode_offset_pos))*d)
RETURN
'***************************************
velocity_setting:

RETURN
'***************************************
cutter_point_calculation:
DIM flag_of_cutter AS INTEGER'This is the flag to declare which kind of compensation to do
DIM alpha,value_of_cos,value_of_sin AS FLOAT'Alpha is the angel of the two velocity
DIM compensated_x,compensated_z AS FLOAT
DIM xl1,yl1,xl2,yl2,xr1,yr1,r1,xr2,yr2,r2,delta,d1,distance_r1_r2 AS FLOAT'Store the coordinate values of the point
flag_of_cutter=0
IF (VR(10000+i)=0 AND VR(10000+i+1)=1) OR (VR(10000+i)=1 AND VR(10000+i+1)=1) THEN flag_of_cutter=1
IF (VR(10000+i)=1 AND VR(10000+i+1)=2) OR (VR(10000+i)=1 AND VR(10000+i+1)=3) THEN flag_of_cutter=2
IF (VR(10000+i)=2 AND VR(10000+i+1)=1) OR (VR(10000+i)=3 AND VR(10000+i+1)=1) THEN flag_of_cutter=3
IF (VR(10000+i)=2 AND VR(10000+i+1)=3) OR (VR(10000+i)=3 AND VR(10000+i+1)=2) THEN flag_of_cutter=4
IF (VR(10000+i)=2 AND VR(10000+i+1)=2) OR (VR(10000+i)=3 AND VR(10000+i+1)=3) THEN flag_of_cutter=4
IF flag_of_cutter<>3 AND flag_of_cutter<>4 THEN
    value_of_cos=TABLE(14000+i+VR(encode_offset_pos))*TABLE(14001+i+VR(encode_offset_pos))+TABLE(15000+i+_
    VR(encode_offset_pos))*TABLE(15001+i+VR(encode_offset_pos))'
'calculate the Alpha
    value_of_sin=TABLE(14000+i+VR(encode_offset_pos))*TABLE(15001+i+VR(encode_offset_pos))-TABLE(14001+i+_
    VR(encode_offset_pos))*TABLE(15000+i+VR(encode_offset_pos))
ELSEIF flag_of_cutter=3 OR flag_of_cutter=4 THEN
    value_of_cos=TABLE(21000+i+VR(encode_offset_pos))*TABLE(14001+i+VR(encode_offset_pos))+TABLE(22000+i+_
    VR(encode_offset_pos))*TABLE(15001+i+VR(encode_offset_pos))
    value_of_sin=TABLE(21000+i+VR(encode_offset_pos))*TABLE(15001+i+VR(encode_offset_pos))-TABLE(14001+i+_
    VR(encode_offset_pos))*TABLE(22000+i+VR(encode_offset_pos))
ENDIF
'Acorrding to the present article,following is the way to judge three kinds of cutter compensation
IF SGN(d)*value_of_sin>=0 THEN
    flag_of_cutter=flag_of_cutter+10
ELSEIF SGN(d)*value_of_sin<0 AND value_of_cos>0 THEN
    flag_of_cutter=flag_of_cutter+20
ELSE
    flag_of_cutter=flag_of_cutter+30
ENDIF
IF flag_of_cutter=11 THEN GOSUB shortening_line_to_line
IF flag_of_cutter=12 THEN GOSUB shortening_line_to_cir
IF flag_of_cutter=13 THEN GOSUB shortening_cir_to_line
IF flag_of_cutter=14 THEN GOSUB shortening_cir_to_cir
IF flag_of_cutter=21 THEN GOSUB extension_line_to_line
IF flag_of_cutter=22 THEN GOSUB extension_line_to_cir
IF flag_of_cutter=23 THEN GOSUB extension_cir_to_line
IF flag_of_cutter=24 THEN GOSUB extension_cir_to_cir
IF flag_of_cutter=31 THEN GOSUB insertion_line_to_line
IF flag_of_cutter=32 THEN GOSUB insertion_line_to_cir
IF flag_of_cutter=33 THEN GOSUB insertion_cir_to_line
IF flag_of_cutter=34 THEN GOSUB insertion_cir_to_cir
RETURN

'********************
shortening_line_to_line:
d1=d
xl1=TABLE(14000+i+VR(encode_offset_pos))
yl1=TABLE(15000+i+VR(encode_offset_pos))
xl2=TABLE(14000+i+1+VR(encode_offset_pos))
yl2=TABLE(15000+i+1+VR(encode_offset_pos))
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

shortening_line_to_cir:
d1=d
xl1=TABLE(14000+i+VR(encode_offset_pos))
yl1=TABLE(15000+i+VR(encode_offset_pos))
xl2=TABLE(14000+i+1+VR(encode_offset_pos))
yl2=TABLE(15000+i+1+VR(encode_offset_pos))
xr2=VR(14000+i+1)
yr2=VR(15000+i+1)
'r1=SQR((xl1-xr1)^2+(yl1-xr1)^2)
r2=SQR(xr2^2+yr2^2)
IF VR(10000+i+1)=3 THEN''''???????????????why this??
    r2=-r2
ENDIF
delta=SQR((r2-d)^2-(xl1*yr2-yl1*xr2-d1)^2)
compensated_x=xl1*(xl1*xr2+yl1*yr2)-d1*yl1-SGN(xl1*xr2+yl1*yr2)*delta*xl1
compensated_z=yl1*(xl1*xr2+yl1*yr2)+d1*xl1-SGN(xl1*xr2+yl1*yr2)*delta*yl1
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

shortening_cir_to_line:
d1=d
xl1=TABLE(14000+i+1+VR(encode_offset_pos))
yl1=TABLE(15000+i+1+VR(encode_offset_pos))
'xl2=TABLE(14000+i)
'yl2=TABLE(15000+i)
xr2=-TABLE(11000+i+VR(encode_offset_pos))+TABLE(18000+i+VR(encode_offset_pos))
yr2=-TABLE(13000+i+VR(encode_offset_pos))+TABLE(19000+i+VR(encode_offset_pos))
'r1=SQR((xl1-xr1)^2+(yl1-xr1)^2)
r2=SQR(xr2^2+yr2^2)
IF VR(10000+i)=3 THEN
    r2=-r2
ENDIF
delta=SQR((r2-d)^2-(xl1*yr2-yl1*xr2-d1)^2)
compensated_x=xl1*(xl1*xr2+yl1*yr2)-d1*yl1-SGN(xl1*xr2+yl1*yr2)*delta*xl1
compensated_z=yl1*(xl1*xr2+yl1*yr2)+d1*xl1-SGN(xl1*xr2+yl1*yr2)*delta*yl1
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),VR(10000+i))
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
RETURN

shortening_cir_to_cir:
xr1=TABLE(18000+i+VR(encode_offset_pos))-TABLE(11000+i+VR(encode_offset_pos))
yr1=TABLE(19000+i+VR(encode_offset_pos))-TABLE(13000+i+VR(encode_offset_pos))
xr2=VR(14000+i+1)
yr2=VR(15000+i+1)
r1=SQR(xr1^2+yr1^2)
r2=SQR(xr2^2+yr2^2)
distance_r1_r2=SQR((xr1-xr2)^2+(yr1-yr2)^2)
xl1=(yr2-yr1)/distance_r1_r2
yl1=-(xr2-xr1)/distance_r1_r2
IF VR(10000+i)=3 THEN r1=-r1
IF VR(10000+i+1)=3 THEN r2=-r2
d1=-d*(r1-r2)/distance_r1_r2'why another negative sign
r2=r1
xr2=xr1
yr2=yr1
delta=SQR((r2-d)^2-(xl1*yr2-yl1*xr2-d1)^2)
compensated_x=xl1*(xl1*xr2+yl1*yr2)-d1*yl1-SGN(xl1*xr2+yl1*yr2)*delta*xl1
compensated_z=yl1*(xl1*xr2+yl1*yr2)+d1*xl1-SGN(xl1*xr2+yl1*yr2)*delta*yl1
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),VR(10000+i))
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
RETURN
'**********************
extension_line_to_line:
d1=d
xl1=TABLE(14000+i+VR(encode_offset_pos))
yl1=TABLE(15000+i+VR(encode_offset_pos))
xl2=TABLE(14000+i+1+VR(encode_offset_pos))
yl2=TABLE(15000+i+1+VR(encode_offset_pos))
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

extension_line_to_cir:
d1=d
xl1=TABLE(14000+i+VR(encode_offset_pos))
yl1=TABLE(15000+i+VR(encode_offset_pos))
xl2=TABLE(14000+i+1+VR(encode_offset_pos))
yl2=TABLE(15000+i+1+VR(encode_offset_pos))
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(16000+i+1+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(17000+i+1+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

extension_cir_to_line:
d1=d
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(22000+i+VR(encode_offset_pos))*(-d))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(21000+i+VR(encode_offset_pos))*d)
TABLE(30000+ii+VR(encode_offset_pos),VR(10000+i))
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
r=SQR((TABLE(11000+i+VR(encode_offset_pos))-TABLE(18000+i+VR(encode_offset_pos)))^2+(TABLE(13000+i+_
VR(encode_offset_pos))-TABLE(19000+i+VR(encode_offset_pos)))^2)
IF VR(10000+i)=2 THEN r=-r
xl1=TABLE(21000+i+VR(encode_offset_pos))
yl1=TABLE(22000+i+VR(encode_offset_pos))
xl2=TABLE(14000+i+1+VR(encode_offset_pos))
yl2=TABLE(15000+i+1+VR(encode_offset_pos))
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

extension_cir_to_cir:
d1=d
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(22000+i+VR(encode_offset_pos))*(-d))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(21000+i+VR(encode_offset_pos))*d)
TABLE(30000+ii+VR(encode_offset_pos),VR(10000+i))
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
xl1=TABLE(21000+i+VR(encode_offset_pos))
yl1=TABLE(22000+i+VR(encode_offset_pos))
xl2=TABLE(14000+i+1+VR(encode_offset_pos))
yl2=TABLE(15000+i+1+VR(encode_offset_pos))
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii+VR(encode_offset_pos),compensated_x+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),compensated_z+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(16000+i+1+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(17000+i+1+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
RETURN
'**********************
insertion_line_to_line:
d1=d
TABLE(31000+ii+VR(encode_offset_pos),TABLE(16000+i+VR(encode_offset_pos))+ABS(d)*TABLE(14000+i+VR(encode_offset_pos))+_
TABLE(11000+i+_
VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(17000+i+VR(encode_offset_pos))+ABS(d)*TABLE(15000+i+VR(encode_offset_pos))+_
TABLE(13000+i+_
VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(16000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(14000+i+1+_
VR(encode_offset_pos))+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(17000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(15000+i+1+_
VR(encode_offset_pos))+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

insertion_line_to_cir:
d1=d
TABLE(31000+ii+VR(encode_offset_pos),TABLE(16000+i+VR(encode_offset_pos))+ABS(d)*TABLE(14000+i+VR(encode_offset_pos))+_
TABLE(11000+i+_
VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(17000+i+VR(encode_offset_pos))+ABS(d)*TABLE(15000+i+VR(encode_offset_pos))+_
TABLE(13000+i+_
VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(16000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(14000+i+1+_
VR(encode_offset_pos))+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(17000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(15000+i+1+_
VR(encode_offset_pos))+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(16000+i+1+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(17000+i+1+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN

insertion_cir_to_line:
d1=d
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(22000+i+VR(encode_offset_pos))*(-d))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(21000+i+VR(encode_offset_pos))*d)
TABLE(30000+ii+VR(encode_offset_pos),VR(10000+i))
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(22000+i+VR(encode_offset_pos))*(-d)+ABS(d)*TABLE(21000+i+_
VR(encode_offset_pos))+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(21000+i+VR(encode_offset_pos))*d+ABS(d)*TABLE(22000+i+VR(encode_offset_pos))_
+TABLE(13000+i+_
VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(16000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(14000+i+1+_
VR(encode_offset_pos))+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(17000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(15000+i+1+_
VR(encode_offset_pos))+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN


insertion_cir_to_cir:
d1=d
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(22000+i+VR(encode_offset_pos))*(-d))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(21000+i+VR(encode_offset_pos))*d)
TABLE(30000+ii+VR(encode_offset_pos),VR(10000+i))
TABLE(34000+ii+VR(encode_offset_pos),TABLE(18000+i+VR(encode_offset_pos)))
TABLE(35000+ii+VR(encode_offset_pos),TABLE(19000+i+VR(encode_offset_pos)))
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(22000+i+VR(encode_offset_pos))*(-d)+ABS(d)*TABLE(21000+i+_
VR(encode_offset_pos))+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(21000+i+VR(encode_offset_pos))*d+ABS(d)*TABLE(22000+i+VR(encode_offset_pos))_
+TABLE(13000+i+_
VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(16000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(14000+i+1+_
VR(encode_offset_pos))+TABLE(11000+i+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(17000+i+1+VR(encode_offset_pos))-ABS(d)*TABLE(15000+i+1+_
VR(encode_offset_pos))+TABLE(13000+i+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
TABLE(31000+ii+VR(encode_offset_pos),TABLE(11000+i+VR(encode_offset_pos))+TABLE(16000+i+1+VR(encode_offset_pos)))
TABLE(33000+ii+VR(encode_offset_pos),TABLE(13000+i+VR(encode_offset_pos))+TABLE(17000+i+1+VR(encode_offset_pos)))
TABLE(30000+ii+VR(encode_offset_pos),1)
ii=ii+1
RETURN




