/*La siguiente macro es para ordenar una base de datos muy grande. Esto lo hace a través de partirla en pequeñas muestras
Referencias:
Sorting a Large Data Set When Space is Limited
Selvaratnam Sridharma, Census Bureau, Suitland, Maryland
*/
%macro splitsort_undup (libref = , dataset =, num = , var =);

	data _null_;
		if 0 then
			set &libref..&dataset nobs = count;
		call symput('numobs',put(count,8.));
	run;

	%let n=%sysevalf(&numobs/&num,ceil);

	data %do J = 1 %to &num;
		dataset_&J
		%end;
		;
		set &libref..&dataset;;

		%do I = 1 %to &num;
			if %eval(&n*(&i-1)) < _n_ <= %eval(&n*&I) then
				output dataset_&I;
		%end;
	run;

	%do J = 1 %to &num;

		proc sort data= dataset_&J;
			by &var;
		run;

	%end;

	data sorted_dataset;
		set

			%do J = 1 %to &num;
				dataset_&J
			%end;;

		by &var;

		if first.%scan(&var,-1,' ');

		/* first. is used with the last variable
		in the list of variables in &var */
	run;

%mend splitsort_undup;

/*As an example:
%splitsort_undup(libref = sashelp, dataset=class, num=3, var = age weight);
*/
