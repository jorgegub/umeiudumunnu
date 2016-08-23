/*
As stata's fillin, this query adds observations with missing data so that all interactions of varlist exist, thus making a complete rectangularization of varlist.
*/

%let data= ssd_pf.colapsada_buro_3;
%let id= numero_expediente;
%let id_time=ClienEndFechaCorte;
%let variable_edo=estado;
proc sql;
	create table &data as
		select a.*,b.&variable_edo 
			from (select * from (select distinct &id from &data),(select distinct &id_time from &data))     as a 
            natural	left join &data as b 
					order by &id,&id_time;
quit;
