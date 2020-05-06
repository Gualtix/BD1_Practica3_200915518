/* Script DDL: Borrado y Creado de la Base de Datos Propuesta */
/*****************************************************************************************/
CREATE TABLE TIPO_EMPLEADO(
	id   INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	tipo VARCHAR(300) UNIQUE NOT NULL
);
/*****************************************************************************************/
CREATE TABLE PAIS(
	id     INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre VARCHAR(300) UNIQUE NOT NULL
);
/*****************************************************************************************/
CREATE TABLE CIUDAD(
	id            INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre        VARCHAR(300) NOT NULL,
	codigo_postal INT          NULL,
	fk_pais       INT          NOT NULL,
	UNIQUE (nombre,fk_pais)
);

ALTER TABLE CIUDAD ADD CONSTRAINT CIUDAD_PAIS FOREIGN KEY (fk_pais) REFERENCES PAIS(id);
/*****************************************************************************************/
CREATE TABLE DIRECCION(
	id          INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	descripcion VARCHAR(300) NOT NULL,
	fk_ciudad   INT          NOT NULL
);

ALTER TABLE DIRECCION ADD CONSTRAINT DIR_CIUDAD FOREIGN KEY (fk_ciudad) REFERENCES CIUDAD(id);
/*****************************************************************************************/
CREATE TABLE TIENDA(
	id           INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre       VARCHAR(300) NOT NULL,
	fk_direccion int NOT NULL
);

ALTER TABLE TIENDA ADD CONSTRAINT TIEND_DIR FOREIGN KEY (fk_direccion) REFERENCES DIRECCION(id);
/*****************************************************************************************/
CREATE TABLE CUENTA(
	id     INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	usr    VARCHAR(300) NOT NULL,
	passwo VARCHAR(300) NOT NULL
);
/*****************************************************************************************/
CREATE TABLE EMPLEADO(
	id             INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre         VARCHAR(300) NOT NULL,
	apellido       VARCHAR(300) NOT NULL,
	email          VARCHAR(300) NOT NULL,
	estado         VARCHAR(300) NOT NULL,
	fk_tienda      INT          NOT NULL,
	fk_direccion   INT          NOT NULL,
	fk_cuenta 	   INT          NOT NULL,
	fk_tipo        INT          NOT NULL
);


ALTER TABLE EMPLEADO ADD CONSTRAINT EMP_TIENDA FOREIGN KEY (fk_tienda)    REFERENCES TIENDA(id);
ALTER TABLE EMPLEADO ADD CONSTRAINT EMP_DIR    FOREIGN KEY (fk_direccion) REFERENCES DIRECCION(id);
ALTER TABLE EMPLEADO ADD CONSTRAINT EMP_CUENTA FOREIGN KEY (fk_cuenta)    REFERENCES CUENTA(id);
ALTER TABLE EMPLEADO ADD CONSTRAINT EMP_TIPO   FOREIGN KEY (fk_cuenta)    REFERENCES TIPO_EMPLEADO(id);
/*****************************************************************************************/	
CREATE TABLE CLIENTE(
	id                  INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre              VARCHAR(300) NOT NULL,
	apellido            VARCHAR(300) NOT NULL,
	email               VARCHAR(300) NOT NULL,
	estado              VARCHAR(300) NOT NULL,
	fecha_registro      DATE         NOT NULL,
	fk_tienda_preferida INT          NOT NULL,
	fk_direccion 		INT          NOT NULL
);

ALTER TABLE CLIENTE ADD CONSTRAINT CLIENTE_TIENDA FOREIGN KEY (fk_tienda_preferida) REFERENCES TIENDA    (id);
ALTER TABLE CLIENTE ADD CONSTRAINT CLIENTE_DIR    FOREIGN KEY (fk_direccion)        REFERENCES DIRECCION (id);

/*****************************************************************************************/
CREATE TABLE CATEGORIA(
	id     INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre VARCHAR(300) NOT NULL
);
/*****************************************************************************************/
/*****************************************************************************************/
CREATE TABLE ACTOR(
	id       INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre   VARCHAR(300) NOT NULL,
	apellido VARCHAR(300) NOT NULL
);

/*****************************************************************************************/
CREATE TABLE CLASIFICACION(
	id     INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre VARCHAR(300) NOT NULL
);

/*****************************************************************************************/	
CREATE TABLE IDIOMA(
	id     INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nombre VARCHAR(300) NOT NULL UNIQUE
);

/*****************************************************************************************/
CREATE TABLE PELICULA(
	id               INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	titulo           VARCHAR(300) NOT NULL,
	descripcion      VARCHAR(300) NOT NULL,
	anio_lanzamiento INT NOT NULL,
	costo_renta      NUMERIC(6, 2) NOT NULL,
	duracion_min     INT NOT NULL,
	max_dias_renta   INT NOT NULL,
	costo_danio      NUMERIC(6, 2) NOT NULL,
	fk_idioma        INT NOT NULL,
	fk_clasificacion INT NOT NULL
);

ALTER TABLE PELICULA ADD CONSTRAINT PELI_IDIOMA FOREIGN KEY (fk_idioma)        REFERENCES IDIOMA       (id);
ALTER TABLE PELICULA ADD CONSTRAINT PELI_CLASIF FOREIGN KEY (fk_clasificacion) REFERENCES CLASIFICACION(id);
/*****************************************************************************************/

CREATE TABLE ASIGNACION_PELICULA_TIENDA(
	id          INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	fk_tienda   INT NOT NULL,
	fk_pelicula INT NOT NULL,
	stock       INT NOT NULL
);

ALTER TABLE ASIGNACION_PELICULA_TIENDA ADD CONSTRAINT ASGPT_TIENDA   FOREIGN KEY (fk_tienda)   REFERENCES TIENDA(id);
ALTER TABLE ASIGNACION_PELICULA_TIENDA ADD CONSTRAINT ASGPT_PELICULA FOREIGN KEY (fk_pelicula) REFERENCES PELICULA(id);
/*****************************************************************************************/
CREATE TABLE ASIGNACION_CATEGORIA(
	id           INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	fk_pelicula  INT NOT NULL,
	fk_categoria INT NOT NULL
);

ALTER TABLE ASIGNACION_CATEGORIA ADD CONSTRAINT ASC_PELICULA  FOREIGN KEY (fk_pelicula)  REFERENCES PELICULA(id);
ALTER TABLE ASIGNACION_CATEGORIA ADD CONSTRAINT ASC_CATEGORIA FOREIGN KEY (fk_categoria) REFERENCES CATEGORIA(id);
/*****************************************************************************************/
CREATE TABLE ASIGNACION_ACTOR(
	id          INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	fk_actor    INT NOT NULL,  
	fk_pelicula INT NOT NULL
);

ALTER TABLE ASIGNACION_ACTOR ADD CONSTRAINT ASA_ACTOR    FOREIGN KEY (fk_actor)    REFERENCES ACTOR(id);
ALTER TABLE ASIGNACION_ACTOR ADD CONSTRAINT ASC_PELICULA FOREIGN KEY (fk_pelicula) REFERENCES PELICULA(id);

/*****************************************************************************************/
CREATE TABLE RENTA(
	id            INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	monto_pagar   NUMERIC(6, 2) NOT NULL,
	fecha_renta   TIMESTAMP NOT NULL,
	fecha_retorno TIMESTAMP NOT NULL,
	fk_cliente    INT NOT NULL,
	fk_empleado   INT NOT NULL,
	fk_pelicula   INT NOT NULL,
	fk_tienda     INT NOT NULL
);

ALTER TABLE RENTA ADD CONSTRAINT RENTA_CLIENTE  FOREIGN KEY (fk_cliente)  REFERENCES CLIENTE(id);
ALTER TABLE RENTA ADD CONSTRAINT RENTA_EMPLEADO FOREIGN KEY (fk_empleado) REFERENCES EMPLEADO(id);
ALTER TABLE RENTA ADD CONSTRAINT RENTA_PELICULA FOREIGN KEY (fk_pelicula) REFERENCES PELICULA(id);
ALTER TABLE RENTA ADD CONSTRAINT RENTA_TIENDA   FOREIGN KEY (fk_tienda)   REFERENCES TIENDA(id);
/*****************************************************************************************/


/* D R O P */

DROP TABLE RENTA;
DROP TABLE ASIGNACION_ACTOR;
DROP TABLE ASIGNACION_CATEGORIA;
DROP TABLE ASIGNACION_PELICULA_TIENDA;
DROP TABLE PELICULA;
DROP TABLE IDIOMA;
DROP TABLE CLASIFICACION;
DROP TABLE ACTOR;
DROP TABLE CATEGORIA;
DROP TABLE CLIENTE;
DROP TABLE EMPLEADO;
DROP TABLE CUENTA;
DROP TABLE TIENDA;
DROP TABLE DIRECCION;
DROP TABLE CIUDAD;
DROP TABLE PAIS;
DROP TABLE TIPO_EMPLEADO;



