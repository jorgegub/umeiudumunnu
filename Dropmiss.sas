/******************/
 *options nomprint noSYMBOLGEN MLOGIC;
/****************************/
%macro DROPMISS( DSNIN /* name of input SAS dataset
*/
 , DSNOUT /* name of output SAS dataset
*/
 , NODROP= /* [optional] variables to be omitted from dropping even if
they have only missing values */
 ) ;
 /* PURPOSE: To find both Character and Numeric the variables that have only
missing values and drop them if
 * they are not in &NONDROP
 *
 * NOTE: if there are no variables in the dataset, produce no variables
processing code
   SOURCE :http://support.sas.com/resources/papers/proceedings10/048-2010.pdf
 *
 * EXAMPLE OF USE:
 * %DROPMISS( DSNIN, DSNOUT )
 * %DROPMISS( DSNIN, DSNOUT, NODROP=A B C D--H X1-X100 )
 * %DROPMISS( DSNIN, DSNOUT, NODROP=_numeric_ )
 * %DROPMISS( DSNIN, DSNOUT, NOdrop=_character_ )
 */

 %local I ;
 %if "&DSNIN" = "&DSNOUT"
 %then %do ;
 %put /------------------------------------------------\ ;
 %put | ERROR from DROPMISS: | ;
 %put | Input Dataset has same name as Output Dataset. | ;
 %put | Execution terminating forthwith. | ;
 %put \------------------------------------------------/ ;
 %goto L9999 ;
 %end ;
 /*###################################################################*/
 /* begin executable code
 /*####################################################################/

 /*===================================================================*/
 /* Create dataset of variable names that have only missing values
 /* exclude from the computation all names in &NODROP
 /*===================================================================*/
 proc contents data=&DSNIN( drop=&NODROP ) memtype=data noprint out=_cntnts_( keep=
name type ) ; run ;
 %let N_CHAR = 0 ;
 %let N_NUM = 0 ;

 data _null_ ;
 set _cntnts_ end=lastobs nobs=nobs ;
 if nobs = 0 then stop ;
 n_char + ( type = 2 ) ;
 n_num + ( type = 1 ) ;
 /* create macro vars containing final # of char, numeric variables */
 if lastobs
 then do ;
 call symput( 'N_CHAR', left( put( n_char, 5. ))) ;
 call symput( 'N_NUM' , left( put( n_num , 5. ))) ;
 end ;
 run ;
 /*===================================================================*/
 /* if there are no variables in dataset, stop further processing
 /*===================================================================*/
 %if %eval( &N_NUM + &N_CHAR ) = 0
 %then %do ;
 %put /----------------------------------\ ;
 %put | ERROR from DROPMISS: | ;
 %put | No variables in dataset. | ;
 %put | Execution terminating forthwith. | ;
 %put \----------------------------------/ ;
 %goto L9999 ;
 %end ;
 /*===================================================================*/
 /* put global macro names into global symbol table for later retrieval
 /*===================================================================*/
 %LET NUM0 =0;
%LET CHAR0 = 0;
%IF &N_NUM >0 %THEN %DO;
 %do I = 1 %to &N_NUM ;
 %global NUM&I ;
 %end ;
 %END;
%if &N_CHAR > 0 %THEN %DO;
 %do I = 1 %to &N_CHAR ;
 %global CHAR&I ;
 %end ;
 %END;
 /*===================================================================*/
 /* create macro vars containing variable names
 /* efficiency note: could compute n_char, n_num here, but must declare macro names
to be
 global b4 stuffing them
 /*
 /*===================================================================*/
 proc sql noprint ;
 %if &N_CHAR > 0 %then %str( select name into :CHAR1 - :CHAR&N_CHAR from
_cntnts_ where type = 2 ; ) ;
 %if &N_NUM > 0 %then %str( select name into :NUM1 - :NUM&N_NUM from
_cntnts_ where type = 1 ; ) ;
 quit ;

 /*===================================================================*/
 /* Determine the variables that are missing
SAS Global Forum 2010 Coders' Corner
5
 /*
 /*===================================================================*/
%IF &N_CHAR > 1 %THEN %DO;
 %let N_CHAR_1 = %EVAL(&N_CHAR - 1);
 %END;
 Proc sql ;
 select %do I= 1 %to &N_NUM; max (&&NUM&I) , %end; %IF &N_CHAR > 1 %THEN %DO;
 %do I= 1 %to &N_CHAR_1; max(&&CHAR&I), %END; %end; MAX(&&CHAR&N_CHAR)
into
 %do I= 1 %to &N_NUM; :NUMMAX&I , %END; %IF &N_CHAR > 1 %THEN %DO;
 %do I= 1 %to &N_CHAR_1; :CHARMAX&I,%END; %END; :CHARMAX&N_CHAR
 from &DSNIN;
 quit;

 /*===================================================================*/
 /* initialize DROP_NUM, DROP_CHAR global macro vars
 /*===================================================================*/
 %let DROP_NUM = ;
 %let DROP_CHAR = ;

%if &N_NUM > 0 %THEN %DO;
DATA _NULL_;

 %do I = 1 %to &N_NUM ;
 %IF &&NUMMAX&I =. %THEN %DO;
 %let DROP_NUM = &DROP_NUM %qtrim( &&NUM&I ) ;
 %END;
 %end ;
RUN;
%END;
%IF &N_CHAR > 0 %THEN %DO;

DATA _NULL_;
 %do I = 1 %to &N_CHAR ;
			%put 1 &I %qtrim( &&CHAR&I ) ;
			%put 2  "%qtrim(&&CHARMAX&I)" eq "" ;
	%IF "%qtrim(&&CHARMAX&I)" eq "" %THEN %DO;
			%put 3  "%qtrim(&&CHARMAX&I)" eq "" ;
		%let DROP_CHAR = &DROP_CHAR %qtrim( &&CHAR&I ) ;
			 /**/
			%put 4 "%qtrim(&&CHARMAX&I)";
			%put 5  &DROP_CHAR %qtrim( &&CHAR&I ) ;
			/**/
	 %END;
 %end ;
 RUN;
%END;

 /*===================================================================*/
 /* Create output dataset
 /*===================================================================*/
 data &DSNOUT ;

 %if &DROP_CHAR ^= %then %str(DROP &DROP_CHAR ; ) ; /* drop char variables
that
 have only missing values */
 %if &DROP_NUM ^= %then %str(DROP &DROP_NUM ; ) ; /* drop num variables
that
 have only missing values */

 set &DSNIN ;

%if &DROP_CHAR ^= or &DROP_NUM ^= %then %do;

 %put /----------------------------------\ ;
 %put | Variables dropped are &DROP_CHAR &DROP_NUM | ;
 %put \----------------------------------/ ;
 %end;
 %if &DROP_CHAR = and &DROP_NUM = %then %do;
 %put /----------------------------------\ ;
 %put | No variables are dropped |;
 %put \----------------------------------/ ;
 %end;
 run ;
 %L9999:
%mend DROPMISS ; 



/******************/
 *A LESS COMPLICATED DROPMISS MACRO. DISADVANTAGE: ONE CAN NOT EXLUDE VARIABLES
SOURCE: https://communities.sas.com/t5/SAS-Enterprise-Guide/Drop-variables-that-have-only-missing-or-null-values/td-p/218289
;
/****************************/
%macro DROPMISS2( DSNIN /* name of input SAS dataset
*/
 , DSNOUT /* name of output SAS dataset
*/
 ) ;
 /* PURPOSE: To find both Character and Numeric the variables that have only
missing values and drop them 

 * EXAMPLE OF USE:
 * %DROPMISS( DSNIN, DSNOUT )

 */

proc transpose data=&DSNIN (obs=0) out=vname ;
 var _all_;
run;

proc sql NOPRINT;
 select catx(' ','n(',_name_,') as ',_name_) into : list separated by ',' from vname;
 create table temp as
  select &list from &DSNIN ;
quit;

proc transpose data=temp out=drop ;
 var _all_;
run;

proc sql NOPRINT;
 select _name_ into : drop separated by ' ' from drop where col1=0;
quit;

data &DSNOUT  / NOLIST;
 set &DSNIN (drop=&drop);
run;

PROC DATASETS LIBRARY=WORK NODETAILS NOLIST;
DELETE DROP VNAME temp HAVE;
RUN;

%mend DROPMISS2 ; 

