DIM count_command AS INTEGER
count_command=0
i=0

REPEAT
    m=TABLE(i)
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
        IF VR(0)=90 THEN flag_coordinate=0'absolute coordinate program
        IF VR(0)=91 THEN flag_coordinate=1'relative coordinate program
        IF VR(0)=41 THEN flag_cutter_compensation=0'left cutter compensation
        IF VR(0)=42 THEN flag_cutter_compensation=1'right cutter compensation
    ENDIF
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
    i=i+1
    'Allow the G File to have one-line or two-line explanation
    'New line's asc is 10
    IF m=10 THEN
        i2=VR(10000+count_command)
        IF i2=41 OR i2=42 OR i2=90 OR i2=91 THEN
            IF flag_number_of_axis=0 THEN count_command=count_command-1
        ENDIF
    ENDIF
UNTIL TABLE(i)=0
'****************************************************
'Move part,including the code translation
DIM i_control AS INTEGER
DIM run_speed,start_speed,end_speed AS FLOAT'volecity of each short line
DIM x_abs,y_abs,z_abs AS FLOAT
DIM ii AS INTEGER
'this ii is for the compensated statistics,count the num of compensated mov
i_control=1
'resolution_encoder=2^20
'pitch_leadscrew=5
'UNITS=resolution_encoder/pitch_leadscrew

run_speed=100
start_speed=100
end_speed=100

FORCE_SPEED AXIS(1)=run_speed
FORCE_SPEED AXIS(3)=run_speed
STARTMOVE_SPEED AXIS(1)=start_speed
STARTMOVE_SPEED AXIS(3)=start_speed
ENDMOVE_SPEED AXIS(1)=end_speed
ENDMOVE_SPEED AXIS(3)=end_speed


SPEED AXIS(1)=100
SPEED AXIS(3)=100

'calculate the absolute coordinate of each axis
REPEAT
    IF (flag_coordinate=0 AND VR(9000+i_control)=3) THEN
        x_abs=VR(11000+i_control)
        y_abs=VR(12000+i_control)
        z_abs=VR(13000+i_control)
    ENDIF
    IF (flag_coordinate=0 AND VR(9000+i_control)=2) THEN
        z_abs=VR(13000+i_control)
        x_abs=TABLE(11000+i_control-1)
    ENDIF
    IF (flag_coordinate=0 AND VR(9000+i_control)=1) THEN
        x_abs=VR(11000+i_control)
        z_abs=TABLE(13000+i_control-1)
    ENDIF

    IF (flag_coordinate=1 AND VR(9000+i_control)=3) THEN
        x_abs=x_abs+VR(11000+i_control)
        y_abs=y_abs+VR(12000+i_control)
        z_abs=z_abs+VR(13000+i_control)
    ENDIF
    IF (flag_coordinate=1 AND VR(9000+i_control)=2) THEN
        z_abs=z_abs+VR(13000+i_control)
        x_abs=TABLE(11000+i_control-1)
    ENDIF
    IF (flag_coordinate=1 AND VR(9000+i_control)=1) THEN
        x_abs=x_abs+VR(11000+i_control)
        z_abs=TABLE(13000+i_control-1)
    ENDIF

    TABLE(11000+i_control,x_abs)
    TABLE(12000+i_control,y_abs)
    TABLE(13000+i_control,z_abs)
    i_control=i_control+1
UNTIL i_control>count_command
'****************CorePart***************
GOSUB cutter_compensation
'****************CorePart***************
i_control=1
BASE(1,3)
DEFPOS(0,0)

'The ORIGINAL trace move
REPEAT
    IF VR(10000+i_control)=0 THEN
        x=TABLE(11000+i_control)
        z=TABLE(13000+i_control)
        GOSUB g00
    ENDIF
    IF VR(10000+i_control)=1 THEN
        x=TABLE(11000+i_control)
        z=TABLE(13000+i_control)
        GOSUB g01
    ENDIF
    IF VR(10000+i_control)=2 THEN
        x=TABLE(11000+i_control)-TABLE(11000+i_control-1)
        z=TABLE(13000+i_control)-TABLE(13000+i_control-1)
        i_of_center=VR(14000+i_control)
        k_of_center=VR(15000+i_control)
        GOSUB g02
    ENDIF
    IF VR(10000+i_control)=3 THEN
        x=TABLE(11000+i_control)-TABLE(11000+i_control-1)
        z=TABLE(13000+i_control)-TABLE(13000+i_control-1)
        i_of_center=VR(14000+i_control)
        k_of_center=VR(15000+i_control)
        GOSUB g03
    ENDIF
    i_control=i_control+1
UNTIL i_control>count_command

DEFPOS(0,0)

'The COMPENSATED Trace
i_control=0
REPEAT
    IF TABLE(30000+i_control)=0 THEN
        x=TABLE(31000+i_control)
        z=TABLE(33000+i_control)
        GOSUB g00
    ENDIF
    IF TABLE(30000+i_control)=1 THEN
        x=TABLE(31000+i_control)
        z=TABLE(33000+i_control)
        GOSUB g01
    ENDIF
    IF TABLE(30000+i_control)=2 THEN
        x=TABLE(31000+i_control)-TABLE(31000+i_control-1)
        z=TABLE(33000+i_control)-TABLE(33000+i_control-1)
        i_of_center=TABLE(34000+i_control)-TABLE(31000+i_control-1)
        k_of_center=TABLE(35000+i_control)-TABLE(33000+i_control-1)
        GOSUB g02
    ENDIF
    IF TABLE(30000+i_control)=3 THEN
        x=TABLE(31000+i_control)-TABLE(31000+i_control-1)
        z=TABLE(33000+i_control)-TABLE(33000+i_control-1)
        i_of_center=TABLE(34000+i_control)-TABLE(31000+i_control-1)
        k_of_center=TABLE(35000+i_control)-TABLE(33000+i_control-1)
        GOSUB g03
    ENDIF
    i_control=i_control+1
UNTIL i_control>ii

STOP

get_number:
VR(0)=0
i_get_number=i
flag_decimal_point=0
position_decimal_point=0
flag_negtive=0
'Find if there is a negative
IF TABLE(i_get_number+1)=ASC("-") THEN
    flag_negtive=1
ENDIF
'Find if there is a decimal point
REPEAT
    m_after=TABLE(i_get_number+1)
    IF m_after=ASC(".")THEN
        flag_decimal_point=1
        position_decimal_point=i_get_number+1
    ENDIF
    i_get_number=i_get_number+1
UNTIL (TABLE(i_get_number)=32 OR TABLE(i_get_number)=13)'32 is the ASC of Backspace
'If it doesn't have
IF flag_decimal_point=0 THEN
    i2=0
    FOR i1=(i_get_number-1) TO (i+1+flag_negtive) STEP -1
        VR(0)=VR(0)+VAL(CHR(TABLE(i1)))*10^i2
        test1=VR(0)
        i2=i2+1
    NEXT i1
ENDIF
'If it has
IF flag_decimal_point=1 THEN
    i2=-1
    FOR i1=(position_decimal_point+1)TO(i_get_number-1) STEP 1
        VR(0)=VR(0)+VAL(CHR(TABLE(i1)))*10^i2
        i2=i2-1
    NEXT i1
    i2=0
    FOR i1=(position_decimal_point-1)TO(i+1) STEP -1
        VR(0)=VR(0)+VAL(CHR(TABLE(i1)))*10^i2
        i2=i2+1
    NEXT i1
ENDIF

VR(0)=VR(0)*(-1)^flag_negtive

RETURN


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

'velocity look-ahead for setting velocity
velocity_look_ahead:
FORCE_SPEED=run_speed
STARTMOVE_SPEED=start_speed
ENDMOVE_SPEED=end_speed
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
'Start point
TABLE(31000,TABLE(11000)+TABLE(16001))'first x coordinate of compensated points
TABLE(33000,TABLE(13000)+TABLE(17001))'first y coordinate of compensated points
'Manufacture point
FOR i=1 TO j-1
    GOSUB cutter_point_calculation
NEXT i
'End point
IF VR(10000+j)=0 OR VR(10000+j)=1 THEN
    TABLE(31000+ii,TABLE(11000+j)+TABLE(16000+j))
    TABLE(33000+ii,TABLE(13000+j)+TABLE(17000+j))
    TABLE(30000+ii,VR(10000+j))
ELSEIF VR(10000+j)=2 OR VR(10000+j)=3 THEN
    TABLE(31000+ii,TABLE(11000+j)+TABLE(22000+j)*(-d))
    TABLE(33000+ii,TABLE(13000+j)+TABLE(21000+j)*d)
    TABLE(30000+ii,VR(10000+j))
    TABLE(34000+ii,TABLE(18000+j))
    TABLE(35000+ii,TABLE(19000+j))
ENDIF
RETURN
'***************************************
'calculate the unit vector of each move
line_unit_vector:
x1=TABLE(11000+i-1)
x2=TABLE(11000+i)
y1=TABLE(13000+i-1)
y2=TABLE(13000+i)
TABLE(14000+i,(x2-x1)/SQR((x2-x1)^2+(y2-y1)^2))
TABLE(15000+i,(y2-y1)/SQR((x2-x1)^2+(y2-y1)^2))
RETURN
cir_unit_vector:
x=TABLE(11000+i-1)
y=TABLE(13000+i-1)
x0=TABLE(11000+i-1)+VR(14000+i)
y0=TABLE(13000+i-1)+VR(15000+i)
r=SQR((y0-y)^2+(x0-x)^2)
IF VR(10000+i)=2 THEN r=-r
TABLE(14000+i,(y-y0)/r)
TABLE(15000+i,(x0-x)/r)
TABLE(18000+i,x0)'Remember the absolute coordinate of the cir center
TABLE(19000+i,y0)
x=TABLE(11000+i)
y=TABLE(13000+i)
TABLE(21000+i,(y-y0)/r)'Calculate the final point velocity vector of cir
TABLE(22000+i,(x0-x)/r)
RETURN
'***************************************
cutter_vector:
TABLE(16000+i,TABLE(15000+i)*(-d))
TABLE(17000+i,TABLE(14000+i)*d)
RETURN
'***************************************
velocity_setting:

RETURN
'***************************************
cutter_point_calculation:
DIM flag_of_cutter AS INTEGER'This is the flag to declare which kind of compensation to do
DIM alpha,value_of_cos AS FLOAT'Alpha is the angel of the two velocity
DIM compensated_x,compensated_z AS FLOAT
DIM xl1,yl1,xl2,yl2,xr1,yr1,r1,xr2,yr2,r2,delta,d1,distance_r1_r2 AS FLOAT'Store the coordinate values of the point
flag_of_cutter=0
IF (VR(10000+i)=0 AND VR(10000+i+1)=1) OR (VR(10000+i)=1 AND VR(10000+i+1)=1) THEN flag_of_cutter=1
IF (VR(10000+i)=1 AND VR(10000+i+1)=2) OR (VR(10000+i)=1 AND VR(10000+i+1)=3) THEN flag_of_cutter=2
IF (VR(10000+i)=2 AND VR(10000+i+1)=1) OR (VR(10000+i)=3 AND VR(10000+i+1)=1) THEN flag_of_cutter=3
IF (VR(10000+i)=2 AND VR(10000+i+1)=3) OR (VR(10000+i)=3 AND VR(10000+i+1)=2) THEN flag_of_cutter=4
IF (VR(10000+i)=2 AND VR(10000+i+1)=2) OR (VR(10000+i)=3 AND VR(10000+i+1)=3) THEN flag_of_cutter=4
IF flag_of_cutter<>3 AND flag_of_cutter<>4 THEN
    value_of_cos=TABLE(14000+i)*TABLE(14001+i)+TABLE(15000+i)*TABLE(15001+i)'calculate the Alpha
    value_of_sin=TABLE(14000+i)*TABLE(15001+i)-TABLE(14001+i)*TABLE(15000+i)
ELSEIF flag_of_cutter=3 OR flag_of_cutter=4 THEN
    value_of_cos=TABLE(21000+i)*TABLE(14001+i)+TABLE(22000+i)*TABLE(15001+i)
    value_of_sin=TABLE(21000+i)*TABLE(15001+i)-TABLE(14001+i)*TABLE(22000+i)
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
xl1=TABLE(14000+i)
yl1=TABLE(15000+i)
xl2=TABLE(14000+i+1)
yl2=TABLE(15000+i+1)
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
RETURN

shortening_line_to_cir:
d1=d
xl1=TABLE(14000+i)
yl1=TABLE(15000+i)
xl2=TABLE(14000+i+1)
yl2=TABLE(15000+i+1)
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
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
RETURN

shortening_cir_to_line:
d1=d
xl1=TABLE(14000+i+1)
yl1=TABLE(15000+i+1)
'xl2=TABLE(14000+i)
'yl2=TABLE(15000+i)
xr2=-TABLE(11000+i)+TABLE(18000+i)
yr2=-TABLE(13000+i)+TABLE(19000+i)
'r1=SQR((xl1-xr1)^2+(yl1-xr1)^2)
r2=SQR(xr2^2+yr2^2)
IF VR(10000+i)=3 THEN
    r2=-r2
ENDIF
delta=SQR((r2-d)^2-(xl1*yr2-yl1*xr2-d1)^2)
compensated_x=xl1*(xl1*xr2+yl1*yr2)-d1*yl1-SGN(xl1*xr2+yl1*yr2)*delta*xl1
compensated_z=yl1*(xl1*xr2+yl1*yr2)+d1*xl1-SGN(xl1*xr2+yl1*yr2)*delta*yl1
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,VR(10000+i))
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
RETURN

shortening_cir_to_cir:
xr1=TABLE(18000+i)-TABLE(11000+i)
yr1=TABLE(19000+i)-TABLE(13000+i)
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
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,VR(10000+i))
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
RETURN
'**********************
extension_line_to_line:
d1=d
xl1=TABLE(14000+i)
yl1=TABLE(15000+i)
xl2=TABLE(14000+i+1)
yl2=TABLE(15000+i+1)
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
RETURN

extension_line_to_cir:
d1=d
xl1=TABLE(14000+i)
yl1=TABLE(15000+i)
xl2=TABLE(14000+i+1)
yl2=TABLE(15000+i+1)
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(11000+i)+TABLE(16000+i+1))
TABLE(33000+ii,TABLE(13000+i)+TABLE(17000+i+1))
TABLE(30000+ii,1)
ii=ii+1
RETURN

extension_cir_to_line:
d1=d
TABLE(31000+ii,TABLE(11000+i)+TABLE(22000+i)*(-d))
TABLE(33000+ii,TABLE(13000+i)+TABLE(21000+i)*d)
TABLE(30000+ii,VR(10000+i))
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
r=SQR((TABLE(11000+i)-TABLE(18000+i))^2+(TABLE(13000+i)-TABLE(19000+i))^2)
IF VR(10000+i)=2 THEN r=-r
xl1=TABLE(21000+i)
yl1=TABLE(22000+i)
xl2=TABLE(14000+i+1)
yl2=TABLE(15000+i+1)
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
RETURN

extension_cir_to_cir:
d1=d
TABLE(31000+ii,TABLE(11000+i)+TABLE(22000+i)*(-d))
TABLE(33000+ii,TABLE(13000+i)+TABLE(21000+i)*d)
TABLE(30000+ii,VR(10000+i))
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
xl1=TABLE(21000+i)
yl1=TABLE(22000+i)
xl2=TABLE(14000+i+1)
yl2=TABLE(15000+i+1)
compensated_x=(xl2-xl1)*d/(xl1*yl2-xl2*yl1)
compensated_z=(yl2-yl1)*d/(xl1*yl2-xl2*yl1)
TABLE(31000+ii,compensated_x+TABLE(11000+i))
TABLE(33000+ii,compensated_z+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(11000+i)+TABLE(16000+i+1))
TABLE(33000+ii,TABLE(13000+i)+TABLE(17000+i+1))
TABLE(30000+ii,1)
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
RETURN
'**********************
insertion_line_to_line:
d1=d
TABLE(31000+ii,TABLE(16000+i)+ABS(d)*TABLE(14000+i)+TABLE(11000+i))
TABLE(33000+ii,TABLE(17000+i)+ABS(d)*TABLE(15000+i)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(16000+i+1)-ABS(d)*TABLE(14000+i+1)+TABLE(11000+i))
TABLE(33000+ii,TABLE(17000+i+1)-ABS(d)*TABLE(15000+i+1)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
RETURN

insertion_line_to_cir:
d1=d
TABLE(31000+ii,TABLE(16000+i)+ABS(d)*TABLE(14000+i)+TABLE(11000+i))
TABLE(33000+ii,TABLE(17000+i)+ABS(d)*TABLE(15000+i)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(16000+i+1)-ABS(d)*TABLE(14000+i+1)+TABLE(11000+i))
TABLE(33000+ii,TABLE(17000+i+1)-ABS(d)*TABLE(15000+i+1)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(11000+i)+TABLE(16000+i+1))
TABLE(33000+ii,TABLE(13000+i)+TABLE(17000+i+1))
TABLE(30000+ii,1)
ii=ii+1
RETURN

insertion_cir_to_line:
d1=d
TABLE(31000+ii,TABLE(11000+i)+TABLE(22000+i)*(-d))
TABLE(33000+ii,TABLE(13000+i)+TABLE(21000+i)*d)
TABLE(30000+ii,VR(10000+i))
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
TABLE(31000+ii,TABLE(22000+i)*(-d)+ABS(d)*TABLE(21000+i)+TABLE(11000+i))
TABLE(33000+ii,TABLE(21000+i)*d+ABS(d)*TABLE(22000+i)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(16000+i+1)-ABS(d)*TABLE(14000+i+1)+TABLE(11000+i))
TABLE(33000+ii,TABLE(17000+i+1)-ABS(d)*TABLE(15000+i+1)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
RETURN


insertion_cir_to_cir:
d1=d
TABLE(31000+ii,TABLE(11000+i)+TABLE(22000+i)*(-d))
TABLE(33000+ii,TABLE(13000+i)+TABLE(21000+i)*d)
TABLE(30000+ii,VR(10000+i))
TABLE(34000+ii,TABLE(18000+i))
TABLE(35000+ii,TABLE(19000+i))
ii=ii+1
TABLE(31000+ii,TABLE(22000+i)*(-d)+ABS(d)*TABLE(21000+i)+TABLE(11000+i))
TABLE(33000+ii,TABLE(21000+i)*d+ABS(d)*TABLE(22000+i)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(16000+i+1)-ABS(d)*TABLE(14000+i+1)+TABLE(11000+i))
TABLE(33000+ii,TABLE(17000+i+1)-ABS(d)*TABLE(15000+i+1)+TABLE(13000+i))
TABLE(30000+ii,1)
ii=ii+1
TABLE(31000+ii,TABLE(11000+i)+TABLE(16000+i+1))
TABLE(33000+ii,TABLE(13000+i)+TABLE(17000+i+1))
TABLE(30000+ii,1)
ii=ii+1
RETURN




