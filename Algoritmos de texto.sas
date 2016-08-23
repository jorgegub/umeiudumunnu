*******************************************************************************************
********************Macro para codificar una palabra en n�meros****************************
*******************************************************************************************
Se regresa la base_salida como copia de la base_entrada, una columna llamada clave que indica 
la codificaci�n de la variable_a_codificar y otra llamada sin_acronimos_variable_a_codificar 
que es lo que se usa para calcular el compged (la distancia entre dos palabras)*
*******************************************************************************************;
options mprint; *En el log aparecen las sustituciones que la macro hace;
%macro codificacion(base_entrada=, base_salida=, variable_a_codificar=);
%if "&base_entrada" NE "" or "&base_salida" NE "" or "&variable_a_codificar" NE "" %then 
%do;
data tmp;
set &base_entrada;
palabra_mod=&variable_a_codificar;
*Pone palabra en may�sculas;
palabra_mod=upcase(palabra_mod);
*Quita espacios al principio y final;
palabra_mod=STRIP(palabra_mod);
/*Pone un espacio al principio y al final;*/
palabra_mod=CAT(" ",palabra_mod," "); 
*Cambia car�cteres "�����������" por "AEIOUAEIOUU";
palabra_mod=TRANSLATE(palabra_mod,"AEIOUAEIOU" , "����������");
*Remueve signos de puntuaci�n, se queda s�lo con las letras y espacios;
palabra_mod=COMPRESS(palabra_mod,"ABCDEFGHIJKLMNOPQRSTUVWXYܥ��� Z","K"); 
*Quita SA, CV, LA, EN, DEL, Y,...;
palabra_mod=TRANWRD(palabra_mod," S DE RL ","");
palabra_mod=TRANWRD(palabra_mod," S DE R L ","");
palabra_mod=TRANWRD(palabra_mod," DE ", "");
palabra_mod=TRANWRD(palabra_mod," DEL ","");
palabra_mod=TRANWRD(palabra_mod," CV ","");
palabra_mod=TRANWRD(palabra_mod," SA ","");
palabra_mod=TRANWRD(palabra_mod," RL ","");
palabra_mod=TRANWRD(palabra_mod," SC ","");
palabra_mod=TRANWRD(palabra_mod," CO ","");
palabra_mod=TRANWRD(palabra_mod," DECV ","");
palabra_mod=TRANWRD(palabra_mod," SACV ","");
palabra_mod=TRANWRD(palabra_mod," INC ","");
palabra_mod=TRANWRD(palabra_mod,"G�","W");
palabra_mod=TRANWRD(palabra_mod,"LL","Y");
palabra_mod=TRANWRD(palabra_mod,"RR","R");
palabra_mod=TRANWRD(palabra_mod,"�","�");
palabra_mod=TRANWRD(palabra_mod,"�","NY");
palabra_mod=TRANWRD(palabra_mod,"�","�");
palabra_mod=TRANWRD(palabra_mod,"�","�");
palabra_mod=TRANWRD(palabra_mod," AC ","");
palabra_mod=TRANWRD(palabra_mod," IAP ","");
palabra_mod=TRANWRD(palabra_mod," S A ","");
palabra_mod=TRANWRD(palabra_mod," D E ","");
palabra_mod=TRANWRD(palabra_mod," C V ","");
palabra_mod=TRANWRD(palabra_mod," R L ","");
palabra_mod=TRANWRD(palabra_mod," I A P ","");
palabra_mod=TRANWRD(palabra_mod," A C ","");
palabra_mod=TRANWRD(palabra_mod," SAPI ","");
palabra_mod=TRANWRD(palabra_mod," SPR ","");
palabra_mod=TRANWRD(palabra_mod," S P R ","");

sin_acronimos_&variable_a_codificar=STRIP(palabra_mod); *variable con la que se calcula el compged;

palabra_mod=TRANWRD(palabra_mod," Y ","");
palabra_mod=TRANWRD(palabra_mod," LA ","");
palabra_mod=TRANWRD(palabra_mod," EN ","");
palabra_mod=TRANWRD(palabra_mod," EL ","");
palabra_mod=TRANWRD(palabra_mod," SAN ","");
palabra_mod=TRANWRD(palabra_mod," PARA ","");
palabra_mod=TRANWRD(palabra_mod," LOS ","");
palabra_mod=TRANWRD(palabra_mod," AND ","");
palabra_mod=TRANWRD(palabra_mod," LAS ","");
palabra_mod=TRANWRD(palabra_mod," SUR ","");
palabra_mod=TRANWRD(palabra_mod," ES ","");
palabra_mod=TRANWRD(palabra_mod," AL ","");
palabra_mod=TRANWRD(palabra_mod," OS ","");
palabra_mod=TRANWRD(palabra_mod," AC ","");
palabra_mod=TRANWRD(palabra_mod," AS ","");
palabra_mod=TRANWRD(palabra_mod," MI ","");
palabra_mod=TRANWRD(palabra_mod," IN ","");
palabra_mod=TRANWRD(palabra_mod," DON ","");
palabra_mod=TRANWRD(palabra_mod," THE ","");
palabra_mod=TRANWRD(palabra_mod," SE ","");
*Quita todos los espacios;
palabra_mod=COMPRESS(palabra_mod);
run;

*Quita la letra H al principio de una palabra;
*Se unifican letras con sonido similar;
proc sql;
create table tmp0 as
select *,
case 
when substr(palabra_mod,1,1)="H" then substr(palabra_mod,2)
else palabra_mod
end as palabra_mod0
from tmp;
quit;

proc sql;
create table tmp2 as
select *,
case
when substr(palabra_mod0,1,1)="Z" then TRANWRD(substr(palabra_mod0,1,1),"Z","S")||substr(palabra_mod0,2)
when substr(palabra_mod0,1,1)="X" then TRANWRD(substr(palabra_mod0,1,1),"X","S")||substr(palabra_mod0,2)
when substr(palabra_mod0,1,1)="G" and substr(palabra_mod0,2,1) IN ("E","I") then TRANWRD(substr(palabra_mod0,1,1),"G","J")||substr(palabra_mod0,2)
when substr(palabra_mod0,1,1)="C" and not(substr(palabra_mod0,2,1) IN ("E","I","H")) then TRANWRD(substr(palabra_mod0,1,1),"C","K")||substr(palabra_mod0,2)
else palabra_mod0
end as palabra_mod2
from tmp0;
quit;

*Se parte la palabra en la primera letra y el resto;
*Se quitan vocales y la w de la parte resto de la palabra;
*Se codifica la parte resto dando valores a las letras;
*Se obtiene la clave de la palabra concatenando la primera letra y la codificaci�n que se hizo de la parte resto;
data &base_salida (drop= palabra_mod0 palabra_mod palabra_mod2 primera resto nume);
set tmp2;
primera=substr(palabra_mod2,1,1);
resto=substr(palabra_mod2,2);
resto=COMPRESS(resto,"AEIOUW");
nume=TRANSLATE(resto, "0112_3!4444-56677889","PBVFHTDSZCXYLNMQKGJR");
clave=CATS(primera,nume);
run;

proc delete data=tmp0 tmp tmp2;
run;

%end;
%do;
%put alg�n dato no fue proporcionado, no se hizo la codificaci�n;
%end;
%mend codificacion;


*******************************************************************************************
*******************************************************************************************
*******Macro para encontrar las coincidencias por clave de dos bases ya codificadas********
***************Estas bases deben tener s�lo la clave como columna en com�n*****************
****************de lo contrario se unifican las columnas con nombre igual******************
*******************************************************************************************
*******************************************************************************************;
*var_compged_base1 y var_compged_base2 son las variables SIN_ACRONIMOS que aparecen en la base_salida de la codificacion;

%macro matches(nombre_base1=,nombre_base2=,base_salida=, var_compged_base1=, var_compged_base2=, distancia=);
%if "&nombre_base1" NE "" or "&nombre_base2" NE "" or "&base_salida" NE "" or "&var_compged_base1" NE "" or "&var_compged_base2" NE ""%then 
%do;
*Se ordena la nombre_base1 que se obtuvo de la codificaci�n;
proc sort data=&nombre_base1;
by clave;
run;
*Se ordena la nombre_base2 que se obtuvo de la codificaci�n;
proc sort data=&nombre_base2;
by clave;
run;
*Se juntan las listas codificadas y se asigna "match" para aquellos nombres que aparecen en ambas listas y tienen la misma clave;
data &base_salida;
MERGE &nombre_base1 (IN=A) &nombre_base2 (IN=B);
if A then base="&nombre_base1"; 
if B then base="&nombre_base2";
if A and B then base="match";
by clave;
dist_ged=compged(&var_compged_base1,&var_compged_base2);
dist_lev=complev(&var_compged_base1,&var_compged_base2);
run;

*Se hace una lista con las empresas que tienen un 
compged (distancia generalizada entre dos palabras) menor a 200; 
data &base_salida (drop= &var_compged_base1 &var_compged_base2 /*clave*/ base);
set &base_salida;
if (dist_ged<=&distancia and dist_lev<=4 and base="match");
run;

%end;
%else
%do;
%put alg�n dato no fue proporcionado, no se construy� la tabla final;
%end;

%mend matches;


*******************************************************************************************
*******************************************************************************************
***************Macro para obtener los n�meros dentro de una variable***********************
*******************************************************************************************
**Se obtiene la base_salida como una copia de la base_entrada y una columna llamada token que 
muestra un n�mero dentro del nombre, la variable_con_numeros se presentara tantas veces como 
los n�meros que tenga***********************************************************************;

%macro obtener_numeros(base_entrada=,base_salida=,variable_con_numeros=);
data &base_entrada;
set &base_entrada;
*Se queda s�lo con digitos y espacios;
num=COMPRESS(&variable_con_numeros,,"KDS");
*Remueve espacios al principio y al final;
num=STRIP(num);
*Reemplaza todas las ocurrencias de dos o mas espacios por uno;
num=COMPBL(num);
*Pone un espacio al principio del n�mero;
num=CAT(" ",num);
*Se quitan ceros que aparecen a la izquierda;
num=TRANWRD(num," 00","");
num=TRANWRD(num," 0","");
run;

*(keep=token nombre_r04 rfc);
data &base_salida; 
set &base_entrada;
*Se lee cada n�mero separado por un espacio y se hace una lista con los n�meros;
*Se asume que ning�n la variable_con_numeros no tiene en su nombre m�s de 10 n�meros;
do I=1 to 10;
token=scan(num, I, ' ');
if token=' ' then goto finish;
if length(trim(token))<1 then goto skip;
output &base_salida;
skip: ;
end;
finish: ;
run;

*Se ordena la lista de n�meros obtenida;
proc sort data=&base_salida (drop=num I);
by token;
run;
%mend obtener_numeros;


*******************************************************************************************
*******************************************************************************************
*Macro para coincidencias exactas en %campo, no es necesario que las bases esten ordenadas*
*******************************************************************************************
*******************************************************************************************;
%macro coincidencias(nombre_base1=, nombre_base2=, nombre_base_salida=, campo=);
%if "&nombre_base1" NE "" or "&nombre_base2" NE "" or "&nombre_base_salida" NE "" %then 
%do;
proc sort data=&nombre_base1;
by &campo;
run;

proc sort data=&nombre_base2;
by &campo;
run;

data &nombre_base_salida;
merge &nombre_base1 (IN=A) &nombre_base2 (IN=B);
if A and B;
by &campo;
run;
%end;
%else
%do;
%put alguna base de datos no fue proporcionada, las coincidencias no fueron encontradas;
%end;

%mend coincidencias;

*******************************************************************************************
*******************************************************************************************
***********Macro para quitar duplicados, el campo puede ser mas de una variable************
*******************************************************************************************
*******************************************************************************************;

%macro no_dup(nombre_base=,nombre_base_salida=, campo=);
proc sort data=&nombre_base nodupkey out=&nombre_base_salida;
by &campo;
run;
%mend no_dup;


**************************************************************************************************************************************************
*************************Obtiene la frecuencia de cada palabra de la base de datos y se queda con las que se repiten almenos 2 veces****************;
**************************************************************************************************************************************************;
/*
data token(keep=token);
set palabras;
do I=1 to 100;
token=scan(palabra_mod, I, ' ');
if token=' ' then goto finish;
if length(trim(token))<2 then goto skip;
output token;
skip: ;
end;
finish: ;
run;

proc sort data=token out=token;
by token;
run;

data token;
set token;
by token;
if first.token and last.token then delete;
run;

proc freq data=token;
tables token / missing out=freq noprint;
run;

proc print data=freq;
run;