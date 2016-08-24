/* PROGRAMA PARA SIMULAR CHOQUES DE TASA A LAS LÍNEAS DE CRÉDITOS EMPRESARIALES*/
/* Hecho por la siempre confiable SEAF */

/* SUPUESTOS DEL BENCHMARK*/
/*
Los créditos no revolventes siguen un comportamineto de pago de tabla de amortización sencilla.
Al vencer, se renuevan todos los créditos no revolventes con la línea de crédito autorizada al plazo original.
Los créditos revolventes mantienen su saldo, pagando intereses mensuales sobre su línea.
Además, se supone crecimiento lineal del endeudamiento de las empresas;*/

/* SUPUESTOS DEL ESCENARIO DE CHOQUES DE TASA*/
/*
1) TASA FIJA: Los créditos NO REVOLVENTES a tasa fija se ven afectados hasta que éstos renuevan su crédito.
Los créditos REVOLVENTES a tasa fija, tanto MN como ME, no se ven afectados.

2) TASA VARIABLE ASOCIADA A TPM: Los créditos en tasa variable están asociados a la TPM se ven afectados al instante.

3) TASA VARIABLE NO ASOCIADA A TPM: Los créditos en tasa variable que no están asociados a la TPM no se ven afectados nunca;
*/

*Crecimiento en moneda nacional;
%let crecimientomn=16;
*Crecimiento en moneda extranjera;
%let crecimientome=16;

*Filtro de moneda;
%let filtroadicional= and monedanacional eq 1;

*%let filtroadicional=;
*Choque de tasa;
%let trayectoria=%nrstr( 
	v_choque1=0.5;
	v_choque2=0.5;
	v_choque3=0.5;
	v_choque4=0.5;
	v_choque5=0.5;
	v_choque6=0.75;
	v_choque7=0.75;
	v_choque8=0.75;
	v_choque9=0.75;
	v_choque10=0.75;
	v_choque11=1.0;
	v_choque12=1.0;
	);
%put &trayectoria;

/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/
/* 1) Primero vamos a calcular la dinámica de los créditos a tasa fija*/
data sasuser.amort_fija;
	set sasuser.base_serv_deu_collapse(where=(tipo_tasa="fija" &filtroadicional));

	/*SE ASIGNA LA TRAYECTORIA DE TPM*/
	&trayectoria;

	/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
	array v_interes{13};
	array v_pago{13};
	array v_respon{13};
	array v_plazo{13};
	array v_choque{13};
	array v_choquefijo{13};

	*Este es un contador que indica cuántas veces ha vencido el crédito;
	cont=0;

	*Se inicializa el choque en cero porque en el primer período no paga porque aún no vence (recordar que se les dio un mes más);
	v_choquefijo{1}=0;

	*Aquí hacemos el caso de los NO REVOLVENTES EN MONEDA EXTRANJERA;
	if revolvente=0 and monedanacional=0 then
		do;
			/*SE LLENA LA PRIMERA ENTRADA DE CADA UNO DE LOS VECTORES*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = (respon*tasa/1200)/(1-(1/((1+tasa/1200)**plazo)));
			v_respon{1} = round(respon-v_pago{1}+v_interes{1},.0001);
			v_plazo{1} = plazo-1;

			/*CON ESTE DO SE LLENA EL RESTO DE LOS VALORES DE CADA VECTOR*/
			do i=2 to 12;
				IF v_plazo[i-1] = 0 THEN
					DO;
						*Este es un contandor de cuántas veces se ha renovado el crédito (cuántas veces entra al loop);
						cont=cont+1;

						*Si se renueva el crédito, a la variable choquefijo se le asigna la trayectoria de choque tpm del mes;
						v_choquefijo[i]=v_choque[i];
						v_respon[i]=linea*((1+&crecimientome*(max(plazo_ori,1))/1200))**cont;
						*v_respon[i]=linea*(1+&crecimientome*(max(plazo_ori,1))/1200);
						v_interes[i]=v_respon[i]*(tasa+v_choquefijo[i])/1200;
						v_pago[i]=(v_respon[i]*(tasa+v_choquefijo[i])/1200)/(1-(1/((1+(tasa+v_choquefijo[i])/1200)**(max(plazo_ori,1)))));
						v_plazo[i]=(max(plazo_ori,1));
					end;
				else
					do;
						v_choquefijo[i]=v_choquefijo[i-1];
						v_interes[i]=v_respon[i-1]*(tasa+v_choquefijo[i])/1200;
						v_pago[i]=(v_respon[i-1]*(tasa+v_choquefijo[i])/1200)/(1-(1/((1+(tasa+v_choquefijo[i])/1200)**v_plazo[i-1])));
						v_respon[i]=round(v_respon[i-1]-v_pago[i]+v_interes[i],.0001);
						v_plazo[i]=v_plazo[i-1]-1;
					end;
			end;
		end;

	/*Aquí hacemos el caso de los NO REVOLVENTES EN MONEDA NACIONAL*/
	else if revolvente=0 and monedanacional=1 then
		do;
			/*	/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			/*SE LLENA LA PRIMERA ENTRADA DE CADA UNO DE LOS VECTORES*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = (respon*tasa/1200)/(1-(1/((1+tasa/1200)**plazo)));
			v_respon{1} = round(respon-v_pago{1}+v_interes{1},.0001);
			v_plazo{1} = plazo-1;

			/*CON ESTE DO SE LLENA EL RESTO DE LOS VALORES DE CADA VECTOR*/
			do i=2 to 12;
				IF v_plazo[i-1] = 0 THEN
					DO;
						*Este es un contandor de cuántas veces se ha renovado el crédito (cuántas veces entra al loop);
						cont=cont+1;

						*Si se renueva el crédito, a la variable choquefijo se le asigna la trayectoria de choque tpm del mes;
						v_choquefijo[i]=v_choque[i];
						v_respon[i]=linea*((1+&crecimientomn*(max(plazo_ori,1))/1200))**cont;
						v_interes[i]=v_respon[i]*(tasa+v_choquefijo[i])/1200;
						v_pago[i]=(v_respon[i]*(tasa+v_choquefijo[i])/1200)/(1-(1/((1+(tasa+v_choquefijo[i])/1200)**(max(plazo_ori,1)))));
						v_plazo[i]=(max(plazo_ori,1));
					end;
				else
					do;
						v_choquefijo[i]=v_choquefijo[i-1];
						v_interes[i]=v_respon[i-1]*(tasa+v_choquefijo[i])/1200;
						v_pago[i]=(v_respon[i-1]*(tasa+v_choquefijo[i])/1200)/(1-(1/((1+(tasa+v_choquefijo[i])/1200)**v_plazo[i-1])));
						v_respon[i]=round(v_respon[i-1]-v_pago[i]+v_interes[i],.0001);
						v_plazo[i]=v_plazo[i-1]-1;
					end;
			end;
		end;

	/*Hacemos el caso de los REVOLVENTES EN MONEDA EXTRANJERA*/
	else if revolvente=1 and monedanacional=0 then
		do;
			*Hacemos el caso de los REVOLVENTES;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = respon;
			v_respon{1} = respon*(1+&crecimientome/1200);
			v_plazo[1]=999;

			do i=2 to 12;
				v_interes[i]=v_respon[i-1] * tasa/1200;
				v_pago[i]=v_respon[i-1];
				v_respon[i]=v_respon[i-1]*(1+&crecimientome/1200);
				v_plazo[i]=999;
			end;
		end;
	else
		do;
			*Hacemos el caso de los REVOLVENTES EN MONEDA NACIONAL;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = respon;
			v_respon{1} = respon*(1+&crecimientomn/1200);
			v_plazo[1]=999;

			do i=2 to 12;
				v_interes[i]=v_respon[i-1] * tasa/1200;
				v_pago[i]=v_respon[i-1];
				v_respon[i]=v_respon[i-1]*(1+&crecimientomn/1200);
				v_plazo[i]=999;
			end;
		end;
run;

/*************************************************************************************************/
/* 2) Ahora vamos a hacer la dinámica de los créditos que tienen tasa variable asociada a la TPM */
data sasuser.amort_variable_tpm;
	set sasuser.base_serv_deu_collapse(where=(tpm=1 and tipo_tasa="variable" &filtroadicional));

	/*SE ASIGNA LA TRAYECTORIA DE TPM*/
	&trayectoria;

	*Este es un contador que indica cuántas veces ha vencido tu crédito;
	cont=0;

	*Aquí hacemos el caso de los NO REVOLVENTES EN MONEDA EXTRANJERA;
	if revolvente=0 and monedanacional=0 then
		do;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			array v_interes{13};
			array v_pago{13};
			array v_respon{13};
			array v_plazo{13};
			array v_choque{13};

			/*SE LLENA LA PRIMERA ENTRADA DE CADA UNO DE LOS VECTORES*/
			v_interes{1} = respon * (tasa+v_choque[1])/1200;
			v_pago{1} = (respon*(tasa+v_choque[1])/1200)/(1-(1/((1+(tasa+v_choque[1])/1200)**plazo)));
			v_respon{1} = round(respon-v_pago{1}+v_interes{1},.0001);
			v_plazo{1} = plazo-1;

			/*CON ESTE DO SE LLENA EL RESTO DE LOS VALORES DE CADA VECTOR*/
			do i=2 to 12;
				IF v_plazo[i-1] = 0 THEN
					DO;
						cont=cont+1;
						v_respon[i]=linea*((1+&crecimientome*(max(plazo_ori,1))/1200))**cont;

						*v_respon[i]=linea*(1+&crecimientome*(max(plazo_ori,1))/1200);
						v_interes[i]=v_respon[i]*(tasa+v_choque[i])/1200;
						v_pago[i]=(v_respon[i]*(tasa+v_choque[i])/1200)/(1-(1/((1+(tasa+v_choque[i])/1200)**(max(plazo_ori,1)))));
						v_plazo[i]=(max(plazo_ori,1));
					end;
				else
					do;
						v_interes[i]=v_respon[i-1]*(tasa+v_choque[i])/1200;
						v_pago[i]=(v_respon[i-1]*(tasa+v_choque[i])/1200)/(1-(1/((1+(tasa+v_choque[i])/1200)**v_plazo[i-1])));
						v_respon[i]=round(v_respon[i-1]-v_pago[i]+v_interes[i],.0001);
						v_plazo[i]=v_plazo[i-1]-1;
					end;
			end;
		end;

	/*Aquí hacemos el caso de los NO REVOLVENTES EN MONEDA NACIONAL*/
	else if revolvente=0 and monedanacional=1 then
		do;
			/*	/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			/*SE LLENA LA PRIMERA ENTRADA DE CADA UNO DE LOS VECTORES*/
			v_interes{1} = respon * (tasa+v_choque[1])/1200;
			v_pago{1} = (respon*(tasa+v_choque[1])/1200)/(1-(1/((1+(tasa+v_choque[1])/1200)**plazo)));
			v_respon{1} = round(respon-v_pago{1}+v_interes{1},.0001);
			v_plazo{1} = plazo-1;

			/*CON ESTE DO SE LLENA EL RESTO DE LOS VALORES DE CADA VECTOR*/
			do i=2 to 12;
				IF v_plazo[i-1] = 0 THEN
					DO;
						cont=cont+1;
						v_respon[i]=linea*((1+&crecimientomn*(max(plazo_ori,1))/1200))**cont;

						*v_respon[i]=linea*(1+&crecimientomn*(max(plazo_ori,1))/1200);
						v_interes[i]=v_respon[i]*(tasa+v_choque[i])/1200;
						v_pago[i]=(v_respon[i]*(tasa+v_choque[i])/1200)/(1-(1/((1+(tasa+v_choque[i])/1200)**(max(plazo_ori,1)))));
						v_plazo[i]=(max(plazo_ori,1));
					end;
				else
					do;
						v_interes[i]=v_respon[i-1]*(tasa+v_choque[i])/1200;
						v_pago[i]=(v_respon[i-1]*(tasa+v_choque[i])/1200)/(1-(1/((1+(tasa+v_choque[i])/1200)**v_plazo[i-1])));
						v_respon[i]=round(v_respon[i-1]-v_pago[i]+v_interes[i],.0001);
						v_plazo[i]=v_plazo[i-1]-1;
					end;
			end;
		end;

	/*Hacemos el caso de los REVOLVENTES EN MONEDA EXTRANJERA*/
	else if revolvente=1 and monedanacional=0 then
		do;
			*Hacemos el caso de los REVOLVENTES;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			v_interes{1} = respon * (tasa+v_choque[1])/1200;
			v_pago{1} = respon;
			v_respon{1} = respon*(1+&crecimientome/1200);
			v_plazo[1]=999;

			do i=2 to 12;
				v_interes[i]=v_respon[i-1] * (tasa+v_choque[i])/1200;
				v_pago[i]=v_respon[i-1];
				v_respon[i]=v_respon[i-1]*(1+&crecimientome/1200);
				v_plazo[i]=999;
			end;
		end;
	else
		do;
			*Hacemos el caso de los REVOLVENTES EN MONEDA NACIONAL;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			v_interes{1} = respon * (tasa+v_choque[1])/1200;
			v_pago{1} = respon;
			v_respon{1} = respon*(1+&crecimientomn/1200);
			v_plazo[1]=999;

			do i=2 to 12;
				v_interes[i]=v_respon[i-1] * (tasa+v_choque[i])/1200;
				v_pago[i]=v_respon[i-1];
				v_respon[i]=v_respon[i-1]*(1+&crecimientomn/1200);
				v_plazo[i]=999;
			end;
		end;
run;

/* 3) ahora vamos a hacer la dinámica de los créditos en tasa variable que no están asociados a la TPM*/
data sasuser.amort_variable_notpm;
	set sasuser.base_serv_deu_collapse(where=(tpm=0 and tipo_tasa="variable" &filtroadicional));

	/*SE ASIGNA LA TRAYECTORIA DE TPM*/
	&trayectoria;

	*Este es un contador que indica cuántas veces ha vencido tu crédito;
	cont=0;

	*Aquí hacemos el caso de los NO REVOLVENTES EN MONEDA EXTRANJERA;
	if revolvente=0 and monedanacional=0 then
		do;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			array v_interes{13};
			array v_pago{13};
			array v_respon{13};
			array v_plazo{13};
			array v_choque{13};

			/*SE LLENA LA PRIMERA ENTRADA DE CADA UNO DE LOS VECTORES*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = (respon*tasa/1200)/(1-(1/((1+tasa/1200)**plazo)));
			v_respon{1} = round(respon-v_pago{1}+v_interes{1},.0001);
			v_plazo{1} = plazo-1;

			/*CON ESTE DO SE LLENA EL RESTO DE LOS VALORES DE CADA VECTOR*/
			do i=2 to 12;
				IF v_plazo[i-1] = 0 THEN
					DO;
						cont=cont+1;
						v_respon[i]=linea*((1+&crecimientome*(max(plazo_ori,1))/1200))**cont;

						*v_respon[i]=linea*(1+&crecimientome*(max(plazo_ori,1))/1200);
						v_interes[i]=v_respon[i]*tasa/1200;
						v_pago[i]=(v_respon[i]*tasa/1200)/(1-(1/((1+tasa/1200)**(max(plazo_ori,1)))));
						v_plazo[i]=(max(plazo_ori,1));
					end;
				else
					do;
						v_interes[i]=v_respon[i-1]*tasa/1200;
						v_pago[i]=(v_respon[i-1]*tasa/1200)/(1-(1/((1+tasa/1200)**v_plazo[i-1])));
						v_respon[i]=round(v_respon[i-1]-v_pago[i]+v_interes[i],.0001);
						v_plazo[i]=v_plazo[i-1]-1;
					end;
			end;
		end;

	/*Aquí hacemos el caso de los NO REVOLVENTES EN MONEDA NACIONAL*/
	else if revolvente=0 and monedanacional=1 then
		do;
			/*	/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			/*SE LLENA LA PRIMERA ENTRADA DE CADA UNO DE LOS VECTORES*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = (respon*tasa/1200)/(1-(1/((1+tasa/1200)**plazo)));
			v_respon{1} = round(respon-v_pago{1}+v_interes{1},.0001);
			v_plazo{1} = plazo-1;

			/*CON ESTE DO SE LLENA EL RESTO DE LOS VALORES DE CADA VECTOR*/
			do i=2 to 12;
				IF v_plazo[i-1] = 0 THEN
					DO;
						cont=cont+1;
						v_respon[i]=linea*((1+&crecimientomn*(max(plazo_ori,1))/1200))**cont;

						*v_respon[i]=linea*(1+&crecimientomn*(max(plazo_ori,1))/1200);
						v_interes[i]=v_respon[i]*tasa/1200;
						v_pago[i]=(v_respon[i]*tasa/1200)/(1-(1/((1+tasa/1200)**(max(plazo_ori,1)))));
						v_plazo[i]=(max(plazo_ori,1));
					end;
				else
					do;
						v_interes[i]=v_respon[i-1]*tasa/1200;
						v_pago[i]=(v_respon[i-1]*tasa/1200)/(1-(1/((1+tasa/1200)**v_plazo[i-1])));
						v_respon[i]=round(v_respon[i-1]-v_pago[i]+v_interes[i],.0001);
						v_plazo[i]=v_plazo[i-1]-1;
					end;
			end;
		end;

	/*Hacemos el caso de los REVOLVENTES EN MONEDA EXTRANJERA*/
	else if revolvente=1 and monedanacional=0 then
		do;
			*Hacemos el caso de los REVOLVENTES;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = respon;
			v_respon{1} = respon*(1+&crecimientome/1200);
			v_plazo[1]=999;

			do i=2 to 12;
				v_interes[i]=v_respon[i-1] * tasa/1200;
				v_pago[i]=v_respon[i-1];
				v_respon[i]=v_respon[i-1]*(1+&crecimientome/1200);
				v_plazo[i]=999;
			end;
		end;
	else
		do;
			*Hacemos el caso de los REVOLVENTES EN MONEDA NACIONAL;
			/*SE GENERAN LOS VECTORES, SOLO CORRE 12 MESES (SE DEBE DE PONER 1 MES MAS DE LOS QUE SE QUIERAN CORRER)*/
			v_interes{1} = respon * tasa/1200;
			v_pago{1} = respon;
			v_respon{1} = respon*(1+&crecimientomn/1200);
			v_plazo[1]=999;

			do i=2 to 12;
				v_interes[i]=v_respon[i-1] * tasa/1200;
				v_pago[i]=v_respon[i-1];
				v_respon[i]=v_respon[i-1]*(1+&crecimientomn/1200);
				v_plazo[i]=999;
			end;
		end;
run;

/* JUNTAMOS LAS BASES */
DATA sasuser.escenario_cambiotasa;
	set  sasuser.amort_fija sasuser.amort_variable_tpm sasuser.amort_variable_notpm;
run;

/* Aquí ponemos el resumen de la ruta con cambio de tasa */
proc means  data=sasuser.escenario_cambiotasa nway missing noprint;
	output out= cambiotasa_results (DROP=_FREQ_ _TYPE_)
		sum( respon v_respon: v_pago: v_interes:)=;
run;
