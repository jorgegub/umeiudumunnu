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

FILENAME CMDS DDE 'Excel|system'; 
DATA _NULL_; 
FILE CMDS; 
PUT '[Workbook.Activate("temp.xlsx")]';
PUT "[SAVE()]";
PUT "[CLOSE("'"'"c:\temp.xlsx"'"'")]"; 
RUN;

x start c:\temp.xlsx;
%mend xport;

*This one imports an excel sheet into a sas data set. 
No spaces in the sheet's name for simplicity;

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


