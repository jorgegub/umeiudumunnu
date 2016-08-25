/* =========^===============================================**=============== */
*options mstored sasmstore = SSD_PF  ;
*OPTION SPOOL;
*LIBNAME SSD_PF "E:\Buro\Bases\Personas_fisicas\Datamart" ;

%macro dataqual(lib,dsn,idvar,varlist) /*/ store*/	;
/*Ligera modificación hecha a la original. 
Fuente y explicación:
http://www.thejuliagroup.com/blog/?m=201105&paged=2
*/
	Title "Duplicate ID Numbers";

	Proc freq data = &lib..&dsn (keep= &idvar &varlist)  noprint;
		tables &idvar / out = &dsn._freq (where = ( count > 1 ));
		format &idvar;

	proc print data = &dsn._freq (obs = 10 );
	run;

	proc summary data = &lib..&dsn (keep= &idvar &varlist ) median mean min n std;
		output out = &dsn._stats;
		var &varlist;

	proc transpose data = &dsn._stats out = &dsn._stats_trans;
		id _STAT_;

proc sql;
select count(*) into: obsnum from &lib..&dsn ;quit;

	data &dsn._chk;
		set &dsn._stats_trans;
		pctmiss = 1 - (n/&obsnum);

		if min < 0 then
			neg_min = 1;
		else neg_min = 0;

		if std = 0 then
			constant = 1;
		else constant = 0;

		if (pctmiss > .05 or neg_min = 1 or constant = 1) then
			output;
		Title "Deviant variables to check ";

	proc print data = &dsn._chk;
	run;

	Title "First 10 observations with ALL of the variables unformatted ";

	proc print data = &lib..&dsn  (obs= 10);
		format _all_;
	run;

	Title "First 10 observations with ALL of the variables formatted ";

	proc print data = &lib..&dsn  (obs= 10);
	run;

	Title "Deviant variables to drop ";

	proc print data = &dsn._chk noobs;
		var _name_;
		%put You defined the following macro variables;
		%put _user_;
	run;

%mend dataqual;


/*******************************************************************************/
/* Ejemplo:
*creas una copia;
data ssd_pf.prueba (drop=numero_expediente CredEndClaveOtorgante tipo_contrato ClienEndRFC	ClienEndCURP	EmplEndRazonSocial	reclasificacion_estadistica	sector) ;
	set ssd_pf.personasfisicasendeudamiento_dm;
	id_cat= ClienEndFechaCorte||numero_expediente||CredEndClaveOtorgante||tipo_contrato;
run;

proc sort data=ssd_pf.prueba;
	by id_cat;
run;

data  ssd_pf.prueba (drop=id_cat);
	set ssd_pf.prueba;
	uno=1;
	by id_cat;
	retain id_unico 0;
	if first.id_cat then
		id_unico=id_unico+1;
run;

data ssd_pf.prueba;
set ssd_pf.prueba (rename=DirecEndCodigoPostal=zipcode);
DirecEndCodigoPostal=input(zipcode,best32.);
drop zipcode;
run;

%let variables=credendsaldoactual CredEndCreditoMaximo CredEndMontoPagar DirecEndCodigoPostal EmplEndSalario DirecEndCodigoPostal;
 
%dataqual(ssd_pf,prueba,id_unico, &variables);
*/
