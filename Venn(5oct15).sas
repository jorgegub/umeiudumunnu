/* En este programa utilizamos dos macros para calcular
1) el número de elementos para cada sección de un diagrama de ven dado y
2) una macro que utiliza los datos obtenidos por la primera para que la gráfica deseada se grafique 
proporcionalmente al tamaño de la sección en google analytics. Ojo: Ya cambió un poco la macro respecto 
a la original que encontré en un paper. 
Representa una recopilación de dos macros que encontré en internet.*/

proc sql;
create table base_trans3 as
select numero_expediente as id, sum(cc) as a, sum(au) as b, sum(pn,pl) as c
from docume.base_trans
group by numero_expediente;
quit;


/* Venn Diagram Macro */
/*
data data;
call streaminit(123);
do i = 1 to 1000;
id = i;
A = RAND('UNIFORM');
B = RAND('UNIFORM');
C = RAND('UNIFORM');
D = RAND('UNIFORM');
output;
end;
*/
run;
%macro venn( data =
,venn_diagram = 3 /* Select whether you want a 2 Way, 3 Way or 4 Way Venn Diagram. EG for 2
way enter 2. Valid values are 2,3 and 4 */
,cutoff = ne missing /* Set the P Value cut-off or any other appropriate cut off
Valid values are the right hand side of an if statement */
,GroupA = TdC /* Define group name 1, mandatory */
,GroupB = Automotriz /* Define group name 2, mandatory */
,GroupC = NyP /* Define group name 3, mandatory for 3 and 4 way diagrams */
,GroupD = Treatment D /* Define group name 4, mandatory for 4 way diagrams */
,out_location = C:\Users\J13246\Desktop\
/* Define the path for all output files e.g. C:\Venn Diagrams */
,outputfilename = Venn diagram Test /* Define the filename for the graphic file */
,drilldownfilename = Drilldown
/* Define the filename for the drill down data file */
);
/* Calculate the category for each observation in the dataset
 This has to be done differently for 2,3 and 4 way diagrams */
data data_reformatted;
 set &data;
run;
/* Counting the overlap */
data data_reformatted2;
set data_reformatted;
%IF &venn_diagram = 2 %THEN %DO;
if A ne . and B ne . then do;
if A &cutoff and B &cutoff then AB = 1;
else AB = 0;
end;
if A ne . then do;
if A &cutoff and AB ne 1 then A1 = 1; else A1 = 0;
end;
if B ne . then do;
if B &cutoff and AB ne 1 then B1 = 1; else B1 = 0;
end;
%end;
%ELSE %IF &venn_diagram = 3 %THEN %DO;
if A ne . and B ne . and C ne . then do;
if A &cutoff and B &cutoff and C &cutoff then ABC = 1;
else ABC = 0;
end;
if A ne . and B ne . then do;
if A &cutoff and B &cutoff and ABC ne 1 then AB = 1;
else AB = 0;
end;
if A ne . and C ne . then do;
if A &cutoff and C &cutoff and ABC ne 1 then AC = 1;
else AC = 0;
end;
if B ne . and C ne . then do;
if B &cutoff and C &cutoff and ABC ne 1 then BC = 1;
else BC = 0;
end;
if A ne . then do;
if A &cutoff and AB ne 1 and AC ne 1 and ABC ne 1 then A1 = 1;
else A1 = 0;
end;
if B ne . then do;
if B &cutoff and AB ne 1 and BC ne 1 and ABC ne 1 then B1 = 1;
else B1 = 0;
end;
if C ne . then do;
if C &cutoff and AC ne 1 and BC ne 1 and ABC ne 1 then C1 = 1;
else C1 = 0;
end;
%END;
%ELSE %IF &venn_diagram=4 %THEN %DO;
if A ne . and B ne . and C ne . and D ne . then do;
if A &cutoff and B &cutoff and C &cutoff and D &cutoff then ABCD = 1;
else ABCD = 0;
end;
if A ne . and B ne . and C ne . then do;
if A &cutoff and B &cutoff and C &cutoff and ABCD ne 1 then ABC = 1;
else ABC = 0;
end;
if A ne . and B ne . and D ne . then do;
if A &cutoff and B &cutoff and D &cutoff and ABCD ne 1 then ABD = 1;
else ABD = 0;
end;
if A ne . and C ne . and D ne . then do;
if A &cutoff and C &cutoff and D &cutoff and ABCD ne 1 then ACD = 1;
else ACD = 0;
end;
if B ne . and C ne . and D ne . then do;
if B &cutoff and C &cutoff and D &cutoff and ABCD ne 1 then BCD = 1;
else BCD = 0;
end;
if A ne . and B ne . then do;
if A &cutoff and B &cutoff and ABC ne 1 and ABD ne 1 and ABCD ne 1 then AB = 1;
else AB = 0;
end;
if A ne . and C ne . then do;
if A &cutoff and C &cutoff and ABC ne 1 and ACD ne 1 and ABCD ne 1 then AC = 1;
else AC = 0;
end;
if A ne . and D ne . then do;
if A &cutoff and D &cutoff and ABD ne 1 and ACD ne 1 and ABCD ne 1 then AD = 1;
else AD = 0;
end;
if B ne . and C ne . then do;
if B &cutoff and C &cutoff and ABC ne 1 and BCD ne 1 and ABCD ne 1 then BC = 1;
else BC = 0;
end;
if B ne . and D ne . then do;
if B &cutoff and D &cutoff and ABD ne 1 and BCD ne 1 and ABCD ne 1 then BD = 1;
else BD = 0;
end;
if C ne . and D ne . then do;
if C &cutoff and D &cutoff and ACD ne 1 and BCD ne 1 and ABCD ne 1 then CD = 1;
else CD = 0; 
end;
if A ne . then do;
if A &cutoff and AB ne 1 and AC ne 1 and AD ne 1 and ABC ne 1 and ABD ne 1 and ACD ne 1
and ABCD ne 1 then A1 = 1; else A1 = 0;
end;
if B ne . then do;
if B &cutoff and AB ne 1 and BC ne 1 and BD ne 1 and ABC ne 1 and ABD ne 1 and BCD ne 1
and ABCD ne 1 then B1 = 1; else B1 = 0;
end;
if C ne . then do;
if C &cutoff and AC ne 1 and BC ne 1 and CD ne 1 and ABC ne 1 and ACD ne 1 and BCD ne 1
and ABCD ne 1 then C1 = 1; else C1 = 0;
end;
if D ne . then do;
if D &cutoff and AD ne 1 and BD ne 1 and CD ne 1 and ABD ne 1 and ACD ne 1 and BCD ne 1
and ABCD ne 1 then D1 = 1; else D1 = 0;
end;
%END;
run;
/*
COUNTING THE ELEMENTS IN EACH GROUP
After the Macro identifies the elements in each group it uses PROC UNIVARIATE
to sum up the number of elements in each group.
The total number of element within the diagram i.e. the union of Groups A, B, C,
and D, and the total number of elements in the dataset i.e. the universal set are
then calculated. This is used to identify the number of elements that fall outside the union.
*/
proc univariate data = Data_reformatted2 noprint;
var AB A1 B1
%if &venn_diagram > 2 %then %do;
ABC AC BC C1
%end;
%if &venn_diagram > 3 %then %do;
ABCD ABD ACD BCD AD BD CD D1
%end;
;
output out = data_sum sum = sum_AB sum = sum_A1 sum = sum_B1
%if &venn_diagram > 2 %then %do;
sum = sum_ABC sum = sum_AC sum = sum_BC sum = sum_C1
%end;
%if &venn_diagram > 3 %then %do;
sum = sum_ABCD sum = sum_ABD sum = sum_ACD
sum = sum_BCD sum = sum_AD sum = sum_BD
sum = sum_CD sum = sum_D1
%end;
;
run;
/* Counting the number in the universal set */
proc sql noprint;
create table id_count as
select count(id) as count_id
from data_reformatted;
quit;
/* Counting the number inside the union */
data data_sum2;
set data_sum;
totalinside = sum(sum_AB, sum_A1, sum_B1
%if &venn_diagram > 2 %then %do;
,sum_ABC, sum_AC, sum_BC, sum_C1
%end;
%if &venn_diagram > 3 %then %do;
,sum_ABCD, sum_ABD, sum_ACD, sum_BCD, sum_AD,
sum_BD, sum_CD, sum_D1
%end;
);
run;
/*
COUNTING THE ELEMENTS THAT FALL OUTSIDE OF THE UNION
Using the fetch function the values of the total number of elements within the
union and the universal set are fetched from the appropriate datasets and assigned
to a macro-variable. The total number of elements that fall outside the diagram is
then calculated by using %eval to evaluate the arithmetic expression of the number
of elements in the universal set - the number of elements within the union.
*/
/* Calculating the total number of unique ids - so that I can calculate
the number that falls outside of the groups*/
proc sql noprint;
select count_id into: TN
from id_count;
quit;
/* Calculating the total number of values that fall within the groups */
proc sql noprint;
select totalinside into: TI
from data_sum2;
quit;
/* Calculating the total numbers that fall outside all of the groups */
%let TO = %eval(&TN - &TI);
/* Assigning the sums to macro variables */
proc sql noprint;
select sum_A1, sum_B1, sum_AB into :A, :B, :AB
from data_sum2;
quit;
%if &venn_diagram > 2 %then %do;
proc sql noprint;
select sum_C1, sum_AC, sum_BC, sum_ABC into :C, :AC, :BC, :ABC
from data_sum2;
quit;
%end;
%if &venn_diagram > 3 %then %do;
proc sql noprint;
select sum_D1, sum_AD, sum_BD, sum_CD, sum_ABD, sum_ACD, sum_BCD, sum_ABCD into :D, :AD,
:BD, :CD, :ABD, :ACD, :BCD, :ABCD
from data_sum2;
quit;
%end;
/* The rest of the macro needs to be done seperately for 2, 3 and 4
way plots */
data test;
do x = 1 to 100;
y = x;
output;
end;
run;
/*************** 2 WAY VENN DIAGRAMS ***************/
%if &venn_diagram=2 %then %do;
proc template;
define statgraph Venn2Way;
 begingraph / drawspace=datavalue;
/* Plot */
 layout overlay / yaxisopts = (display = NONE) xaxisopts = (display = NONE);
 scatterplot x=x y=y / markerattrs=(size = 0);
/* Venn Diagram (Circles) */
 drawoval x=36 y=50 width=45 height=60 /
 display=all fillattrs=(color=red)
 transparency=0.75 WIDTHUNIT= Percent HEIGHTUNIT= Percent;
drawoval x=63 y=50 width=45 height=60 /
 display=all fillattrs=(color=green)
 transparency=0.75 WIDTHUNIT= Percent HEIGHTUNIT= Percent;
/* Numbers */
 drawtext "&A" / x=33 y=50 anchor=center;
drawtext "&AB" / x=50 y=50 anchor=center;
drawtext "&B" / x=66 y=50 anchor=center;
drawtext "Outside Union - &TO" / x=50 y=10 anchor=center width = 30;
/* Labels */
drawtext "&GroupA" / x=30 y=15 anchor=center width = 30;
drawtext "&GroupB" / x=70 y=15 anchor=center width = 30;
 endlayout;
 endgraph;
 end;
run;
ods graphics on / reset = all border = off width=16cm height=12cm imagefmt = png imagename =
"&outputfilename";
ods listing gpath = "&out_location" image_dpi = 200;
proc sgrender data=test template=Venn2Way;
run;
ods listing close;
ods graphics off;
%end;
/*************** 3 WAY VENN DIAGRAMS ***************/
%if &venn_diagram = 3 %then %do;
proc template;
define statgraph Venn3Way;
 begingraph / drawspace=datavalue;
/* Plot */
 layout overlay / yaxisopts = (display = NONE) xaxisopts = (display = NONE);
 scatterplot x=x y=y / markerattrs=(size = 0);
/* Venn Diagram (Circles) */
 drawoval x=37 y=40 width=45 height=60 /
 display=all fillattrs=(color=red)
 transparency=0.75 WIDTHUNIT= Percent HEIGHTUNIT= Percent;
drawoval x=63 y=40 width=45 height=60 /
display=all fillattrs=(color=green)
 transparency=0.75 WIDTHUNIT= Percent HEIGHTUNIT= Percent;
 drawoval x=50 y=65 width=45 height=60 /
 display=all fillattrs=(color=blue)
 transparency=0.75 WIDTHUNIT= Percent HEIGHTUNIT= Percent;
/* Numbers */
drawtext "&A" / x=32 y=35 anchor=center;
drawtext "&AB" / x=50 y=30 anchor=center;
drawtext "&B" / x=68 y=35 anchor=center;
drawtext "&ABC" / x=50 y=50 anchor=center;
drawtext "&AC" / x=37 y=55 anchor=center;
drawtext "&BC" / x=63 y=55 anchor=center;
drawtext "&C" / x=50 y=75 anchor=center;
drawtext "Outside Union - &TO" / y=3 x=50 anchor=center width = 30;
/* Labels */
drawtext "&GroupA" / x=30 y=7 anchor=center width = 30;
drawtext "&GroupB" / x=70 y=7 anchor=center width = 30;
drawtext "&GroupC" / x=50 y=98 anchor=center width = 30;
endlayout;
endgraph;
end;
run;
ods graphics on / reset = all border = off width=16cm height=12cm imagefmt = png imagename =
"&outputfilename";
ods listing gpath = "&out_location" image_dpi = 200;
proc sgrender data=test template=Venn3Way;
run;
ods listing close;
ods graphics off;
%end;
/*************** 4 WAY VENN DIAGRAMS ***************/
%if &venn_diagram = 4 %then %do;
proc template;
define statgraph Venn4Way;
begingraph / drawspace=datavalue;
/* Plot */
layout overlay / yaxisopts = (display = NONE) xaxisopts = (display = NONE);
scatterplot x=x y=y / markerattrs=(size = 0);
/* Venn Diagram (Ellipses) */
drawoval x=28 y=39 width=26 height=100 /
display=all fillattrs=(color=red transparency=0.85)
outlineattrs=(color=red) transparency=0.50
WIDTHUNIT= Percent HEIGHTUNIT= Percent rotate = 45 ;
drawoval x=72 y=39 width=26 height=100 /
display=all fillattrs=(color=green transparency=0.85)
outlineattrs=(color=green) transparency=0.50
WIDTHUNIT= Percent HEIGHTUNIT= Percent rotate = 315 ;
drawoval x=57 y=54 width=26 height=100 /
display=all fillattrs=(color=blue transparency=0.85)
outlineattrs=(color=blue) transparency=0.50
WIDTHUNIT= Percent HEIGHTUNIT= Percent rotate = 335 ;
drawoval x=43 y=54 width=26 height=100 /
display=all fillattrs=(color=yellow transparency=0.85)
outlineattrs=(color=yellow) transparency=0.50
WIDTHUNIT= Percent HEIGHTUNIT= Percent rotate = 25 ;
/* Numbers */

drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&A" / x=13
y=60 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&B" / x=35
y=80 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&C" / x=65
y=80 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&D" / x=87
y=60 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&AB" / x=36
y=45 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&AC" / x=41
y=16 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&AD" / x=50
y=6 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&BC" / x=50
y=55 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&BD" / x=59
y=16 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&CD" / x=64
y=45 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&ABC" / x=43
y=30 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&BCD" / x=57
y=30 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&ACD" / x=46
y=12 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&BCD" /
x=52 y=12 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 6pt weight = bold) "&ABCD" /
x=50 y=21 anchor=center;
drawtext textattrs = GRAPHVALUETEXT(size = 7pt weight = bold) "Outside
Union - &TO" / x=70 y=5 anchor=center width = 30;
/* Labels */
drawtext textattrs = GRAPHVALUETEXT(size = 7pt weight = bold) "&GroupA" / x=6
y=20 anchor=center width = 30;
drawtext textattrs = GRAPHVALUETEXT(size = 7pt weight = bold) "&GroupB" / x=6
y=85 anchor=center width = 30;
drawtext textattrs = GRAPHVALUETEXT(size = 7pt weight = bold) "&GroupC" / x=82
y=85 anchor=center width = 30;
drawtext textattrs = GRAPHVALUETEXT(size = 7pt weight = bold) "&GroupD" / x=82
y=20 anchor=center width = 30;
endlayout;
endgraph;
end;
run;
ods graphics on / reset = all border = off width=16cm height=12cm imagefmt = png imagename =
"&outputfilename";
ods listing gpath = "&out_location" image_dpi = 200;
proc sgrender data=test template=Venn4Way;
run;
ods listing close;
ods graphics off;
%end;
%mend venn;
/* Example macro calls to produce 2,3 and 4 way diagrams */
%venn( data = work.base_trans3);

data _null_;
set data_sum2;
call symput('a',sum_a1/totalinside*100);
call symput('b',sum_b1/totalinside*100);
call symput('c',sum_c1/totalinside*100);
call symput('ab',sum_ab/totalinside*100);
call symput('ac',sum_ac/totalinside*100);
call symput('bc',sum_bc/totalinside*100);
call symput('abc',sum_abc/totalinside*100);
run;

%macro VennChart (size, type, col1, col2, col3, dat1, dat2, dat3, dat4, dat5, dat6,
 dat7, lab1, lab2, lab3,coll);
data _null_;
file 'C:\Users\XXXX\Desktop\VENN.html';
 put '<img src="http://chart.googleapis.com/chart?chs='"&size."'&cht='"&type."'&chco='"&col1."','"&col2."','"&col3."'&chd=t:'"&dat1."','"&dat2."','"&dat3."','"&dat4."','"&dat5."','"&dat6."','"&dat7."'&chdl='"&lab1."'|'"&lab2."'|'"&lab3."'"width="500" height="500" alt="" />';
  run;
 %mend VennChart;
 %VennChart (500x500,v,FF6342,ADDE63,63C6DE,&A.,&B.,&C.,&AB.,&AC.,&BC.,&ABC.,TdC,Automotriz,NyP);
 
%put &A.,&B.,&C.,&AB.,&AC.,&BC.,&ABC.;
/*
chdls=0000CC,14*/
