*MAPA EN SAS A NIVEL MUNICIPAL EN MÉXICO
***Primero creas una base annotate para poner los bordes de los estados. Creo que lo saqué de aquí
http://www.mwsug.org/proceedings/2013/DV/MWSUG-2013-DV06.pdf
;
goptions  cback=white htitle=12pt htext=10pt noborder ;  
 /* Create a data set named STATES that contains the state boundaries */
proc gremove data=mapsgfk.mexico  out=states;

  /* STATE is the new identification variable */
  by id1;

  /* STATE and COUNTY were the original identification variables */
  id id1 id;
run;
quit;

data states;
  set states;
  by id1;
  retain flag num 0;

  /* Reset the flag value for each state */
  if first.state then do;
     flag=0;
     num=0;
  end;

  /* Set the flag value when x and y are missing */
  if x=. and y=. then do;
    flag=1;
    num + 1;
    delete;
  end;

  /* Increment the segment value */
  if flag=1 then segment + num;
  drop flag num;
run;
data anno;
  length function color $8;
  retain xsys ysys '2' when 'a' color 'white' size 1;
  *drop xsave ysave;
  set states;
  by id1 segment;

  /* Move to the first coordinate */
  if first.segment then function='poly';
   
  /* Draw to each successive coordinate */
  else function='polycont';
  output;
run;



**sorteas la base anterior por id;
proc sort data=buro_id;
	by descending id;
run;


***************************************************************************************************
Empiezan los mapas;
***********************************************************************************************;
proc means data=work.buro_id (where=((periodo=201503) and numero>0 ));
	var numero;
	output out=percentiles_ (DROP=_FREQ_ _TYPE_)
		p25=p25
		p50=p50
		p75=p75	;
run;

data _null_;
	set percentiles_;
	format p25 8.
			p50 8.
			p75 8.;
	call symput('p25',round(p25,1));
	call symput('p50',round(p50,1));
	call symput('p75',round(p75,1));
run;
data _null_;
	call symput('pp25',trim(left(put(&p25/1,comma8.))));
	call symput('pp50',trim(left(put(&p50/1,comma8.))));
	call symput('pp75',trim(left(put(&p75/1,comma8.))));
run;

proc format;
	value percentiles_
		low - &p25 = "0 - &pp25"
		&p25 - &p50 = "&pp25 - &pp50"
		&p50 - &p75 = "&pp50 - &pp75"
		&p75 - high = "> &pp75"
	;
run;

PATTERN1 color=verylightred;
PATTERN2 color=lightred;
PATTERN3 color=red;
PATTERN4 color=darkred;
pattern5 color=morbr;
pattern6 color=black;
pattern7 color=black;

title "Número de créditos por municipio";

proc gmap
	map=mapsgfk.mexico 
	data=buro_id (where=(periodo=201503))
	all  ;
	id id;
	choro  numero /  description="" anno=anno discrete missing coutline=same cempty=white;
	format numero percentiles_.;
run;

quit;

*********************************************************************;
*Con esto ves cuáles son los cuartiles buenos;
proc means data=buro_id (where=((periodo=201503) and saldo>0 ));
	var saldo;
	output out=percentiles_saldo (DROP=_FREQ_ _TYPE_)
		p25=p25
		p50=p50
		p75=p75
	;
run;

data _null_;
	set percentiles_saldo;
	format p25 8.
			p50 8.
			p75 8.;
	call symput('p25',round(p25,10000));
	call symput('p50',round(p50,10000));
	call symput('p75',round(p75,10000));
run;
data _null_;
	call symput('pp25',trim(left(put(&p25/1000,comma8.))));
	call symput('pp50',trim(left(put(&p50/1000,comma8.))));
	call symput('pp75',trim(left(put(&p75/1000,comma8.))));
run;

title "Saldo de crédito por municipio";

proc format;
	value saldo_
		low - &p25 = "0 - &pp25"
		&p25 - &p50 = "&pp25 - &pp50"
		&p50 - &p75 = "&pp50 - &pp75"
		&p75 - high = "> &pp75"
	;
run;

PATTERN1 color=verylightred;
PATTERN2 color=lightred;
PATTERN3 color=red;
PATTERN4 color=darkred;
pattern5 color=morbr;
pattern6 color=black;
pattern7 color=black;

proc gmap
	map=mapsgfk.mexico 
	data=buro_id (where=(periodo=201503))
	all;
	id id;
	choro  saldo / anno=anno discrete missing coutline=same cempty=white;
	format saldo saldo_.;
run;

quit;
