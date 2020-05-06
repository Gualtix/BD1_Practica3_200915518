/*1*/
/*****************************************************************************************************
1: Mostrar la cantidad de copias que existen en el inventario para la pelicula
   'SUGAR WONKA'
*/

select 
	tienda.nombre,
	asignacion_pelicula_tienda.stock,
	pelicula.titulo 
from 
	asignacion_pelicula_tienda,
	pelicula,
	tienda
where 
	asignacion_pelicula_tienda.fk_pelicula = pelicula.id
	and 
	asignacion_pelicula_tienda.fk_tienda = tienda.id 
	and
	pelicula.titulo = 'SUGAR WONKA';





/*2*/
/*****************************************************************************************************
2: Mostrar el nombre, apellido y pago total de todos los clientes que han
   rentado peliculas por lo menos 40 veces
*/

SELECT CLIENTE.nombre,CLIENTE.apellido,TOT,NRENT FROM 
(
    SELECT RENTA.fk_cliente AS CLIENT ,COUNT(*) AS NRENT,SUM(RENTA.monto_pagar) AS TOT 
    FROM RENTA 
    GROUP BY RENTA.fk_cliente
    HAVING COUNT(*) >= 40
) AS RSTABLE,CLIENTE
WHERE CLIENTE.id = CLIENT;


/*3*/
/****************************************************************************************************
3: "Mostrar el nombre y apellido del actor que mas veces a aparecido en una pelicula. Debe mostrar la 
    cantidad de veces que aparecio. Si esa cantidad coincide tambien para otros actores, 
    debe mostrarlos todos".
*/

select actor.nombre,actor.apellido,pelicula.titulo,nump
from
(
	select distinct on (acto) acto,pelicula.id as peli,nump
	from 
		(
			select 
				actor.id           as acto,
				count(actor.id )   as nump
			from 
				actor,
				asignacion_actor,
				pelicula
			where
				actor.id = asignacion_actor.fk_actor
				and 
				pelicula.id =  asignacion_actor.fk_pelicula
			group by actor.id 
		) as t,
		pelicula,
		asignacion_actor
	where
	acto = asignacion_actor.fk_actor
	and 
	pelicula.id =  asignacion_actor.fk_pelicula
) as rest,
actor,
pelicula
where
actor.id = acto 
and 
pelicula.id = peli
order by nump desc;



/*4*/
/****************************************************************************************************
4: Mostrar el nombre y apellido (en una sola columna) de los actores que contiene la palabra
   'SON' en su apellido, ordenados por su primer nombre
*/

SELECT CONCAT(ACTOR.nombre,' ',ACTOR.apellido) AS ACTOR FROM ACTOR WHERE ACTOR.apellido LIKE '%son%'
ORDER BY ACTOR.nombre; 

/*5*/
/****************************************************************************************************
5: Mostrar el apellido de todos los actores y la cantidad de actores que tienen ese apellido
*/

select distinct on (actor.apellido) actor.apellido from actor 
group by actor.nombre;

select actor.apellido,count(actor.apellido) nveces
from 
	actor
group by actor.apellido;


/*6*/
/****************************************************************************************************
6: Mostrar el nombre y apellido de los actores que participaron en una pelicula que involucra un 
   'cocodrilo' y un 'tiburon' junto con el anio de lanzamiento de la pelicula, ordenados por
   por el apellido del actor de forma ascendente 
*/


SELECT 
    ACTOR.nombre,ACTOR.apellido,
    PELICULA.titulo,PELICULA.descripcion,PELICULA.anio_lanzamiento
FROM ACTOR,PELICULA,ASIGNACION_ACTOR
WHERE
    ACTOR.id = ASIGNACION_ACTOR.fk_actor
    AND
    PELICULA.id = ASIGNACION_ACTOR.fk_pelicula
    AND
    (PELICULA.descripcion LIKE '%Shark%' OR PELICULA.descripcion LIKE '%Crocodile%')
	ORDER BY ACTOR.nombre,ACTOR.apellido ASC;

/*7*/
/****************************************************************************************************
7: Mostrar el nombre de la categoria y el numero de peliclas por categoria de todas las
   categorias de peliculas en las que hay entre 55 y 65 peliculas. Ordenar el resultado
   por numero de peliculas de forma descendente
*/

SELECT CATEGORIA.nombre,NPELIS
FROM
(
	SELECT ASIGNACION_CATEGORIA.fk_categoria AS CAT,COUNT(*) AS NPELIS FROM ASIGNACION_CATEGORIA
	GROUP BY ASIGNACION_CATEGORIA.fk_categoria,ASIGNACION_CATEGORIA.fk_categoria
	HAVING COUNT(*) >= 55 AND COUNT(*) <= 65
	ORDER BY COUNT(*) DESC
) AS PROF,CATEGORIA
WHERE CATEGORIA.id = CAT;




/*8*/
/****************************************************************************************************
8: Mostrar todas las categorias de peliculas en las que la diferencia promedio entre el costo
   de reemplazo de la pelicula y el precio de alquiler sea superior a 17;
*/


/*9*/
/*****************************************************************************************************
9: Mostrar el titulo de la pelicula, el nombre y apellido del actor de todas aquellas peliculas en las 
   que uno o mas actores actuaron en dos o mas peliculas.
*/


/*10*/
/****************************************************************************************************
10: Mostrar el nombre y apellido (en una sola columna) de todos los actores y clientes cuyo primer
    nombre sea el mismo que el primer nombre del actor: MATTHEW JOHANSSON, id = 127
*/

SELECT ACTOR.nombre,ACTOR.apellido 
FROM ACTOR 
WHERE Actor.nombre IN 
(
   SELECT nombre FROM ACTOR WHERE ACTOR.nombre = 'Matthew' AND ACTOR.apellido = 'Johansson'
)

UNION

SELECT CLIENTE.nombre,CLIENTE.apellido 
FROM CLIENTE 
WHERE CLIENTE.nombre IN 
(
   SELECT nombre FROM ACTOR WHERE ACTOR.nombre = 'Matthew' AND ACTOR.apellido = 'Johansson'
);

/*11*/
/****************************************************************************************************
11: Mostrar el pais y el nombre del cliente que mas peliculas rento asi como
	tambien el porcentaje que representa la cantidad de peliculas que rento con
	respecto al resto de clientes del pais
*/

select 
	cliname,
	cliap,
	cli_pais_name,
	n_rent_cliente,
	(	
		( 
			(
				n_rent_cliente
				/
				(
					select 
						count(pais.id)
					from 
						renta
						inner join cliente   on (renta    .fk_cliente   = cliente.id)
						inner join direccion on (cliente  .fk_direccion = direccion.id)
						inner join ciudad    on (direccion.fk_ciudad    = ciudad.id)
						inner join pais      on (ciudad   .fk_pais      = pais.id)
					where pais.nombre = cli_pais_name
				)::float
			)
		)*100
	) as porsenaje
from 
(

	select 
		cliente.id        as clid,
		cliente.nombre    as cliname,
		cliente.apellido  as cliap,
		pais.id           as cli_pais_id,
		pais.nombre       as cli_pais_name,
		count(cliente.id) as n_rent_cliente
	from 
		renta
		inner join cliente   on (renta    .fk_cliente   = cliente.id)
		inner join direccion on (cliente  .fk_direccion = direccion.id)
		inner join ciudad    on (direccion.fk_ciudad    = ciudad.id)
		inner join pais      on (ciudad   .fk_pais      = pais.id)
	group by 
		cliente.id,
		cliente.nombre,
		cliente.apellido,
		pais.id,
		pais.nombre
	order by count(cliente.id) desc limit 1
) as jar


/*12*/
/****************************************************************************************************
12: Mostrar el total de clientes y porcentaje de clientes por ciudad y
	pais. El ciento por ciento es el total de clientes por pais. (Tip: Todos los
	porcentajes por ciudad de un pais deben sumar el 100%)
*/


select
	paisnm,
	ciudadnm,
	nclientes,
	(
		(
			(nclientes)
			/
			(
				select
				count(*) 
				from 
				cliente
				inner join direccion on (cliente.fk_direccion = direccion.id) 
				inner join ciudad    on (direccion.fk_ciudad  = ciudad.id)
				inner join pais      on (ciudad.fk_pais       = pais.id)
				where pais.nombre = paisnm
			
			)::float
		)*100
	)as porcentaje
	
from 
(
	select
	    distinct on(ciudad.nombre)
	    pais.nombre as paisnm,
		ciudad.nombre as ciudadnm,
		nclientes
	from
	(
		select
		ciudad.id        as idcity,
		count(ciudad.id) as nclientes
		from cliente
		inner join direccion on (cliente.fk_direccion = direccion.id)
		inner join ciudad    on (direccion.fk_ciudad  = ciudad.id)
		inner join pais      on (ciudad.fk_pais       = pais.id)
		group by ciudad.id
	)as jar,
	ciudad,
	pais,
	direccion 
	where 
	ciudad.id = jar.idcity
	and 
	ciudad.fk_pais = pais.id 
	and 
	direccion.fk_ciudad = ciudad.id
)as jam



/*13*/
/****************************************************************************************************
13: Mostrar el nombre del pais, nombre del cliente y numero de peliculas
	rentadas de todos los clientes que rentaron mas paliculas por pais. Si el
	numero de peliculas maximo se repite, mostrar todos los valores que
	representa el maximo.
*/

select 

	pais.nombre      as nombre_pais,
	cliente.nombre   as cliente_nombre,
	cliente.apellido as cliente_apellido,
	maxnrent          as top_nrent

from 
(
	select 
	pid,
	(
		select
			xclid
		from
		(
			select	
				pais.id    as xpid,
				cliente.id as xclid,
				count(*)   as xnrent
			from
			renta
			inner join pelicula  on(renta.fk_pelicula = pelicula.id)
			inner join cliente   on(renta.fk_cliente = cliente.id)
			inner join direccion on(cliente.fk_direccion = direccion.id)
			inner join ciudad    on(direccion.fk_ciudad = ciudad.id)
			inner join pais      on(ciudad.fk_pais = pais.id)
			group by pais.id,cliente.id
			having pais.id =pid and count(*) = maxnrent
		)as net
		limit 1
	) as clide,
	maxnrent
	from 
	(
		select 
			pid,
			max(nrent) as maxnrent
		from
		(
			select	
				pais.id    as pid,
				cliente.id as clid,
				count(*)   as nrent
			from
			renta
			inner join pelicula  on(renta.fk_pelicula = pelicula.id)
			inner join cliente   on(renta.fk_cliente = cliente.id)
			inner join direccion on(cliente.fk_direccion = direccion.id)
			inner join ciudad    on(direccion.fk_ciudad = ciudad.id)
			inner join pais      on(ciudad.fk_pais = pais.id)
			group by pais.id,cliente.id
			order by pais.id,cliente.id
		)as jar
		group by pid
	)as jam
)as nao
inner join pais    on (pais.id = pid)
inner join cliente on (cliente.id = clide)


/*14*/
/****************************************************************************************************
14: Mostrar todas las ciudades por pais en las que predomina la renta de
	paliculas de la categor�a 'Horror'. Es decir, hay mas rentas que las otras
	categorias.
	
*/
select 
	(
		select 
		pais.nombre 
		from
		ciudad 
		inner join pais on(ciudad.nombre = city and ciudad.fk_pais = pais.id)
		limit 1
	)as country,
	city,
	cat,
	max(ncat) as nrent
	from
	(
		select
		
			ciudad.nombre    as city,
			categoria.nombre as cat,
			count(*)         as ncat
		from
			renta
		inner join pelicula              on(renta.fk_pelicula = pelicula.id)
		inner join asignacion_categoria  on (asignacion_categoria.fk_pelicula = renta.fk_pelicula)
		inner join categoria             on (asignacion_categoria.fk_categoria = categoria.id)
		inner join cliente               on(renta.fk_cliente = cliente.id)
		inner join direccion             on(cliente.fk_direccion = direccion.id)
		inner join ciudad                on(direccion.fk_ciudad = ciudad.id)
		group by ciudad.nombre,categoria.nombre 
		order by ciudad.nombre,count(*),categoria.nombre desc
	)as jam
group by city,cat
having cat = 'Horror'



/*15*/
/****************************************************************************************************
15: Mostrar el nombre del pais, la ciudad y el promedio de rentas por ciudad.
	Por ejemplo: si el pais tiene 3 ciudades, se deben sumar todas las rentas de
	la ciudad y dividirlo dentro de tres (numero de ciudades del pais).
*/


select
	country,
	city,
	(
		(
			(ncat)
			/
			(
				select
				count(*)
				from 
				ciudad
				inner join pais on(ciudad.fk_pais = pais.id)
				group by pais.nombre 
				having pais.nombre = country
			)::float
		)
	) as promedio
from
(
	select
		pais.nombre      as country,
		ciudad.nombre    as city,
		count(*)         as ncat
	from
		renta
	inner join pelicula              on(renta.fk_pelicula = pelicula.id)
	inner join cliente               on(renta.fk_cliente = cliente.id)
	inner join direccion             on(cliente.fk_direccion = direccion.id)
	inner join ciudad                on(direccion.fk_ciudad = ciudad.id)
	inner join pais                  on(ciudad.fk_pais = pais.id)
	group by pais.nombre,ciudad.nombre
)as jar





/*16*/
/****************************************************************************************************
16: Mostrar el nombre del pais y el porcentaje de rentas de paliculas de la
	categor�a 'Sports'.
*/

select 
	country,
	(
		(
			(
				sum(ncat)
			)
			/
			(
				select 
				count(*)
				from 
				renta
				inner join cliente               on(renta.fk_cliente = cliente.id)
				inner join direccion             on(cliente.fk_direccion = direccion.id)
				inner join ciudad                on(direccion.fk_ciudad = ciudad.id)
				inner join pais                  on(ciudad.fk_pais = pais.id)
				group by pais.nombre 
				having pais.nombre = country
			)::float
		)*100
		
	)porcentaje
from
(
	select
		pais.nombre      as country,
		ciudad.nombre    as city,
		categoria.nombre as cat,
		count(*)         as ncat
	from
		renta
	inner join pelicula              on(renta.fk_pelicula = pelicula.id)
	inner join asignacion_categoria  on (asignacion_categoria.fk_pelicula = renta.fk_pelicula)
	inner join categoria             on (asignacion_categoria.fk_categoria = categoria.id)
	inner join cliente               on(renta.fk_cliente = cliente.id)
	inner join direccion             on(cliente.fk_direccion = direccion.id)
	inner join ciudad                on(direccion.fk_ciudad = ciudad.id)
	inner join pais                  on(ciudad.fk_pais = pais.id)
	group by pais.nombre,ciudad.nombre,categoria.nombre 
	having categoria.nombre = 'Sports'
)as jar
group by country 



/*17*/
/****************************************************************************************************
17: Mostrar la lista de ciudades de Estados Unidos y el numero de rentas de
	peliculas para las ciudades que obtuvieron m�s rentas que la ciudad
	'Dayton'.
*/


select
	pais.nombre      as country,
	ciudad.nombre    as city,
	count(*)         as ncpelis
from
	renta
inner join cliente               on(renta.fk_cliente = cliente.id)
inner join direccion             on(cliente.fk_direccion = direccion.id)
inner join ciudad                on(direccion.fk_ciudad = ciudad.id)
inner join pais                  on(ciudad.fk_pais = pais.id)
group by pais.nombre,ciudad.nombre
having pais.nombre = 'United States' 
and 
count(*) > 
(
	select 
	count(*)
	from 
	renta
	inner join cliente               on(renta.fk_cliente     = cliente.id)
	inner join direccion             on(cliente.fk_direccion = direccion.id)
	inner join ciudad                on(direccion.fk_ciudad  = ciudad.id)
	inner join pais                  on(ciudad.fk_pais       = pais.id)
	group by ciudad.nombre 
	having ciudad.nombre = 'Dayton'
)


/*18*/
/****************************************************************************************************
18: Mostrar el nombre, apellido y fecha de retorno de pel�cula a la tienda de
	todos los clientes que hayan rentado m�s de 2 peliculas que se encuentren
	en lenguaje Ingles en donde el empleado que se las vendio ganara m�s de 15
	dolares en sus rentas del dia en la que el cliente rento la pel�cula
*/



/*19*/
/****************************************************************************************************
19: Mostrar el numero de mes, de la fecha de renta de la pelicula, nombre y
	apellido de los clientes que mas paliculas han rentado y las que menos en
	una sola consulta
*/



/*20*/
/****************************************************************************************************
20: Mostrar el porcentaje de lenguajes de peliculas mas rentadas de cada ciudad
	durante el mes de julio del anio 2005 de la siguiente manera: ciudad,
	lenguaje, porcentaje de renta
*/








































CREATE OR REPLACE PROCEDURE HTR() AS $$
DECLARE 

	dif INTEGER  := 0;
	id_actor INTEGER  := 0;

	GENIS CURSOR FOR
	select 
	renta.monto_pagar,
	pelicula.titulo,
	pelicula.costo_renta
	from 
	renta
	inner join pelicula on (renta.fk_pelicula = pelicula.id)
	limit 10;

BEGIN
	FOR GN IN GENIS LOOP
	BEGIN
		
		dif := GN.monto_pagar - GN.costo_renta;
		raise notice '% % % %', 'Pelicula: '||GN.titulo,'Monto: '||gn.monto_pagar,'Costo: '||GN.costo_renta,'Resta: '||dif;
	END;

    END LOOP;
  END;
$$ LANGUAGE plpgsql;

CALL HTR();

















































/***************************************************************************************************************/


/*No de Rentas por Pais *****************************************************/
select 
count(*)
from 
renta
inner join cliente               on(renta.fk_cliente     = cliente.id)
inner join direccion             on(cliente.fk_direccion = direccion.id)
inner join ciudad                on(direccion.fk_ciudad  = ciudad.id)
inner join pais                  on(ciudad.fk_pais       = pais.id)
group by pais.nombre 
having pais.nombre = 'Afghanistan'
/****************************************************************************/



/*No de Rentas por Ciudad ***************************************************/
select 
count(*)
from 
renta
inner join cliente               on(renta.fk_cliente     = cliente.id)
inner join direccion             on(cliente.fk_direccion = direccion.id)
inner join ciudad                on(direccion.fk_ciudad  = ciudad.id)
inner join pais                  on(ciudad.fk_pais       = pais.id)
group by ciudad.nombre 
having ciudad.nombre = 'Avellaneda'
/****************************************************************************/




/*No de Ciudades por Pais ***************************************************/
select 
count(*)
from 
ciudad
inner join pais on(ciudad.fk_pais = pais.id)
group by pais.nombre 
having pais.nombre = 'Afghanistan'
/***************************************************************************/


/*Lista de Ciudades segun Pais *********************************************/
select 
ciudad.nombre
from 
ciudad
inner join pais on(ciudad.fk_pais = pais.id)
where pais.nombre = 'Argentina'
/***************************************************************************/
