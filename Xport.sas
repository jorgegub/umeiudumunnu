* This macro exports to excel the last dataset created automatically;
* One can choose the dataset to export and the name of the sheet;
%macro xport(dataxport=&syslast,hoja=sheet1);
proc export
data=&dataxport
dbms=xlsx
outfile="c:\temp.xlsx" replace;
sheet = &hoja ;
run;
options noxwait;
*x net file temp.xlsx /close;
x start c:\temp.xlsx;
%mend xport;

*This one import an excel sheet into a sas data set;
%macro mport(datamport,sheet,dataout=importado);
PROC IMPORT OUT= &dataout
            DATAFILE= &datamport.
            DBMS=EXCELCS REPLACE;
     RANGE='%sysfunc(cats(&sheet.,$))'; 
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
%mend mport;


