/*  Extraemos los nuevos de 201605 */
proc sql;
	create table histograma_nuevos as
		select  periodo, rfc, id_cre_cnb, tipo, sum(respon) as respon, mean(linea) as sumlinea
			from sasuser.base_empresas
				where periodo=201605 and periodo=peri_alta and linea>0 and tipo = "PYME"
					group by periodo, rfc, id_cre_cnb, tipo;
quit;

* Identificamos a las  nuevas empresas del mes;
proc sort data=nuevas_empresas;
	by periodo rfc;
run;

data histograma_nuevos;
	merge histograma_nuevos (in=a) nuevas_empresas(in=b);
	by  periodo rfc;
	if a;
	if b then
		nueva="nueva";
	else nueva="exist";
;
run;

/* ahora vamos a transponer la base para crear los histogramas en una misma base */
proc sort data=histograma_nuevos;
	by nueva;
run;

proc transpose  data=histograma_nuevos out=interim;
	by nueva;
	var sumlinea;
run;

proc transpose data= interim out=paranuevos(drop=_name_);
	id nueva;
run;

data paranuevos;
	modify paranuevos;
	if exist >10000000 then
		exist=10000000;
	if nueva >10000000 then
		nueva=10000000;
	exist=exist/1000;
	nueva=nueva/1000;
	replace;
run;

ods graphics on  / reset noborder ;

proc sgplot data=paranuevos /*(where=(exist<5000000  and nueva<5000000))*/
	noborder;
	refline 20 to 100 by 20 / axis=y lineattrs=(pattern=4);  
	* density A / type=normal lineattrs=(color=red) legendlabel='A';
	* density B / type=normal lineattrs=(color=blue) legendlabel='B';
	histogram exist / binwidth=200 binstart=0 transparency=0.75 fillattrs=(color=blue) legendlabel='Existentes';
	histogram nueva / binwidth=200 binstart=0 transparency=0.75 fillattrs=(color=red) legendlabel='Nuevas empresas';
	keylegend   /  location=inside  position=topright down=2 noborder valueattrs=(family='calibri' size=12pt style=normal);
	xaxis discreteorder=data   label = "Montos de línea autorizada (en miles de pesos)" labelattrs=(family='calibri' size=11pt style=normal) valueATTRS=(family='calibri' size=12pt style=normal);
	yaxis    discreteorder=data label = "Por ciento"   labelattrs=(family='calibri' size=11pt style=normal) valueATTRS=(family='calibri' size=12pt style=normal);
format exist comma6.0 nueva comma6.0;
run;

/* Ahora procederemos a hacer las curvas de densidad acumulada */
*Primero con existentes;
proc sort data= paranuevos;
	by exist;
run;

data acumulados;
	set paranuevos end=ultimo;
	exist_acum+1;

	if ultimo then
		call symput('exist_sum', exist_acum);
run;

%put &exist_sum;

*Después con nuevas empresas;
proc sort data= acumulados;
	by nueva;
run;

data acumulados;
	set acumulados end=ultimo;

	if nueva ne . then
		nueva_acum+1;

	if ultimo then
		call symput('nueva_sum', nueva_acum);
run;

%put &nueva_sum;

*los normalizamos a 100;
data acumulados;
	modify acumulados;
	nueva_acum=nueva_acum/&nueva_sum*100;
	exist_acum=exist_acum/&exist_sum*100;
	replace;
run;

*Va la gráfica;
proc sgplot data=acumulados /*(where=(exist<5000000  and nueva<5000000))*/
	noborder;
	refline 20 to 100 by 20 / axis=y lineattrs=(pattern=4);    
	scatter	 x=exist y=exist_acum /  markerattrs=(symbol=circlefilled size=3 )  legendlabel='Existentes';
	scatter x=nueva y=nueva_acum /  markerattrs=(symbol=circlefilled size=3 ) legendlabel='Nuevas empresas';
	*density A / type=normal lineattrs=(color=red) legendlabel='A';
	* density B / type=normal lineattrs=(color=blue) legendlabel='B';
	*	histogram exist / binwidth=10 binstart=0 transparency=0.75 fillattrs=(color=red) legendlabel='Existentes';
	*histogram nueva / binwidth=10 binstart=0 transparency=0.75 fillattrs=(color=blue) legendlabel='Nuevas empresas';
	keylegend   / location=inside position=bottom down=2 noborder valueattrs=(family='calibri' size=12pt style=normal);
	xaxis discreteorder=data   label = "Montos de línea autorizada (en miles de pesos)" labelattrs=(family='calibri' size=11pt style=normal) valueATTRS=(family='calibri' size=12pt style=normal);
	yaxis  discreteorder=data label = "Por ciento"   labelattrs=(family='calibri' size=11pt style=normal) valueATTRS=(family='calibri' size=12pt style=normal);
format exist comma6.0 nueva comma6.0;
run;

/* Ahora sacamos los deciles de la distribución de los montos de los nuevos créditos*/
proc means data=histograma_nuevos noprint;
	var sumlinea;
	class nueva;
	output out=deciles(DROP=_FREQ_ _TYPE_)
		p1=per1
		p5=per5
		p10=per10 
		p25=per25
		p50=per50
		p75=per75
		p90=per90
		p95=per95
		p99=per99
		mean=promedio
	;
run
;

/* Se ve raro que aparezcan empresas viejas com oprimera vez en la base*/

/*
data nuevas_Edad;
set nuevas_empresas (where=(substr(rfc,1,1)="_"));
*edad=floor(intck('dtmonth',dhms(input(put(substr(rfc,anydigit(rfc),6),6.),YYMMDD.),0,0,0), dhms(input(periodo,YYYYMM.),0,0,0))/12);
periodo_fecha=put(periodo*100+1,YYMMDD.), date.);
RUN;
*/