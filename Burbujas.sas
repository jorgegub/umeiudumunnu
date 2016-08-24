/* Aquí creamos unas gráfica de burbujas acompañada de una gráfica de líneas. 
Nos ayuda a ver la dispersión de una variable y el peso de sus componente, a la vez.
http://support.sas.com/resources/papers/proceedings10/154-2010.pdf*/
*Modificas la base;
proc sort data=grandes_altas;by periodo;run;
data graficar;
	set grandes_altas;
where periodo>=201002;
	*if grupo ne "";
	if saldo_altas<3e9 then
		grupo="";
	grupobis=substr(grupo,1,20);
run;

*Creas una variable dummy de tiempo;
data graficar;
	set graficar;
	uno=1;
	by periodochar;
	retain id_tiempo 0;

	if first.periodochar then
		id_tiempo=id_tiempo+1;
run;

TITLE1 "Tasa de interés de nuevos créditos a las empresas emisoras";
FOOTNOTE;
ods graphics on  / reset noborder;


PROC sGPLOT DATA = WORK.graficar noborder noautolegend;
	*refline 2 to 16 by 2 / axis=y lineattrs=(pattern=4);
SERIES X=periodochar	Y=TPP_ALTAS_SISTEMA / LINEATTRS=(color=blue thickness=3 );
	BUBBLE x=periodochar y=tpp_altas	size=saldo_altas 
		/ bradiusmin=0  transparency=.8 nooutline  fillattrs=(color=dargr ) /* datalabel=grupobis datalabelattrs=( family='calibri' size=8pt style=normal) */;
*	scatter x=periodochar y=tpp_altas / datalabel=grupobis markerattrs=(size=0) splitchar="-" splitjustify=left 
		datalabelattrs=( family='calibri' size=7pt style=normal );
	/*	keylegend   / location=inside position=topright down=2 noborder valueattrs=(family='calibri' size=12pt style=normal)*/;
	xaxis     fitpolicy=rotatethin   label = "Período" labelattrs=(family='calibri' size=11pt style=normal) valueATTRS=(family='calibri' size=12pt style=normal ) ;
	yaxis  grid gridattrs=(color=liggr pattern=4)  max=12 integer  discreteorder=data label = "Por ciento"   labelattrs=(family='calibri' size=11pt style=normal) valueATTRS=(family='calibri' size=12pt style=normal);
RUN;
QUIT;
