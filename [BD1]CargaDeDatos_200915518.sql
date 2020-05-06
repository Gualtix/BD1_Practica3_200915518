/* Script DML: Carga de Datos al Modelo Relacional */

/*TIPO_EMPLEADO****************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_TIPO_EMPLEADO() AS $$
BEGIN
	INSERT INTO TIPO_EMPLEADO(tipo) VALUES('vendedor');
	INSERT INTO TIPO_EMPLEADO(tipo) VALUES('jefe');
END;
$$ LANGUAGE plpgsql;

CALL LOAD_TIPO_EMPLEADO();
SELECT * FROM TIPO_EMPLEADO();
SELECT COUNT(*) FROM TIPO_EMPLEADO;
/*TIPOS DE EMPLEADOS: 2*/
/******************************************************************************************************************/


















/*PAIS*************************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_PAIS() AS $$
DECLARE 
	GENIS CURSOR FOR
	SELECT PAIS_CLIENTE FROM TMP WHERE TMP.PAIS_CLIENTE != '-'
	UNION
	SELECT PAIS_EMPLEADO FROM TMP WHERE TMP.PAIS_EMPLEADO != '-'
	UNION
	SELECT PAIS_TIENDA FROM TMP WHERE TMP.PAIS_TIENDA != '-';
	
BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO PAIS(nombre) VALUES (GN.PAIS_CLIENTE);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'PAIS_CLIENTE: ',GN.PAIS_CLIENTE;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_PAIS();
SELECT * FROM PAIS;
SELECT COUNT(*) FROM PAIS;
/*PAISES: 109*/
/******************************************************************************************************************/


























/*CIUDAD***********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_CIUDAD() AS $$
DECLARE 
	id_pais INTEGER  := 0;
	postal  INTEGER  := 0;

	GENIS CURSOR FOR
	SELECT CIUDAD_CLIENTE,PAIS_CLIENTE,CODIGO_POSTAL_CLIENTE FROM TMP WHERE TMP.CIUDAD_CLIENTE != '-'
	UNION
	SELECT CIUDAD_EMPLEADO,PAIS_EMPLEADO,CODIGO_POSTAL_EMPLEADO FROM TMP WHERE TMP.CIUDAD_EMPLEADO != '-'
	UNION
	SELECT CIUDAD_TIENDA,PAIS_TIENDA,CODIGO_POSTAL_TIENDA FROM TMP WHERE TMP.CIUDAD_TIENDA != '-'; 
	/*
	SELECT DISTINCT ON (CIUDAD_CLIENTE) PAIS_CLIENTE,CIUDAD_CLIENTE,CODIGO_POSTAL_CLIENTE
	FROM TMP WHERE CIUDAD_CLIENTE !='-'
	ORDER BY CIUDAD_CLIENTE;
	*/
BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		SELECT id INTO id_pais FROM PAIS WHERE GN.PAIS_CLIENTE = PAIS.nombre;

		IF GN.CODIGO_POSTAL_CLIENTE = '-' THEN
			GN.CODIGO_POSTAL_CLIENTE = NULL;
    	END IF;

		INSERT INTO CIUDAD(nombre,codigo_postal,fk_pais) VALUES (GN.CIUDAD_CLIENTE,CAST(GN.CODIGO_POSTAL_CLIENTE AS INTEGER),id_pais);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'PAIS_CLIENTE: ',GN.CIUDAD_CLIENTE;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_CIUDAD();
SELECT * FROM CIUDAD;
SELECT COUNT(*) FROM CIUDAD;
/*CIUDADES: 599*/
/******************************************************************************************************************/














































/*DIRECCION********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_DIRECCION() AS $$
DECLARE 
	id_ciudad INTEGER  := 0;
	GENIS CURSOR FOR
	SELECT DISTINCT ON (DIRECCION_CLIENTE) DIRECCION_CLIENTE,CIUDAD_CLIENTE
	FROM TMP WHERE DIRECCION_CLIENTE !='-';


BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		SELECT id INTO id_ciudad FROM CIUDAD WHERE GN.CIUDAD_CLIENTE = CIUDAD.nombre;

		IF GN.CIUDAD_CLIENTE = '-' THEN
			GN.CIUDAD_CLIENTE = NULL;
    	END IF;

		INSERT INTO DIRECCION(descripcion,fk_ciudad) VALUES (GN.DIRECCION_CLIENTE,id_ciudad);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'PAIS_CLIENTE: ',GN.DIRECCION_CLIENTE;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_DIRECCION();
SELECT * FROM DIRECCION;
SELECT COUNT(*) FROM DIRECCION;
/*DIRECCION: 603*/
/******************************************************************************************************************/



































/*TIENDA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_TIENDA() AS $$
DECLARE 
	id_direccion INTEGER  := 0;
	GENIS CURSOR FOR
	SELECT DISTINCT ON (NOMBRE_TIENDA) NOMBRE_TIENDA,DIRECCION_TIENDA
	FROM TMP WHERE NOMBRE_TIENDA !='-';


BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		SELECT id INTO id_direccion FROM DIRECCION WHERE GN.DIRECCION_TIENDA= DIRECCION.descripcion;

		IF GN.DIRECCION_TIENDA = '-' THEN
			GN.DIRECCION_TIENDA = NULL;
    	END IF;

		IF GN.DIRECCION_TIENDA = '-' THEN
			GN.DIRECCION_TIENDA = NULL;
    	END IF;

		INSERT INTO TIENDA(nombre,fk_direccion) VALUES (GN.NOMBRE_TIENDA,id_direccion);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'PAIS_CLIENTE: ',GN.NOMBRE_TIENDA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_TIENDA();
SELECT * FROM TIENDA;
SELECT COUNT(*) FROM TIENDA;
/*TIENDA: 2*/
/******************************************************************************************************************/

































/*CLIENTE********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_CLIENTE() AS $$
DECLARE 
	id_direccion        INTEGER  := 0;
	id_tienda_preferida INTEGER  := 0;
	GENIS CURSOR FOR
	SELECT DISTINCT ON (NOMBRE_CLIENTE) NOMBRE_CLIENTE,CORREO_CLIENTE,CLIENTE_ACTIVO,FECHA_CREACION,TIENDA_PREFERIDA,DIRECCION_CLIENTE
	FROM TMP WHERE NOMBRE_CLIENTE !='-';


BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		
		SELECT id INTO id_tienda_preferida FROM TIENDA    WHERE GN.TIENDA_PREFERIDA  = TIENDA.nombre;
		SELECT id INTO id_direccion        FROM DIRECCION WHERE GN.DIRECCION_CLIENTE = DIRECCION.descripcion;

		IF GN.DIRECCION_CLIENTE = '-' THEN
			GN.DIRECCION_CLIENTE = NULL;
    	END IF;

		IF GN.TIENDA_PREFERIDA = '-' THEN
			GN.TIENDA_PREFERIDA = NULL;
    	END IF;

		INSERT INTO CLIENTE(nombre,apellido,email,estado,fecha_registro,fk_tienda_preferida,fk_direccion) 
		VALUES (
			SPLIT_PART(GN.NOMBRE_CLIENTE,' ',1),
			SPLIT_PART(GN.NOMBRE_CLIENTE,' ',2),
			GN.CORREO_CLIENTE,
			GN.CLIENTE_ACTIVO,
		    to_date(GN.FECHA_CREACION,'DD/MM/YYYY'), 
			id_tienda_preferida,
			id_direccion


		);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'PAIS_CLIENTE: ',GN.DIRECCION_CLIENTE;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_CLIENTE();
SELECT * FROM CLIENTE;
SELECT COUNT(*) FROM CLIENTE;
/*CLIENTE: 599*/
/******************************************************************************************************************/




































/*CUENTA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_CUENTA() AS $$
DECLARE 

	GENIS CURSOR FOR
	SELECT DISTINCT ON (USUARIO_EMPLEADO) USUARIO_EMPLEADO,*
	FROM TMP WHERE USUARIO_EMPLEADO !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO CUENTA(usr,passwo) 
		VALUES (GN.USUARIO_EMPLEADO,GN.CONTRASENIA_EMPLEADO);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'USUARIO_EMPLEADO: ',GN.USUARIO_EMPLEADO;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_CUENTA();
SELECT * FROM CUENTA;
SELECT COUNT(*) FROM CUENTA;
/*CUENTA: 2*/
/******************************************************************************************************************/







































/*EMPLEADO********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_EMPLEADO() AS $$
DECLARE 
	id_tienda   INTEGER  := 0;
	id_direccion INTEGER  := 0;

	id_cuenta    INTEGER  := 0;
	id_tipo_empleado INTEGER  := 0;

	GENIS CURSOR FOR
	SELECT DISTINCT ON (NOMBRE_EMPLEADO) NOMBRE_EMPLEADO,*
	FROM TMP WHERE NOMBRE_EMPLEADO !='-';


BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		
		SELECT id INTO id_tienda    FROM TIENDA    WHERE GN.TIENDA_EMPLEADO  = TIENDA.nombre;
		SELECT id INTO id_direccion FROM DIRECCION WHERE GN.DIRECCION_EMPLEADO = DIRECCION.descripcion;

		IF GN.USUARIO_EMPLEADO = 'Jon' THEN
			id_cuenta = 1;
			id_tipo_empleado = 2;
    	END IF;

		IF GN.USUARIO_EMPLEADO = 'Mike' THEN
			id_cuenta = 2;
			id_tipo_empleado = 2;
    	END IF;

		IF GN.TIENDA_EMPLEADO = '-' THEN
			GN.TIENDA_EMPLEADO = NULL;
    	END IF;

		IF GN.DIRECCION_EMPLEADO = '-' THEN
			GN.DIRECCION_EMPLEADO = NULL;
    	END IF;

		INSERT INTO EMPLEADO(nombre,apellido,email,estado,fk_tienda,fk_direccion,fk_cuenta,fk_tipo) 
		VALUES (
			SPLIT_PART(GN.NOMBRE_EMPLEADO,' ',1),
			SPLIT_PART(GN.NOMBRE_EMPLEADO,' ',2),
			GN.CORREO_EMPLEADO,
			GN.EMPLEADO_ACTIVO,
			id_tienda,
			id_direccion,
			id_cuenta,
			id_tipo_empleado
		);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'NOMBRE_EMPLEADO: ',GN.NOMBRE_EMPLEADO;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_EMPLEADO();
SELECT * FROM EMPLEADO;
SELECT COUNT(*) FROM EMPLEADO;
/*EMPLEADO: 2*/
/******************************************************************************************************************/

































/*CATEGORIA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_CATEGORIA() AS $$
DECLARE 

	GENIS CURSOR FOR
	SELECT DISTINCT ON (CATEGORIA_PELICULA) CATEGORIA_PELICULA,*
	FROM TMP WHERE CATEGORIA_PELICULA !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO CATEGORIA(nombre)
		VALUES (GN.CATEGORIA_PELICULA);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'CATEGORIA_PELICULA: ',GN.CATEGORIA_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_CATEGORIA();
SELECT * FROM CATEGORIA;
SELECT COUNT(*) FROM CATEGORIA;
/*CATEGORIA: 16*/
/******************************************************************************************************************/




































/*CLASIFICACION********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_CLASIFICACION() AS $$
DECLARE 

	GENIS CURSOR FOR
	SELECT DISTINCT ON (CLASIFICACION) CLASIFICACION,*
	FROM TMP WHERE CLASIFICACION !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO CLASIFICACION(nombre)
		VALUES (GN.CLASIFICACION);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'CLASIFICACION: ',GN.CLASIFICACION;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_CLASIFICACION();
SELECT * FROM CLASIFICACION;
SELECT COUNT(*) FROM CLASIFICACION;
/*CLASIFICACION: 5*/
/******************************************************************************************************************/




































/*LENGUAJE********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_LENGUAJE() AS $$
DECLARE 

	GENIS CURSOR FOR
	SELECT DISTINCT ON (LENGUAJE_PELICULA) LENGUAJE_PELICULA,*
	FROM TMP WHERE LENGUAJE_PELICULA !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO IDIOMA(nombre)
		VALUES (GN.LENGUAJE_PELICULA);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'LENGUAJE_PELICULA: ',GN.LENGUAJE_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_LENGUAJE();
SELECT * FROM IDIOMA;
SELECT COUNT(*) FROM IDIOMA;
/*LENGUAJE: 6*/
/******************************************************************************************************************/






































/*ACTOR********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_ACTOR() AS $$
DECLARE 

	GENIS CURSOR FOR
	/*
	SELECT DISTINCT ON (ACTOR_PELICULA) ACTOR_PELICULA,*
	FROM TMP WHERE ACTOR_PELICULA !='-' AND ACTOR_PELICULA NOT LIKE '%,%'; 
	*/
	SELECT DISTINCT ON (ACTOR_PELICULA) ACTOR_PELICULA,*
	FROM TMP WHERE ACTOR_PELICULA !='-' 
	AND ACTOR_PELICULA LIKE '%,%'
	AND ACTOR_PELICULA !='-,'; 

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO ACTOR(nombre,apellido)
		/*VALUES (SPLIT_PART(GN.ACTOR_PELICULA,' ',1),SPLIT_PART(GN.ACTOR_PELICULA,' ',2));*/
		VALUES (SPLIT_PART(GN.ACTOR_PELICULA,' ',1),RTRIM(SPLIT_PART(GN.ACTOR_PELICULA,' ',2),','));
		
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'ACTOR_PELICULA: ',GN.ACTOR_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_ACTOR();
SELECT * FROM ACTOR;
SELECT COUNT(*) FROM ACTOR;
/*ACTOR: 199*/
/******************************************************************************************************************/

































/*LENGUAJE********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_LENGUAJE() AS $$
DECLARE 

	GENIS CURSOR FOR
	SELECT DISTINCT ON (LENGUAJE_PELICULA) LENGUAJE_PELICULA,*
	FROM TMP WHERE LENGUAJE_PELICULA !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		INSERT INTO IDIOMA(nombre)
		VALUES (GN.LENGUAJE_PELICULA);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'LENGUAJE_PELICULA: ',GN.LENGUAJE_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_LENGUAJE();
SELECT * FROM IDIOMA;
SELECT COUNT(*) FROM IDIOMA;
/*LENGUAJE: 6*/
/******************************************************************************************************************/































    





/*PELICULA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_PELICULA() AS $$
DECLARE 

	id_idioma        INTEGER  := 0;
	id_clasificacion INTEGER  := 0;

	GENIS CURSOR FOR
	SELECT DISTINCT ON (NOMBRE_PELICULA) NOMBRE_PELICULA,*
	FROM TMP WHERE NOMBRE_PELICULA !='-'; 

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN

		SELECT id INTO id_idioma        FROM IDIOMA        WHERE GN.LENGUAJE_PELICULA  = IDIOMA.nombre;
		SELECT id INTO id_clasificacion FROM CLASIFICACION WHERE GN.CLASIFICACION      = CLASIFICACION.nombre;

		INSERT INTO PELICULA
		(
			titulo,
			descripcion,
			anio_lanzamiento,
			costo_renta,
			duracion_min,
			max_dias_renta,
			costo_danio,
			fk_idioma,
			fk_clasificacion
		)
		VALUES 
		(
			GN.NOMBRE_PELICULA,
			GN.DESCRIPCION_PELICULA,
			CAST(GN.ANIO_LANZAMIENTO AS INTEGER),
			CAST(GN.COSTO_RENTA AS double precision),
			CAST(GN.DURACION AS INTEGER),
			CAST(GN.DIAS_RENTA AS INTEGER),
			CAST(GN.COSTO_POR_DANIO AS double precision),
			id_idioma,
			id_clasificacion
		);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'NOMBRE_PELICULA: ',GN.NOMBRE_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_PELICULA();
SELECT * FROM PELICULA;
SELECT COUNT(*) FROM PELICULA;
/*PELICULA: 1000*/
/******************************************************************************************************************/











/*ASG_CATEGORIA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_ASG_CATEGORIA() AS $$
DECLARE 

	id_pelicula  INTEGER  := 0;
	id_categoria INTEGER  := 0;

	GENIS CURSOR FOR
	SELECT DISTINCT ON (NOMBRE_PELICULA) NOMBRE_PELICULA,*
	FROM TMP WHERE NOMBRE_PELICULA !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		SELECT id INTO id_pelicula FROM PELICULA WHERE GN.NOMBRE_PELICULA = PELICULA.titulo;
		SELECT id INTO id_categoria FROM CATEGORIA WHERE GN.CATEGORIA_PELICULA = CATEGORIA.nombre;
		INSERT INTO ASIGNACION_CATEGORIA(fk_pelicula,fk_categoria)
		VALUES (id_pelicula,id_categoria);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'ASG_CATEGORIA_PELICULA: ',GN.NOMBRE_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_ASG_CATEGORIA();
SELECT * FROM ASIGNACION_CATEGORIA;
SELECT COUNT(*) FROM ASIGNACION_CATEGORIA;
/*ASG_CATEGORIA: 1000*/
/******************************************************************************************************************/









































/*ASG_ACTOR********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_ASG_ACTOR() AS $$
DECLARE 

	id_pelicula INTEGER  := 0;
	id_actor INTEGER  := 0;

	GENIS CURSOR FOR
	SELECT DISTINCT ON (NOMBRE_PELICULA,ACTOR_PELICULA) NOMBRE_PELICULA,ACTOR_PELICULA,*
	FROM TMP WHERE NOMBRE_PELICULA !='-' AND ACTOR_PELICULA !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		
		SELECT id INTO id_pelicula FROM PELICULA WHERE GN.NOMBRE_PELICULA = PELICULA.titulo;
		/*SELECT id INTO id_actor FROM ACTOR WHERE GN.ACTOR_PELICULA = CONCAT(ACTOR.nombre,' ',ACTOR.apellido,',');*/
		SELECT id INTO id_actor FROM ACTOR WHERE RTRIM(GN.ACTOR_PELICULA,',') = CONCAT(ACTOR.nombre,' ',ACTOR.apellido);
		INSERT INTO ASIGNACION_ACTOR(fk_pelicula,fk_actor)
		VALUES (id_pelicula,id_actor);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'ASG_CATEGORIA_PELICULA: ',GN.ACTOR_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_ASG_ACTOR();
SELECT * FROM ASIGNACION_ACTOR;
SELECT COUNT(*) FROM ASIGNACION_ACTOR;
/*ASG_ACTOR: 881*/
/******************************************************************************************************************/


































/*ASG_PELICULA_TIENDA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_ASG_PELICULA_TIENDA() AS $$
DECLARE 
	st_td1  INTEGER  := 0;
	st_td2  INTEGER  := 0;
	GENIS CURSOR FOR
	SELECT * FROM PELICULA;

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		/*TIENDA 1***************/
			SELECT COUNT(*) INTO st_td1
			FROM TMP 
			WHERE TMP.NOMBRE_PELICULA = GN.titulo 
			AND 
			TMP.NOMBRE_PELICULA != '-'
			AND TMP.TIENDA_PELICULA = 'Tienda 1';
		/************************/

		/*TIENDA 2***************/
			SELECT COUNT(*) INTO st_td2
			FROM TMP 
			WHERE TMP.NOMBRE_PELICULA = GN.titulo 
			AND 
			TMP.NOMBRE_PELICULA != '-'
			AND TMP.TIENDA_PELICULA = 'Tienda 2';
		/************************/

		INSERT INTO ASIGNACION_PELICULA_TIENDA(fk_tienda,fk_pelicula,stock)
		VALUES (1,GN.id,st_td1);

		INSERT INTO ASIGNACION_PELICULA_TIENDA(fk_tienda,fk_pelicula,stock)
		VALUES (2,GN.id,st_td2);

		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'ASG_ASG_PELICULA_TIENDA: ',GN.NOMBRE_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_ASG_PELICULA_TIENDA();
SELECT * FROM ASIGNACION_PELICULA_TIENDA;
SELECT COUNT(*) FROM ASIGNACION_PELICULA_TIENDA;
/*ASG_PELICULA_TIENDA: 2000*/
/******************************************************************************************************************/









/*RENTA********************************************************************************************************/
CREATE OR REPLACE PROCEDURE LOAD_RENTA() AS $$
DECLARE 
	id_cliente  INTEGER  := 0;
	id_empleado  INTEGER  := 0;
	id_pelicula  INTEGER  := 0;
	id_tienda    INTEGER  := 0;

	GENIS CURSOR FOR
	SELECT DISTINCT ON (FECHA_RENTA,NOMBRE_CLIENTE) FECHA_RENTA,NOMBRE_CLIENTE,* FROM TMP WHERE FECHA_RENTA !='-';

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
			
		SELECT id INTO id_cliente  FROM CLIENTE  WHERE GN.NOMBRE_CLIENTE  = CONCAT(CLIENTE.nombre,' ',CLIENTE.apellido);
		SELECT id INTO id_empleado FROM EMPLEADO WHERE GN.NOMBRE_EMPLEADO = CONCAT(EMPLEADO.nombre,' ',EMPLEADO.apellido);
		SELECT id INTO id_pelicula FROM PELICULA WHERE GN.NOMBRE_PELICULA = PELICULA.titulo;
		SELECT id INTO id_tienda   FROM TIENDA   WHERE GN.NOMBRE_TIENDA = TIENDA.nombre;
	
		INSERT INTO RENTA(monto_pagar,fecha_renta,fecha_retorno,fk_cliente,fk_empleado,fk_pelicula,fk_tienda)
		VALUES 
		(
			CAST(GN.MONTO_A_PAGAR AS double precision),
			TO_TIMESTAMP(GN.FECHA_RENTA, 'DD/MM/YYYY HH24:MI'),
			TO_TIMESTAMP(GN.FECHA_RENTA, 'DD/MM/YYYY HH24:MI'),
			id_cliente,
			id_empleado,
			id_pelicula,
			id_tienda
		);
		EXCEPTION WHEN OTHERS THEN
		raise notice '% % % %', SQLERRM, SQLSTATE,'RENTA: ',GN.NOMBRE_PELICULA;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL LOAD_RENTA();
SELECT * FROM RENTA;
SELECT COUNT(*) FROM RENTA;
/*RENTA: 16014*/
/******************************************************************************************************************/


CALL LOAD_TIPO_EMPLEADO();
CALL LOAD_PAIS();
CALL LOAD_CIUDAD();
CALL LOAD_DIRECCION();
CALL LOAD_TIENDA();
CALL LOAD_CLIENTE();
CALL LOAD_CUENTA();
CALL LOAD_EMPLEADO();
CALL LOAD_CATEGORIA();
CALL LOAD_CLASIFICACION();
CALL LOAD_LENGUAJE();
CALL LOAD_ACTOR();
CALL LOAD_PELICULA();
CALL LOAD_ASG_CATEGORIA();
CALL LOAD_ASG_ACTOR();
CALL LOAD_ASG_PELICULA_TIENDA();
CALL LOAD_RENTA();