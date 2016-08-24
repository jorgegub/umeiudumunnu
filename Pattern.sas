
****************************************************************************************************************;

/*Have you ever needed to know if a given variable is in a SAS data set? 
This macro returns 1 if a variable exists in a data set, 0 if not.
Found it in SAS communities.
*/
%macro VarExist(ds,var);
	%local rc dsid result;
	%let dsid=%sysfunc(open(&ds));

	%if %sysfunc(varnum(&dsid,&var)) > 0 %then
		%do;
			%let result=1;
			%put NOTE: Var &var exists in &ds;
		%end;
	%else
		%do;
			%let result=0;
			%put NOTE: Var &var not exists in &ds;
		%end;

	%let rc=%sysfunc(close(&dsid));
	&result
%mend VarExist;

/* 
%put %VarExist(sashelp.class,name);
%put %VarExist(sashelp.class,aaa);

*/

**************************************************************************;
/* Aquí está el programa macro para generar la variable de patrón.
   Cualquier comentario para su mejora, es bien recibido.
*/
%macro pattern(data=, id_time=, id_unico=);

	proc sort data= &data;
		by &id_time;
	run;

	data &data;
		set &data;
		uno=1;
		by &id_time;
		retain id_tiempo 0;

		if first.&id_time then
			id_tiempo=id_tiempo+1;
	run;

	proc sql;
		select max(id_tiempo) into: fechamax from &data;
	quit;

	proc sort data=&data;
		by &id_unico;
	run;

	proc transpose data=&data (keep=&id_unico id_tiempo uno ) out=trans prefix=fecha;
		by &id_unico;
		id id_tiempo;
	run;

	data trans;
		retain fecha1-%sysfunc(cats(fecha,%str(&fechamax)));
		set trans;
	run;

	data trans;
		set trans;
		array fe(*) fecha:;
		do i= 1 to dim(fe);
			if missing(fe(i)) then
				fe(i)=0;
		end;
		drop i;
		patron=catt(of fecha:);
	run;

	proc sort data=trans nodup;
		by &id_unico;
	run;

	*usar el varexist (macro para ver si existe la varible patrón en &data);
	%if %VarExist(&data,patron)=1 %then
		%do;
			%let vardrop = id_tiempo uno patron;
		%end;
	%else
		%do;
			%let vardrop = id_tiempo uno;
		%end;

	data &data;
		merge &data(drop=&vardrop) trans (keep=&id_unico patron );
		by &id_unico;
	run;

%mend pattern;

/************
 ***********************************************************/
