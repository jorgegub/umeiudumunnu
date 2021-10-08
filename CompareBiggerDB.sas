
/*
macro para comparar cuál base es la buena. si son iguales, te avienta la primera que quieres
*/
%macro comparebigger(b1,b2);

	%local RC1  RC2 result b1_size dsid1 b2_size;

	%let dsid1=%sysfunc(open(&b1,IN));
 	%let b1_size=%sysfunc(ATTRN(&dsid1,NOBS));
  	%let RC1=%sysfunc(CLOSE(&dsid1));

	%let dsid2=%sysfunc(open(&b2,IN));
 	%let b2_size=%sysfunc(ATTRN(&dsid2,NOBS));
    	%let RC2=%sysfunc(CLOSE(&dsid2));
	
	%if %EVAL(&b1_size>=&b2_size) %then
		%do;
			%let result=&b1;
		%end;
	%else
		%do;
			%let result=&b2;
		%end;
	&result
%mend comparebigger;