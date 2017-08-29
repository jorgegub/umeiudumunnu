/*filename job "P:\Cuadros y Gráficas\Códigos\SAS\INCLUDE\";
%include job(DROPMISS.sas,DO_OVER.sas);*/

*******************************************************************************************
********************Macro para codificar una palabra en números****************************
*******************************************************************************************
Se regresa la base_salida como copia de la base_entrada, una columna llamada clave que indica 
la codificación de la variable_a_codificar y otra llamada sin_acronimos_variable_a_codificar 
que es lo que se usa para calcular el compged (la distancia entre dos palabras)*
Referencia principal:
https://github.com/jorgegub/umeiudumunnu/blob/master/Algoritmos%20de%20texto%20(empresas).sas
*******************************************************************************************;
options mprint; *En el log aparecen las sustituciones que la macro hace;
%macro codificacion(base_entrada=, base_salida=, variable_a_codificar=);
%if "&base_entrada" NE "" or "&base_salida" NE "" or "&variable_a_codificar" NE "" %then 
%do;
data tmp / view=tmp;
set &base_entrada;
palabra_mod=&variable_a_codificar;
*Pone palabra en mayúsculas;
palabra_mod=upcase(palabra_mod);
*Quita espacios al principio y final;
palabra_mod=STRIP(palabra_mod);
*quita dobles y triples y así de espacios;
palabra_mod=COMPBL(palabra_mod);

* PRIMER DIAGNÓSTICO:
Corta la palabra si le encuentra un + o un /. Nos quedamos con la primera enfermedad
;
palabra_mod=substr(palabra_mod, 1, index(palabra_mod, '+') - 1);
palabra_mod=substr(palabra_mod, 1, index(palabra_mod, '/') - 1);
palabra_mod=substr(palabra_mod, 1, index(palabra_mod, '\') - 1);
palabra_mod=substr(palabra_mod, 1, index(palabra_mod, '|') - 1);
*Si encuentra ** sólo después de los primeros cinco dígitos, se corta el diagnóstico;
if find(substr(palabra_mod,1,5),'**')=0 then palabra_mod=substr(palabra_mod, 1, index(palabra_mod, '**') - 1);

/*Pone un espacio al principio y al final;*/
palabra_mod=CAT(" ",palabra_mod," "); 

*Cambia carácteres "AEIOUAEIOUAEIO" por "ÁÉÍÓÚÀÈÌÒÙÄËÏÖ";
palabra_mod=TRANSLATE(palabra_mod,"AEIOUAEIOUAEIO" , "ÁÉÍÓÚÀÈÌÒÙÄËÏÖ");

/*Antes de quitar los números, recuperamos información*/

palabra_mod=TRANWRD(palabra_mod," 2DO "," SEGUNDO ");
palabra_mod=TRANWRD(palabra_mod," 2 DO "," SEGUNDO ");
palabra_mod=TRANWRD(palabra_mod," 2DA "," SEGUNDA ");
palabra_mod=TRANWRD(palabra_mod," 2 DA "," SEGUNDA ");
palabra_mod=TRANWRD(palabra_mod," 3ER "," TERCER ");
palabra_mod=TRANWRD(palabra_mod," 3 ER "," TERCER ");
palabra_mod=TRANWRD(palabra_mod," 3RO "," TERCERO ");
palabra_mod=TRANWRD(palabra_mod," 3 RO "," TERCERO ");
palabra_mod=TRANWRD(palabra_mod," 3ERO "," TERCERO ");
palabra_mod=TRANWRD(palabra_mod," 3 ERO "," TERCERO ");
palabra_mod=TRANWRD(palabra_mod," 4O "," CUARTO ");
palabra_mod=TRANWRD(palabra_mod," 4 O "," CUARTO ");
palabra_mod=TRANWRD(palabra_mod," 4TO "," CUARTO ");
palabra_mod=TRANWRD(palabra_mod," 4 TO "," CUARTO ");
palabra_mod=TRANWRD(palabra_mod," 4TA "," CUARTA ");
palabra_mod=TRANWRD(palabra_mod," 4 TA "," CUARTA ");
palabra_mod=TRANWRD(palabra_mod," 5O "," QUINTO ");
palabra_mod=TRANWRD(palabra_mod," 5 O "," QUINTO ");
palabra_mod=TRANWRD(palabra_mod," 5TO "," QUINTO ");
palabra_mod=TRANWRD(palabra_mod," 5 TO "," QUINTO ");
palabra_mod=TRANWRD(palabra_mod," 5TA "," QUINTA ");
palabra_mod=TRANWRD(palabra_mod," 5 TA "," QUINTA ");

palabra_mod=TRANWRD(palabra_mod," 6O "," SEXTO ");
palabra_mod=TRANWRD(palabra_mod," 6 O "," SEXTO ");
palabra_mod=TRANWRD(palabra_mod," 6TO "," SEXTO ");
palabra_mod=TRANWRD(palabra_mod," 6 TO "," SEXTO ");
palabra_mod=TRANWRD(palabra_mod," 6A "," SEXTA ");
palabra_mod=TRANWRD(palabra_mod," 6TA "," SEXTA ");
palabra_mod=TRANWRD(palabra_mod," 6 TA "," SEXTA ");

palabra_mod=TRANWRD(palabra_mod," GDO "," GRADO ");

*Remueve (LP) y (EN BASE LIST. PRECAPT.), ST7;

palabra_mod=TRANWRD(palabra_mod," (LP) "," ");
palabra_mod=TRANWRD(palabra_mod," (EN BASE LIST. PRECAPT.) "," ");
palabra_mod=TRANWRD(palabra_mod," (LIST.PRECAP.) "," ");
palabra_mod=TRANWRD(palabra_mod," SIN FORMATO ST7 "," ");
palabra_mod=TRANWRD(palabra_mod," ST-7 "," ");
palabra_mod=TRANWRD(palabra_mod," ST7 "," ");
palabra_mod=TRANWRD(palabra_mod," S.T. 7 "," ");

*Homologa grados;
palabra_mod=TRANWRD(palabra_mod," GRADO 1 "," GRADO I ");
palabra_mod=TRANWRD(palabra_mod," GRADO 2 "," GRADO II ");
palabra_mod=TRANWRD(palabra_mod," GRADO 3 "," GRADO III ");

**********************************************************************;
*Remueve signos de puntuación, se queda sólo con las letras y espacios;
palabra_mod=COMPRESS(palabra_mod,"ABCDEFGHIJKLMNOPQRSTUVWXYÜ¥ÑðÐ Z","K"); 

*Quita typos en MENISCOS y homologa;
palabra_mod=TRANWRD(palabra_mod," MEÑISC"," MENISC");
palabra_mod=TRANWRD(palabra_mod," MENISCOS "," MENISCO ");

*Remueve (LP) y (EN BASE LIST. PRECAPT.);
palabra_mod=TRANWRD(palabra_mod," LIST PRE "," ");
palabra_mod=TRANWRD(palabra_mod," APOYO PRECAPTURA "," ");

*BUSCA AMENAZAS DE ABORTO;
*if palabra_mod=" AA " then palabra_mod=" AMENAZA DE ABORTO ";*FRÁGIL;
if find(palabra_mod," A DE A")>0 then palabra_mod=" AMENAZA DE ABORTO ";
if find(palabra_mod," A ABORT")>0 then palabra_mod=" AMENAZA DE ABORTO ";
**********************************************************************;
*Homologamos palabra de POSTQUIRURGICO;
palabra_mod=TRANWRD(palabra_mod," P O "," PO ");
*HOMOLOGAMOS POST;
palabra_mod=TRANWRD(palabra_mod," POS "," POST ");

*Homologamos postquirurgico;
%LET postqx=PO POP POSTQX PQX POSOPERADO POSTOPERADO POSOPERATORIO 
			POSTOPERADO POSTOPERADA POSTOPERATORIO POSTOP POSQUIRURGICA POSQUIRURGICO 
			POQX POSTINTERVENCION POSINTERVENCION POSTCIRUGIA ;

 %DO_OVER(VALUES=&postqx,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " POSTQUIRURGICO ");)
;

*HOMOLOGOMAMOS QUIRURGICO;
%LET qx=	INTERVENCION CIRUGIA QX  OPERADO OPERADA  LAPARASCOPIA;

 %DO_OVER(VALUES=&qx,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " QUIRURGICO ");)
;


palabra_mod=TRANWRD(palabra_mod," POST OP ", " POSTQUIRURGICO ");

palabra_mod=TRANWRD(palabra_mod," POST QUIRURGICO ", " POSTQUIRURGICO ");

palabra_mod=TRANWRD(palabra_mod," POSTQUIRURGICO POSTQUIRURGICO ", " POSTQUIRURGICO ");

*Homologamos palabra de PROBABLE;
palabra_mod=TRANWRD(palabra_mod," CASO SOSPECHOSO ", " SOSPECHOSO ");

%LET probables= PB PBLE PROBABLE PROB PRB PBE
				DESC DESCARTAR 
				SOSPECHOSO;

 %DO_OVER(VALUES=&probables,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " PROBABLE ");)
;

*Homologamos palabras de ENFERMEDAD;
%LET ENFERMEDADES= ENF ENFE ENFER ENFERM ;

%DO_OVER(VALUES=&ENFERMEDADES,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " ENFERMEDAD ");)

*Quita LA, EN, DEL, Y,...;
%LET QUITALAS1= DE DEL LA X POR 
				LAPARASCOPICA LAPARASCOPICO  
				EN LOS LAS UN Y 
				INMEDIATO INMEDIATA
				;
 %DO_OVER(VALUES=&QUITALAS1,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " ");)
;

*Homologa Grados;
palabra_mod=TRANWRD(palabra_mod," GI "," GRADO I ");
palabra_mod=TRANWRD(palabra_mod," GII "," GRADO II ");
palabra_mod=TRANWRD(palabra_mod," GIII "," GRADO III ");
palabra_mod=TRANWRD(palabra_mod," G II "," GRADO II ");
palabra_mod=TRANWRD(palabra_mod," G III "," GRADO III ");
palabra_mod=TRANWRD(palabra_mod," GDO II "," GRADO II ");
palabra_mod=TRANWRD(palabra_mod," GDO III "," GRADO III ");
palabra_mod=TRANWRD(palabra_mod,"CERVICAL G LL ","CERVICAL GRADO II ");
palabra_mod=TRANWRD(palabra_mod,"CERVICAL G LLL ","CERVICAL GRADO III ");


*Homologa INFECCIONES;
palabra_mod=TRANWRD(palabra_mod," INFECCI N "," INFECCION ");
palabra_mod=TRANWRD(palabra_mod," INFECC "," INFECCION ");
palabra_mod=TRANWRD(palabra_mod," INFEC "," INFECCION ");

*Completa PALABRAS;
palabra_mod=TRANWRD(palabra_mod," ABLACI N "," ABLACION ");
palabra_mod=TRANWRD(palabra_mod," OBSERVACI N "," OBSERVACION ");
palabra_mod=TRANWRD(palabra_mod," COMPLICACI N "," COMPLICACION ");
palabra_mod=TRANWRD(palabra_mod," ABRASI N "," ABRASION ");
palabra_mod=TRANWRD(palabra_mod," PULM N "," PULMON ");
palabra_mod=TRANWRD(palabra_mod," REGI N "," REGION ");
palabra_mod=TRANWRD(palabra_mod," REHABILITACI N "," REHABILITACION ");
palabra_mod=TRANWRD(palabra_mod," TEND N "," TENDON ");
palabra_mod=TRANWRD(palabra_mod," AGRESI N "," AGRESION ");
palabra_mod=TRANWRD(palabra_mod," ALTERACI N "," ALTERACION ");
palabra_mod=TRANWRD(palabra_mod," AMPUTACI N "," AMPUTACION ");
palabra_mod=TRANWRD(palabra_mod," ARTICULACI N "," ARTICULACION ");
palabra_mod=TRANWRD(palabra_mod," ATENCI N "," ATENCION ");
palabra_mod=TRANWRD(palabra_mod," CALCIFICACI N "," CALCIFICACION ");
palabra_mod=TRANWRD(palabra_mod," COMPLICACI N "," COMPLICACION ");
palabra_mod=TRANWRD(palabra_mod," COMPRESI N "," COMPRESION ");
palabra_mod=TRANWRD(palabra_mod," CONTRACCI N "," CONTRACCION ");
palabra_mod=TRANWRD(palabra_mod," CONTUSI N "," CONTUSION ");
palabra_mod=TRANWRD(palabra_mod," DEGENERACI N "," DEGENERACION ");
palabra_mod=TRANWRD(palabra_mod," DEPRESI N "," DEPRESION ");
palabra_mod=TRANWRD(palabra_mod," DESNUTRICI N "," DESNUTRICION ");
palabra_mod=TRANWRD(palabra_mod," DISFUNCI N "," DISFUNCION ");
palabra_mod=TRANWRD(palabra_mod," DISMINUCI N "," DISMINUCION ");
palabra_mod=TRANWRD(palabra_mod," CORAZ N "," CORAZON ");
palabra_mod=TRANWRD(palabra_mod," ERUPCI N "," ERUPCION ");
palabra_mod=TRANWRD(palabra_mod," EXPOSICI N "," EXPOSICION ");
palabra_mod=TRANWRD(palabra_mod," EXTRACCI N "," EXTRACCION ");
palabra_mod=TRANWRD(palabra_mod," FIBRILACI N "," FIBRILACION ");
palabra_mod=TRANWRD(palabra_mod," ABDUCCI N "," ABDUCCION ");
palabra_mod=TRANWRD(palabra_mod," REGI N "," REGION ");
palabra_mod=TRANWRD(palabra_mod," HERNIACI N "," HERNIACION ");
palabra_mod=TRANWRD(palabra_mod," HIPERTENSI N "," HIPERTENSION ");
palabra_mod=TRANWRD(palabra_mod," HIPOTENSI N "," HIPOTENSION ");
palabra_mod=TRANWRD(palabra_mod," INFLAMACI N "," INFLAMACION ");
palabra_mod=TRANWRD(palabra_mod," INTOXICACI N "," INTOXICACION ");
palabra_mod=TRANWRD(palabra_mod," IRRITACI N "," IRRITACION ");
palabra_mod=TRANWRD(palabra_mod," LACERACI N "," LACERACION ");
palabra_mod=TRANWRD(palabra_mod," LESI N "," LESION ");
palabra_mod=TRANWRD(palabra_mod," LUXACI N "," LUXACION ");
palabra_mod=TRANWRD(palabra_mod," MALFORMACI N "," MALFORMACION ");
palabra_mod=TRANWRD(palabra_mod," CLASIFICACI N "," CLASIFICACION ");
palabra_mod=TRANWRD(palabra_mod," OBSERVACI N "," OBSERVACION ");
palabra_mod=TRANWRD(palabra_mod," OBSTRUCCI N "," OBSTRUCCION ");
palabra_mod=TRANWRD(palabra_mod," PERTURBACI N "," PERTURVACION ");
palabra_mod=TRANWRD(palabra_mod," RETENCI N "," RETENCION ");
palabra_mod=TRANWRD(palabra_mod," PROLONGACI N "," PROLOGNACION ");
palabra_mod=TRANWRD(palabra_mod," REACCI N "," REACCION ");
palabra_mod=TRANWRD(palabra_mod," REHABILITACI N "," REHABILITACION ");
palabra_mod=TRANWRD(palabra_mod," RESPIRACI N "," RESPIRACION ");
palabra_mod=TRANWRD(palabra_mod," SECRECI N "," SECRECION ");
palabra_mod=TRANWRD(palabra_mod," SENSACI N "," SENSACION ");
palabra_mod=TRANWRD(palabra_mod," SUPERVISI N "," SUPERVISION ");
palabra_mod=TRANWRD(palabra_mod," VIOLACI N "," VIOLACION ");
palabra_mod=TRANWRD(palabra_mod," VISI N "," VISION ");
palabra_mod=TRANWRD(palabra_mod," TAMBI N "," TAMBIEN ");

palabra_mod=TRANWRD(palabra_mod," S NDROME "," SINDROME ");
palabra_mod=TRANWRD(palabra_mod," TEST CULO "," TESTICULO ");

*HOMOLOGA DIABETICO;
palabra_mod=TRANWRD(palabra_mod," DIAB TICA "," DIABETICA ");
palabra_mod=TRANWRD(palabra_mod," DIAB TICO "," DIABETICO ");
palabra_mod=TRANWRD(palabra_mod," DIABETICA "," DIABETICO ");



*Quita palabras no relevantes;

%LET QUITALAS2= QUINTO QUINTA SEXTA SEXTO SEPTIMO SEPTIMA OCTAVO OCTAVA
				INDICE MEÑIQUE MENIQUE MENYIQUE  
				IZQUIERDO IZQUIERDA IZQ IZQDO IZQDA IZDA IZDO DERECHO DERECHA DER DCHO DCHA DERE DEREC
				ESTATUS CLINICO 
				DX DIAGNOSTICO DIAG DIAGN
				DESCONTROLADO DESCONTROLADA
				EXPUESTA EXPUESTO MEDIAL
				IMSS HTVFN HGR HTVFN HGZ UMF CMNR SUBSECUENTE SUBSEC LISTADO CATALOGO SECCION DELEGACION MATRICULA TRABAJADOR TRABAJADORA
				DRA DOCTORA DR DOCTOR ENFERMERA ENFERMERO ESPECIALISTA
				PRECAPTURADO PRECAPTURA PRECAPTURADA PRECAP	
				NSSA OCI FOLIO FORMATO
				PEREZ CECILIA ALEJANDRO 
				;
				/*GRAVE LEVE SIMPLE SEVERO SEVERA AGUDA AGUDO PROFUNDA PROFUNDO*/
 %DO_OVER(VALUES=&QUITALAS2,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " ");)
;

*Transforma letras;

palabra_mod=TRANWRD(palabra_mod,"¥","Ñ");
palabra_mod=TRANWRD(palabra_mod,"ð","Ñ");
palabra_mod=TRANWRD(palabra_mod,"Ð","Ñ");
palabra_mod=TRANWRD(palabra_mod,"Ñ","NY");

*Transforma palabras;
palabra_mod=TRANWRD(palabra_mod," FX "," FRACTURA ");
palabra_mod=TRANWRD(palabra_mod," FRAC "," FRACTURA ");
palabra_mod=TRANWRD(palabra_mod," FRACT "," FRACTURA ");
palabra_mod=TRANWRD(palabra_mod," FRX "," FRACTURA ");
palabra_mod=TRANWRD(palabra_mod," LX "," LUXACION ");
palabra_mod=TRANWRD(palabra_mod," SX "," SINDROME ");
palabra_mod=TRANWRD(palabra_mod," SD "," SINDROME ");
palabra_mod=TRANWRD(palabra_mod," SIND "," SINDROME ");
palabra_mod=TRANWRD(palabra_mod," TX "," TRATAMIENTO ");
palabra_mod=TRANWRD(palabra_mod," QT "," QUIMIOTERAPIA ");
palabra_mod=TRANWRD(palabra_mod," QUIMIOTX "," QUIMIOTERAPIA ");
palabra_mod=TRANWRD(palabra_mod," QUIMIO TX "," QUIMIOTERAPIA ");
palabra_mod=TRANWRD(palabra_mod," CA "," CANCER ");
palabra_mod=TRANWRD(palabra_mod," MUSC "," MUSCULAR ");

palabra_mod=TRANWRD(palabra_mod," BACT "," BACTERIANA ");
palabra_mod=TRANWRD(palabra_mod," FARINGOAMIGD "," FARINGOAMIGDALITIS ");
palabra_mod=TRANWRD(palabra_mod," SRAG "," SINDROME RESPIRATORIO AGUDO GRAVE ");
palabra_mod=TRANWRD(palabra_mod," SCPH "," SINDROME CARDIO PULMONAR HANTAVIRUS ");
palabra_mod=TRANWRD(palabra_mod," EPOC "," ENFERMEDAD PULMONAR OBSTRUCTIVA CRONICA ");
palabra_mod=TRANWRD(palabra_mod," CCL "," COLECISTITIS CRONICA LITIASICA ");
palabra_mod=TRANWRD(palabra_mod," C C L "," COLECISTITIS CRONICA LITIASICA ");
palabra_mod=TRANWRD(palabra_mod," HUA "," HEMORRAGIA UTERINA ANORMAL ");
palabra_mod=TRANWRD(palabra_mod," HTA "," HIPERTENSION ARTERIAL ");
palabra_mod=TRANWRD(palabra_mod," HA "," HIPERTENSION ARTERIAL ");
palabra_mod=TRANWRD(palabra_mod," SUA "," SANGRADO UTERINO ANORMAL ");
palabra_mod=TRANWRD(palabra_mod," IVU "," INFECCION VIAS URINARIAS ");
palabra_mod=TRANWRD(palabra_mod," IVR "," INFECCION VIAS RESPIRATORIAS ");
palabra_mod=TRANWRD(palabra_mod," IVRA "," INFECCION VIAS RESPIRATORIAS ALTAS ");
palabra_mod=TRANWRD(palabra_mod," IVRS "," INFECCION VIAS RESPIRATORIAS SUPERIORES ");
palabra_mod=TRANWRD(palabra_mod," IVRB "," INFECCION VIAS RESPIRATORIAS BAJAS ");
palabra_mod=TRANWRD(palabra_mod," LUI "," LEGRADO UTERINO INSTRUMENTAL ");
palabra_mod=TRANWRD(palabra_mod," L U I "," LEGRADO UTERINO INSTRUMENTAL ");
palabra_mod=TRANWRD(palabra_mod," AMEU "," ASPIRACION MANUAL ENDOUTERINA ");
palabra_mod=TRANWRD(palabra_mod," EVC "," ENFERMEDAD VASCULAR CEREBRAL ");
palabra_mod=TRANWRD(palabra_mod," ECV "," ENFERMEDAD CEREBROVASCULAR ");
palabra_mod=TRANWRD(palabra_mod," AVC "," ACCIDENTE VASCULAR CEREBRAL ");
palabra_mod=TRANWRD(palabra_mod," ACV "," ACCIDENTE CEREBRO VASCULAR ");
palabra_mod=TRANWRD(palabra_mod," EAP "," ENFERMEDAD ACIDO PEPTICA ");

palabra_mod=TRANWRD(palabra_mod," GEPI "," GASTROENTERITIS INFECCION ");
palabra_mod=TRANWRD(palabra_mod," FOD "," FIEBRE ORIGEN DESCONOCIDO ");
*palabra_mod=TRANWRD(palabra_mod," PBE "," PERITONITIS BACTERIANA ESPONTANEA ");
palabra_mod=TRANWRD(palabra_mod," MTC "," METACARPIANO ");
palabra_mod=TRANWRD(palabra_mod," MTT "," METATARSIANO ");
palabra_mod=TRANWRD(palabra_mod," TCE "," TRAUMATISMO CRANEOENCEFALICO ");
palabra_mod=TRANWRD(palabra_mod," LCA "," LIGAMENTO CRUZADO ANTERIOR ");
palabra_mod=TRANWRD(palabra_mod," LCL "," LIGAMENTO CRUZADO LATERAL ");
palabra_mod=TRANWRD(palabra_mod," HMR "," HUEVO MUERTO RETENIDO ");

*Homologamos LAPE;
palabra_mod=TRANWRD(palabra_mod," LAPE "," LAPAROTOMIA EXPLORATORIA ");
palabra_mod=TRANWRD(palabra_mod," LAPARATOMIA EXP "," LAPAROTOMIA EXPLORATORIA ");
palabra_mod=TRANWRD(palabra_mod," LAPARATOMIA EXPLORADO "," LAPAROTOMIA EXPLORATORIA ");
palabra_mod=TRANWRD(palabra_mod," LAPARATOMIA EXPLORADA "," LAPAROTOMIA EXPLORATORIA ");


*Sólo sí se encuentra valvula, estenosis o aneurisma, se cambia ao a aorta.
En ausencia de estas palabras, cambiamos a ambos ojos.;
if find(palabra_mod,"VALVULA")>0 or find(palabra_mod,"ESTENOSIS")>0 or find(palabra_mod,"ANEURISMA")>0 
	THEN palabra_mod=TRANWRD(palabra_mod," AO "," AORTA ");
else palabra_mod=TRANWRD(palabra_mod," AO "," AMBOS OJOS ");
palabra_mod=TRANWRD(palabra_mod," ETA "," ENFERMEDAD TIROIDEA AUTOINMUNE ");

palabra_mod=TRANWRD(palabra_mod," VIH "," VIRUS INMUNODEFICIENCIA HUMANA ");
palabra_mod=TRANWRD(palabra_mod," HIV "," VIRUS INMUNODEFICIENCIA HUMANA ");
palabra_mod=TRANWRD(palabra_mod," VPH "," VIRUS PAPILOMA HUMANO ");

palabra_mod=TRANWRD(palabra_mod," IRCT "," INSUFICIENCIA RENAL CRONICA TERMINAL");
palabra_mod=TRANWRD(palabra_mod," IRC "," INSUFICIENCIA RENAL CRONICA ");
palabra_mod=TRANWRD(palabra_mod," I R C "," INSUFICIENCIA RENAL CRONICA ");
palabra_mod=TRANWRD(palabra_mod," ERC "," ENFERMEDAD RENAL CRONICA ");
palabra_mod=TRANWRD(palabra_mod," DPCA "," DIALISIS PERITONEAL CRONICA AMBULATORIA ");
palabra_mod=TRANWRD(palabra_mod," DPCC "," DIALISIS PERITONEAL CICLICA CONTINUA ");
palabra_mod=TRANWRD(palabra_mod," QXPLAST "," CIRUGIA PLASTICA ");
palabra_mod=TRANWRD(palabra_mod," APP "," AMENAZA PREMATURA PARTO ");
palabra_mod=TRANWRD(palabra_mod," TBP "," TUBERCULOSIS PULMONAR ");
palabra_mod=TRANWRD(palabra_mod," SICA "," SINDROME CORONARIO AGUDO ");
palabra_mod=TRANWRD(palabra_mod," SICCA "," SINDROME CORONARIO AGUDO ");

palabra_mod=TRANWRD(palabra_mod," DM "," DIABETES MELLITUS ");

palabra_mod=TRANWRD(palabra_mod," VHA "," VIRUS HEPATITIS A ");
palabra_mod=TRANWRD(palabra_mod," VHB "," VIRUS HEPATITIS B ");
palabra_mod=TRANWRD(palabra_mod," VHC "," VIRUS HEPATITIS C ");
palabra_mod=TRANWRD(palabra_mod," HAV "," VIRUS HEPATITIS A ");
palabra_mod=TRANWRD(palabra_mod," HBV "," VIRUS HEPATITIS B ");
palabra_mod=TRANWRD(palabra_mod," HCV "," VIRUS HEPATITIS C ");

palabra_mod=TRANWRD(palabra_mod," LEP "," LUPUS ERITEMATOSO PROFUNDO ");
palabra_mod=TRANWRD(palabra_mod," LES "," LUPUS ERITEMATOSO SISTEMICO ");
palabra_mod=TRANWRD(palabra_mod," LET "," LUPUS ERITEMATOSO TUMIDO ");


*ESTAS NO APLICAN PORQUE ERAN DE MATERNIDAD;
*palabra_mod=TRANWRD(palabra_mod," EMBARAZO "," EMB ");
*palabra_mod=TRANWRD(palabra_mod," SEMANAS "," SEM ");
*palabra_mod=TRANWRD(palabra_mod," SEMANA "," SEM ");
*palabra_mod=TRANWRD(palabra_mod," SDG "," SEM ");

palabra_mod=TRANWRD(palabra_mod," POSTCOLECISTECTOMIA "," COLECISTECTOMIA ");
palabra_mod=TRANWRD(palabra_mod," COXIS "," COCCIX ");	
palabra_mod=TRANWRD(palabra_mod," TIBIAL "," TIBIA ");	
palabra_mod=TRANWRD(palabra_mod," PELVIANA "," PELVIS ");	
palabra_mod=TRANWRD(palabra_mod," PUBIANA "," PUBIS ");	
palabra_mod=TRANWRD(palabra_mod," TUMORACION "," TUMOR ");	
palabra_mod=TRANWRD(palabra_mod," TUMORACIONES "," TUMOR ");	
palabra_mod=TRANWRD(palabra_mod," TUMORES "," TUMOR ");	
palabra_mod=TRANWRD(palabra_mod," CARCINOMA "," CANCER ");	
palabra_mod=TRANWRD(palabra_mod," ROD "," RODILLA ");	
palabra_mod=TRANWRD(palabra_mod," RODILLAS "," RODILLA ");	
palabra_mod=TRANWRD(palabra_mod," MANOS "," MANO ");
palabra_mod=TRANWRD(palabra_mod," OJOS "," OJO ");	
palabra_mod=TRANWRD(palabra_mod," DEDOS "," DEDO ");	

*Homologamos chikungunya;

%LET chikungunya= CHINKUNGUYA CHIKUNGUYA CHINKUNGUNYA CHIKONKUYA CHINKU CHINGUNKUYA CHIKUNG CHIKUNG
					CHINK CHIKU
					;
 %DO_OVER(VALUES=&chikungunya,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " CHIKUNGUNYA ");)
;



*quita dobles y triples y así de espacios;
palabra_mod=COMPBL(palabra_mod);

*Encuentra coincidencias;
*Palabra_mod=TRANWRD(palabra_mod," NO ESPECIFICADA "," ");
*Palabra_mod=TRANWRD(palabra_mod," NO ESPECIFICADO "," ");

Palabra_mod=TRANWRD(palabra_mod," A NIVEL "," ");

*Los siguientes comandos sólo los realiza cuando no se trata del catálogo, i.e. no encuentra la palabra "CIE";
%if %index(%UPCASE(&base_entrada),CIE) > 0 %then %goto Continua;

	
	*BUSCA CONTRACTURA MUSCULAR;
*	if find(palabra_mod,"CONTRACTURA MUSC")>0 then palabra_mod=" CONTRACTURA MUSCULAR ";
	*BUSCA AMENAZA ABORTO;
	*if find(palabra_mod,"AMENAZA")>0 & (find(palabra_mod,"ABORTO")>0 OR find(palabra_mod,"PARTO")>0 )then palabra_mod=" AMENAZA ABORTO ";

	*BUSCA ZIKA;
	*if find(palabra_mod,"ZIKA")>0 OR find(palabra_mod,"ZICA")>0 then palabra_mod=" ZIKA ";
	*BUSCA CONJUNTIVITIS;
	*if find(palabra_mod,"CONJUNTIVITIS")>0 then palabra_mod=" CONJUNTIVITIS ";
	*BUSCA LUMBALGIA;
	*if find(palabra_mod,"LUMBALGIA")>0 then palabra_mod=" LUMBALGIA ";
	*BUSCA LEGRADO UTERINO (checar si no hay distintos ;
	*if find(palabra_mod,"LEGRADO UTERINO")>0 then palabra_mod=" LEGRADO UTERINO ";
	*BUSCA DENGUE;
	*if find(palabra_mod,"DENGUE")>0 then palabra_mod=" DENGUE ";

	*BUSCA FRACTURA FALANGE DEDO PIE;
*	if find(palabra_mod,"FRACTURA")>0 & (find(palabra_mod,"FALANG")>0 OR find(palabra_mod," DEDO ")>0) & find(palabra_mod," PIE ")>0 then palabra_mod=" FRACTURA DEDO PIE ";
	*BUSCA FRACTURA FALANGE DEDO MANO;
	*if find(palabra_mod,"FRACTURA")>0 & (find(palabra_mod,"FALANG")>0 OR find(palabra_mod," DEDO ")>0) & find(palabra_mod," MANO ")>0 then palabra_mod=" FRACTURA DEDO MANO ";

	*BUSCA HERIDA TOBILLO ;
	*if find(palabra_mod,"HERIDA")>0 & find(palabra_mod,"TOBIYO")>0 then palabra_mod=" HERIDA TOBIYO ";
	*BUSCA HERIDA DEDO MANO (no pie);
	*if find(palabra_mod,"HERIDA")>0 & (find(palabra_mod," DEDO ")>0 OR find(palabra_mod,"MANO")>0) & find(palabra_mod,"PIE")=0 then palabra_mod=" HERIDA MANO ";
	*BUSCA HERIDA PIE ;
	*if find(palabra_mod,"HERIDA")>0 & find(palabra_mod," PIE ")>0 then palabra_mod=" HERIDA PIE ";
	*BUSCA HERIDA DEDO PIE ;
	*if find(palabra_mod,"HERIDA")>0 & find(palabra_mod," DEDO ")>0 & find(palabra_mod," PIE ")>0 then palabra_mod=" HERIDA DEDO PIE ";

	*BUSCA CONTUSION DEDO MANO (no pie);
	*if find(palabra_mod,"CONTUSION")>0 & (find(palabra_mod," DEDO ")>0 OR find(palabra_mod,"MANO")>0) & find(palabra_mod,"PIE")=0 then palabra_mod=" CONTUSION MANO ";
	*BUSCA CONTUSION PIE ;
	*if find(palabra_mod,"CONTUSION")>0 & find(palabra_mod," PIE ")>0 then palabra_mod=" CONTUSION PIE ";
	*BUSCA CONTUSION DEDO PIE ;
	*if find(palabra_mod,"CONTUSION")>0 & find(palabra_mod," DEDO ")>0 & find(palabra_mod," PIE ")>0 then palabra_mod=" CONTUSION DEDO PIE ";

	*BUSCA HUEVO MUERTO RETENIDO;
	*if find(palabra_mod,"HUEVO MUERTO RETENIDO")>0 then palabra_mod=" HUEVO MUERTO RETENIDO ";

	*BUSCA POSTCOLECISTECTOMIA;
*	if find(palabra_mod,"POSTCOLECISTECTOMIA")>0 then palabra_mod=" POSTCOLECISTECTOMIA ";

	*BUSCA PERITONITIS BACTERIANA;
	*if find(palabra_mod,"PERITONITIS")>0 & find(palabra_mod,"BACTERIANA")>0then palabra_mod=" PERITONITIS BACTERIANA ";

	*BUSCA PARALISIS FACIAL;
	*if find(palabra_mod,"PARALISIS")>0 & find(palabra_mod,"FACIAL")>0then palabra_mod=" PARALISIS FACIAL ";

%Continua:

*Transforma letras Y SONIDOS;
palabra_mod=TRANWRD(palabra_mod,"TRANS","TRAS");


*Dejas la palabra sin acrónimos;
sin_acronimos_&variable_a_codificar=STRIP(palabra_mod); *variable con la que se calcula el compged;

*Sonidos;
palabra_mod=TRANWRD(palabra_mod,"CK","K");
palabra_mod=TRANWRD(palabra_mod,"DD","D");
palabra_mod=TRANWRD(palabra_mod,"SS","S");
palabra_mod=TRANWRD(palabra_mod,"GÜ","W");
palabra_mod=TRANWRD(palabra_mod,"LL","Y");
palabra_mod=TRANWRD(palabra_mod,"RR","R");
palabra_mod=TRANWRD(palabra_mod," ES"," S");

palabra_mod=TRANWRD(palabra_mod,"CA","KA");
palabra_mod=TRANWRD(palabra_mod,"CO","KO");
palabra_mod=TRANWRD(palabra_mod,"CU","KU");
palabra_mod=TRANWRD(palabra_mod,"QUE","KE");
palabra_mod=TRANWRD(palabra_mod,"QUI","KI");

*Quita palabras no relevantes;
%LET QUITALAS3= Y EL PARA LOS LAS EN AL A ;
 %DO_OVER(VALUES=&QUITALAS3,
 PHRASE=palabra_mod=TRANWRD(palabra_mod," ? ", " ");)
;
*Se mete un vocablo para el sonido SH y CH;
palabra_mod=TRANWRD(palabra_mod,"CHA","#A");
palabra_mod=TRANWRD(palabra_mod,"CHE","#E");
palabra_mod=TRANWRD(palabra_mod,"CHI","#I");
palabra_mod=TRANWRD(palabra_mod,"CHO","#O");
palabra_mod=TRANWRD(palabra_mod,"CHU","#U");
palabra_mod=TRANWRD(palabra_mod,"SHA","#A");
palabra_mod=TRANWRD(palabra_mod,"SHE","#E");
palabra_mod=TRANWRD(palabra_mod,"SHI","#I");
palabra_mod=TRANWRD(palabra_mod,"SHO","#O");
palabra_mod=TRANWRD(palabra_mod,"SHU","#U");

*Quita todos los espacios;
palabra_mod=COMPRESS(palabra_mod);
run;

*Quita la letra H al principio de una palabra;

proc sql NOPRINT;
create view tmp0 as
select *,
case 
when substr(palabra_mod,1,1)="H" then substr(palabra_mod,2)
else palabra_mod
end as palabra_mod0
from tmp;
quit;

*Se unifican letras con sonido similar;
proc sql NOPRINT;
create view tmp2 as
select *,
case
	when substr(palabra_mod0,1,1)="Z" then TRANWRD(substr(palabra_mod0,1,1),"Z","S")||substr(palabra_mod0,2)
	when substr(palabra_mod0,1,1)="X" then TRANWRD(substr(palabra_mod0,1,1),"X","S")||substr(palabra_mod0,2)
	when substr(palabra_mod0,1,1)="G" and substr(palabra_mod0,2,1) IN ("E","I") then TRANWRD(substr(palabra_mod0,1,1),"G","J")||substr(palabra_mod0,2)
	when substr(palabra_mod0,1,1)="C" and not(substr(palabra_mod0,2,1) IN ("E","I","H")) then TRANWRD(substr(palabra_mod0,1,1),"C","K")||substr(palabra_mod0,2)
else palabra_mod0
	end as palabra_mod2
from tmp0;
quit;

*Se parte la palabra en la primera letra y el resto;
*Se quitan vocales y la w de la parte resto de la palabra;
*Se codifica la parte resto dando valores a las letras;
*Se obtiene la clave de la palabra concatenando la primera letra y la codificación que se hizo de la parte resto;
data &base_salida (drop= palabra_mod0 palabra_mod palabra_mod2 primera resto nume);
set tmp2;
primera=substr(palabra_mod2,1,1);
resto=substr(palabra_mod2,2);
resto=COMPRESS(resto,"AEIOUW");
*nume=TRANSLATE(resto, "0112_3!4444-56677889","PBVFHTDSZCXYLNMQKGJR");/*Anterior*/
nume=TRANSLATE(resto, "0112_3!4444-56$77889#","PBVFHTDSZCXYLNMQKGJR#");
cve_metaphone=CATS(primera,nume);
run;
*Borras lo que ya no usas;
proc delete data= &base_entrada;
run;
proc delete data= tmp0 tmp tmp2 (memtype=view) ;
run;

%end;
%else %do;
%put Algún dato no fue proporcionado. No se hizo la codificación.;
%end;
%mend codificacion;
/*
	*Ejemplo;
	%codificacion(base_entrada=no_encontrados, base_salida=no_encontrados_cod, variable_a_codificar=diagnostico);
	DATA cie10BIS; SET cie10;RENAME DIAGNOSTICO=DIAGNOSTICO_CIE cod4=cod4_CIE;RUN;
	%codificacion(base_entrada=cie10BIS, base_salida=cie10_cod, variable_a_codificar=DIAGNOSTICO_CIE);

proc datasets lib=WORK nolist;
 change TEMPV2 = CATALOGACOMOCIE;
quit;
run;
DATA CATALOGACOMOCIE; SET CATALOGACOMOCIE;RENAME DIAGNOSTICO=DIAGNOSTICO_CIE cod4=cod4_CIE;RUN;
PROC SORT DATA=CATALOGACOMOCIE NODUPKEY;BY  SIN_ACRONIMOS_DIAGNOSTICO_CIE;RUN;
	%codificacion(base_entrada=CATALOGACOMOCIE, base_salida=catbase_cod, variable_a_codificar=DIAGNOSTICO_CIE);
*/
*******************************************************************************************
*******************************************************************************************
*******Macro para encontrar las coincidencias por clave de dos bases ya codificadas********
***************Estas bases deben tener sólo la cve_metaphone en común**********************
*******************************************************************************************
*****Base 1 debe ser la base maestra*******************************************************
*****Base 2 debe ser el catálogo***********************************************************
*******************************************************************************************;
/*  En particular, hacemos dos pasos para poder hacer el merge. Primero, se hace un merge 
	mediante las palabras sin acrónimos y, después, se hace mediante la clave originada 
	de la variante del Metaphone. En caso de que haya más de dos casos, nos quedamos con 
	la que tenga una menor distancia (combinación lineal de distancia generalizada y 
	levenshtein).		
	var_sinacron_base1 y var_sinacron_base2 son las variables SIN_ACRONIMOS que aparecen 
	en la base_salida de la codificacion;
*/
%macro matches(nombre_base1=,nombre_base2=,base_salida=, var_sinacron_base1=, var_sinacron_base2=, distancia_ged=,distancia_lev=);
%if "&nombre_base1" NE "" or "&nombre_base2" NE "" or "&base_salida" NE "" or "&var_sinacron_base1" NE "" or "&var_sinacron_base2" NE ""%then 
%do;

*Se ordena la nombre_base1 que se obtuvo de la codificación;
proc sort data=&nombre_base1;
by &var_sinacron_base1;
run;

*Se ordena la nombre_base2(catálogo) que se obtuvo de la codificación;
proc sort data=&nombre_base2 nodupkey out=cataux1;
by &var_sinacron_base2;
run;

*Primero se hace el metch mediante la variable sin acrónimos. Se generan tres bases de datos:
el primer merge, observaciones de primera base y observaciones de segunda base.;

data  nomatch1 primermerge;
MERGE &nombre_base1 (IN=A rename=(&var_sinacron_base1=sinacron)) cataux1 (IN=B rename=(&var_sinacron_base2=sinacron));
by sinacron;
if A and not B then output nomatch1;
if A and B then origen_cve="match_acroni";
if A and B then &var_sinacron_base2=sinacron;
if A and B then output primermerge;
run;

*Eliminamos columnas vacías de las bases;
%DROPMISS( nomatch1,nomatch1_1 );

*Se ordena la base1 que se obtuvo previamente;
proc sort data=nomatch1_1;
by cve_metaphone;
run;

*Se ordena la base2(catálogo) ;
proc sort data=&nombre_base2 nodupkey out=cataux2;
by cve_metaphone;
run;

* El segundo merge se hace sobre la clave metaphone a la base intermedia recién creada;
data segundomerge /view=segundomerge;
MERGE nomatch1_1(IN=A rename=(sinacron=&var_sinacron_base1)) cataux2(IN=B);
by cve_metaphone;
if A and not B then origen_cve="no_match"; 
if A and B then origen_cve="match_cve";
dist_ged=compged(&var_sinacron_base1,&var_sinacron_base2);
dist_lev=complev(&var_sinacron_base1,&var_sinacron_base2);
if A;
run;

*Se hace una lista con los diagnósticos y sus distancias generalizadas y levenshtein; 
data &base_salida (drop= /*&var_sinacron_base1 &var_sinacron_base2 origen_cve*/);
set primermerge (rename=(sinacron=&var_sinacron_base1)) segundomerge;
if (dist_ged>&distancia_ged and dist_lev>&distancia_lev and origen_cve ne "no_match") then origen_cve="match_dudoso";
run;

%end;
%else %do;
%put Algún dato no fue proporcionado. No se construyó la tabla final.;
%end;

*Borras las versiones que ya no se usaran;
	proc datasets library=WORK noprint;
	delete primermerge nomatch: cataux: &nombre_base1 &nombre_base2;
	proc delete data= segundomerge (memtype=view) ;
	run;

%mend matches;


	*Ejemplo;
	*%matches(nombre_base1=no_encontrados_cod,nombre_base2=CIE10_cod,base_salida=MATCHED, var_sinacron_base1=SIN_ACRONIMOS_DIAGNOSTICO, var_sinacron_base2=SIN_ACRONIMOS_DIAGNOSTICO_CIE, distancia_ged=400,distancia_lev=5);
	*%matches(nombre_base1=no_encontrados_cod,nombre_base2=catbase_cod,base_salida=MATCHED, var_sinacron_base1=SIN_ACRONIMOS_DIAGNOSTICO, var_sinacron_base2=SIN_ACRONIMOS_DIAGNOSTICO_CIE, distancia_ged=400,distancia_lev=5);

	*%XPORT();
/*
/**********************************************************************************************
REFERENCIAS
http://132.247.8.18:8080/intranet/downloads/uploads/2014/02/GLOSARIOINCMNSZ.pdf
