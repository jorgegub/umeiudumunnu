************************************************************************************
Ahora ponemos el código que encontramos en SAS communities
https://communities.sas.com/t5/General-SAS-Programming/Estimate-transition-probability-matrix/m-p/228510/highlight/true#M33589
Estima una matriz de transición de un panel balanceado. Similar al XTTRANS de stata.
************************************************************************************;
data  ssd_pf.colapsada_buro_4;
	set ssd_pf.colapsada_buro_4;
	rename estado=group;
run;

proc sql;
	create table trans as
		select a.group as from, b.group as to, count(*) as nTrans
			from ssd_pf.colapsada_buro_4 as a inner join ssd_pf.colapsada_buro_4 as b
				on a.numero_expediente=b.numero_expediente and a.id_time+1 = b.id_time
			group by a.group, b.group;
	create table probs as 
		select from, to, nTrans/sum(nTrans) as prob
			from trans
				group by from;
quit;


proc sql;
	create table trans2 as
		select a.group as from, b.group as to, count(*) as nTrans, b.id_time as period
			from ssd_pf.colapsada_buro_4 as a inner join ssd_pf.colapsada_buro_4 as b
				on a.numero_expediente=b.numero_expediente and a.id_time+1 = b.id_time
			group by a.group, b.group, b.id_time;
	create table probs2 as 
		select from, to, nTrans/sum(nTrans) as prob, period
			from trans2
				group by from, period;
quit;



proc transpose data=probs out=transTable(drop = _name_) prefix=to_;
	by from;
	id to;
	var prob;
run;

/* reorder variables, assign format to probabilities (optional) */
data transTable;
	retain from to_0-to_3;
	format to_0-to_3 pvalue5.3;
	set transTable;
run;

proc print data=transTable noobs;
run;
