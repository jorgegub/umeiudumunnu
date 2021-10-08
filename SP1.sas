/*****************************************************************
This macro program retrieves the inflation serie (INPC) of the 
Bank of Mexico's Information System, using a HTTP Procedure
							8/10/21
******************************************************************/

%macro sp1();
	filename SP1 temp;

	proc http
		url= "%NRSTR(https://www.banxico.org.mx/SieInternet/consultarDirectorioInternetAction.do?sector=8&accion=consultarCuadro&idCuadro=CP154&locale=es&formatoXLS.x=1&fechaInicio=1231394400000&fechaFin=1831077200000)"

		method="GET"
		out=SP1;
	run;

	/* Tell SAS to allow "nonstandard" names */
	options validvarname=any;

	/* import to a SAS data set */
	proc import DATAfile=SP1
		out=work.SP1(DROP=A) replace
		dbms=XLSX;
		getnames=yes;
		range="Hoja1$10:12";
	run;

	data sp1;
		set sp1;

		if FIND(B ,"INPC")>0 THEN
			B="INPC";
		ELSE B= "";
	run;

	PROC TRANSPOSE DATA= SP1 OUT= SP1_TRANS;
		ID B;
	RUN;

	DATA SP1;
		SET SP1_TRANS;
		DROP _LABEL_;
		FECHA= input( SUBSTR(_NAME_,1,3)||SUBSTR(_NAME_,7,2) ,ESPDFMY.);
		FORMAT FECHA ESPDFMY.;
		DROP _NAME_;
		YYYYMM=YEAR(FECHA)*100+MONTH(FECHA);
	RUN;

	PROC SQL NOPRINT NOPROMPT;
		DROP TABLE SP1_TRANS;
	QUIT;

%mend sp1;

%sp1;
