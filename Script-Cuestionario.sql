--Inicio del desarrollo de la base de datos 
--06/12/2023

--crear la tabla usuarios
--crear la extension para el Universal Unique Identifier
create extension if not exists "uuid-ossp";
--para encriptar datos 
CREATE EXTENSION pgcrypto;
--para verificar si se esta ejecutando el Universal Unique Identifier 
select uuid_generate_v1() as xd;


--crear tabla Usuario 
create table usuario(
	ID_User uuid default uuid_generate_V4(),
	Nombres_apellidos varchar(300) not null ,
	Tipo_identificacion varchar(50) not null,
	Identificacion Varchar(15) not null,
	Correo_Institucional varchar(100) not null,
	Numero_celular varchar(15) not null,
	Estado bool Default true not null,
	URL_Foto varchar(500) not null,
	IsAdmin bool Default false not null,
	Contra varchar(500) not null,
		Primary Key(ID_User)
);

select * from usuario;

--09-12-2023
--establecer restricciones en la tabla usuario 
alter table usuario
  add constraint UQ_Name
  unique (nombres_apellidos);
 
alter table usuario
  add constraint UQ_Correo_Institucional
  unique (correo_institucional);

alter table usuario
  add constraint UQ_Numero_Celular
  unique (numero_celular);

alter table usuario
  add constraint UQ_Identificacion
  unique (identificacion);
 

--eleiminar la columna URL Foto porque no se va usar de momento 
 ALTER TABLE usuario
DROP COLUMN url_foto;




--consulta para ver las columnas de una tabla 
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'usuario' order by column_name asc;
---

--Procedimiento almacenado para crear usuarios de la APP (no admin, es decir no SUPER_USUARIOS)
CREATE OR REPLACE PROCEDURE public.crear_usuario(
		IN p_contrasena character varying,
		IN p_correo_institucional character varying,
		IN p_identificacion character varying,
		IN p_nombres_apellidos character varying,
		IN p_celular character varying,
		IN p_tipo_identificacion character varying
		)
LANGUAGE plpgsql
AS $procedure$

Begin
	insert into usuario(
						contra,
						correo_institucional,
						identificacion,
						nombres_apellidos,
						numero_celular,
						tipo_identificacion
						)values
						(
						 PGP_SYM_ENCRYPT(p_contrasena::text,'SGDV_KEY'),
						 p_correo_institucional,
						 p_identificacion,
						 p_nombres_apellidos,
						 p_celular,
						 p_tipo_identificacion
						);

COMMIT;
END;
$procedure$
;

--crear el super_usuario y luego editarle el campo 'isadmin' = true xd 
call crear_usuario('123456','rcoelloc2@uteq.edu.ec','1234567890','Raul C','0980844846','Cedula');

select * from usuario u ;

--modificar al usuario para que sea superusuario
update usuario set isadmin = true where usuario.correo_institucional = 'rcoelloc2@uteq.edu.ec'


--crear procedimineto almacenado para iniciar sesion con cuenta local de la base de datos
CREATE OR REPLACE FUNCTION public.verification_auth(email character varying, contra1 character varying)
 RETURNS TABLE(verification integer, mensaje character varying)
 LANGUAGE plpgsql
AS $function$
declare
	User_Deshabili bool;
	User_Exit bool;
begin
	--Primero Verificar si el correo que se esta ingresando existe
	select into User_Exit case when COUNT(*)>=1 then True else false end  from usuario where correo_institucional=email;	
	--Segundo  Verificar si el usuario tiene un estado habilitado o deshabilitado
	if (User_Exit) then 
		select into User_Deshabili estado from usuario where correo_institucional=email;
		if (User_Deshabili) then 
			return query
			select
			cast(case when COUNT(*)>=1 then 1 else 2 end as int),
			 cast(case when COUNT(*)>=1 then 'Login Correcto' else 'Contraseña incorrecta' end as varchar(500))
			from usuario
			where correo_institucional  = email 
			and  PGP_SYM_DECRYPT(contra ::bytea, 'SGDV_KEY') = contra1
   			and estado=true;
   		else 
   			return query
			select cast(3 as int), cast('Usuario deshabilitado contacte con un administrador' as varchar(500));
		end if;
	else 
	   		return query
			select cast(4 as int), cast('Este correo no esta registrado' as varchar(500));
	end if;
end;
$function$
;

select * from verification_auth('rcoelloc2@uteq.edu.ec','')

--Funcion para retornar los datos del inicio de sesion como los nombres, etc 
CREATE OR REPLACE FUNCTION public.auth_data(email character varying)
 RETURNS TABLE(userd character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(ID_User as varchar(500)) as UserT  from usuario where correo_institucional  = email;
end;
$function$
;

select * from auth_data('','')


create table prueba2(Nombres_apellidos varchar(300) not null );


select * from Auth_Data('rcoelloc2@uteq.edu.ec');


select * from Test;


select PGP_SYM_DECRYPT(contra ::bytea, 'SGDV_KEY') from usuario u;
call editar_usuario_not_admin




--funcion para ver los datos de un usuario segun el id 
--y el nombre con un subtring 
select 
		LEFT(nombres_apellidos, 3) || '...' AS user_name_ab,
		nombres_apellidos , tipo_identificacion , identificacion , 
		correo_institucional ,numero_celular, isadmin  
from usuario u 
	where cast(u.id_user as varchar(800)) = '3b43792d-ec18-49a5-b8af-753c65cb9b21' 

--select * from usuario u 
	
select * from FU_usuario_data('3b43792d-ec18-49a5-b8af-753c65cb9b21' )
--crear la funcion que retorne la info de un usuario xd 
create or replace function FU_usuario_data(p_idu varchar(500))
returns table
(
	r_user_name_ab varchar(500), r_nombres_apellidos varchar(500), r_tipo_identificacion varchar(500), 
	r_identificacion varchar(500), r_correo_institucional varchar(500), r_numero_celular varchar(500),
	r_isadmin bool
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select 
		cast(LEFT(nombres_apellidos, 10) || '...' as varchar(500) )AS user_name_ab,
		nombres_apellidos , tipo_identificacion , identificacion , 
		correo_institucional ,numero_celular, isadmin  
	from usuario u 
	where cast(u.id_user as varchar(800)) = p_idu;
end;
$BODY$	

	
	
	
alter table secciones
  add constraint UQ_Titulo
  unique (titulo);
 
 
select * from secciones s ;
select * from secciones_usuario;
--Crear un procedimiento para crear seccion segun el usuaio
--SP_Crear_Seccion

select * from usuario u ;
--3b43792d-ec18-49a5-b8af-753c65cb9b21
call SP_Crear_Seccion('Matematicas','Seccion de matematicas','3b43792d-ec18-49a5-b8af-753c65cb9b21');
Create or Replace Procedure SP_Crear_Seccion(
										p_titulo varchar(500),
										p_descripcion varchar(500),
										p_id_usuario_crea varchar(800)
										  )
Language 'plpgsql'
AS $$
declare
	p_id_seccion_creada int;
begin
	--crear la seccion
	insert into secciones(titulo,descripcion) values (p_titulo,p_descripcion);
	--bucar el id de la seccion creada para insertarla en la tabla transaccional
	select into p_id_seccion_creada id_seccion from secciones order by id_seccion desc limit 1;
	--insertar en la transaccional 
	insert into secciones_usuario(id_seccion, id_usuario, Admin_Seccion) values (p_id_seccion_creada,cast(p_id_usuario_crea as UUID),true);
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

select * from Now()
--crear la tabla transaccional 
CREATE TABLE secciones_usuario (
    ID_Seccion INT,
    ID_Usuario UUID,
    Fecha_Creacion TIMESTAMPTZ DEFAULT Now(),
    Admin_Seccion BOOLEAN DEFAULT false not null,
    PRIMARY KEY (ID_Seccion, ID_Usuario)
);

alter table secciones_usuario 
add constraint FK_ID_Seccion 
FOREIGN KEY (ID_Seccion) 
references secciones(id_seccion);


alter table secciones_usuario 
add constraint FK_ID_Usuario 
FOREIGN KEY (ID_Usuario) 
references usuario(ID_User);



--crear funcion que retorne todas las secciones en las que participe un usuario 
select s.id_seccion ,s.titulo ,s.descripcion, su.admin_seccion  from secciones s  
inner join secciones_usuario su on s.id_seccion = su.id_seccion  where cast(su.id_usuario as varchar(800)) = '3b43792d-ec18-49a5-b8af-753c65cb9b21' 
--3b43792d-ec18-49a5-b8af-753c65cb9b21

--Creacion de la funcion
create or replace function FU_Secciones_usuario(p_idu varchar(500))
returns table
(
	r_id_seccion int, r_titulo varchar(500), r_descripcion varchar(500), 
	r_admin_seccion bool
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select s.id_seccion ,s.titulo ,s.descripcion, su.admin_seccion  from secciones s  
	inner join secciones_usuario su on s.id_seccion = su.id_seccion  
	where cast(su.id_usuario as varchar(800)) = p_idu;
end;
$BODY$

select * from FU_Secciones_usuario('3b43792d-ec18-49a5-b8af-753c65cb9b21');


select * from secciones_usuario;
delete  from secciones_usuario where id_seccion = 28;


delete from secciones where id_seccion = 28;




select * from niveles n ;

delete from niveles where id_nivel = 3 

declare nivel int;

select into nivel COUNT(*) + 1 as Nivel from  niveles n    -- where new.id_seccion

int _nivel 

select    COUNT(*) +1   as Nivel  from  niveles where new.id_seccion

new.nivel = _nivel 


-- funcion para ver los niveles por seccion y su numero de preguntas 
select * from niveles n;
select * from preguntas p ;

select id_nivel , id_seccion , nivel  from niveles n;
select id_nivel  from preguntas p;


select * from 

SELECT
    n.id_nivel,
    n.id_seccion,
    n.nivel,
    COUNT(p.id_nivel) AS total_preguntas
FROM
    niveles n
LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
WHERE
    n.id_seccion = 1
GROUP BY
    n.id_nivel, n.id_seccion, n.nivel
ORDER BY
    n.id_nivel;
   
   --4
   select * from secciones s ;
 select * from preguntas p ;

insert into preguntas (id_nivel, tiempos_segundos, enunciado) values (4,15,'Seleccion el perro');


--crear la funcion que retorne la lista de niveles con sus numero de preguntas segun la seccion
   

select * from FU_Niveles_Preguntas('1');

   create or replace function FU_Niveles_Preguntas(p_id_seccion varchar(50))
returns table
(
	r_id_nivel int, r_id_seccion int, r_nivel varchar(500), r_total_preguntas int
)
language 'plpgsql'
as
$BODY$
begin
	return query
	SELECT
    n.id_nivel,
    n.id_seccion,
    cast(CONCAT('Nivel ', CAST(n.nivel AS VARCHAR)) as varchar(100)) AS nivel,
    cast(COUNT(p.id_nivel)as int) AS total_preguntas
	FROM
    niveles n
	LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
	WHERE
    n.id_seccion = cast(p_id_seccion as int)
	GROUP BY
    n.id_nivel, n.id_seccion, n.nivel
	ORDER BY
    n.id_nivel;
end;
$BODY$


select * from secciones s ;
SELECT
    n.id_nivel,
    n.id_seccion,
    cast(CONCAT('Nivel ', CAST(n.nivel AS VARCHAR)) as varchar(100)) AS nivel,
    cast(COUNT(p.id_nivel)as int) AS total_preguntas
	FROM
    niveles n
	LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
	WHERE
    n.id_seccion = 27
	GROUP BY
    n.id_nivel, n.id_seccion, n.nivel
	ORDER BY
    n.id_nivel;
call sp_insertar_niveles();

--procedure para crear un nivel segun el id de una seccion 
select * from niveles n ;

call sp_insertar_niveles()

--funcion para listar las pregunta de un nivel 
select * from preguntas p ;

select * from tipos_preguntas tp ;
select * from preguntas;

select * from FU_preguntas_nivel1('7');
drop function FU_preguntas_nivel1;
create or replace function FU_preguntas_nivel1(p_id_nivel varchar(50))
returns table
(
	r_enunciado varchar(900), r_fecha varchar(900), r_tiempo_segundos int, r_estado bool, r_id_pregunta varchar(10), r_ID_p int,
	r_error bool, r_error_detalle varchar(50)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select cast(LEFT(p.enunciado, 80) || '...' as varchar(900) ) as enunciad, cast(to_char(p.fecha_creacion,'DD-MON-YYYY')as varchar(500)) as fecha_crea,
	p.tiempos_segundos, p.estado, tp.codigo, p.id_pregunta, p.error, p.error_detalle
	from preguntas p 
	inner join  tipos_preguntas tp on p.tipo_pregunta= tp.id_tipo_pregunta
	where p.id_nivel = cast(p_id_nivel as int) order by p.fecha_creacion asc;
end;
$BODY$


select * from preguntas p;

select * from preguntas p ;



create table tipos_preguntas(
	id_tipo_pregunta INT GENERATED ALWAYS AS IDENTITY,
	titulo varchar(200) not null unique,
	descripcion varchar(200) not null,
	estado bool not null default true,
	opcion_multiple bool not null default false,
	enunciado_img bool not null default false,
	timepo_enunciado int not null default 0,
	opciones_img bool not null default false,
		primary key (id_tipo_pregunta)
);


--tabla tipo pregunta maestra 
create table tipos_preguntas_maestra(
	id_maestro int GENERATED ALWAYS AS IDENTITY,
	titulo varchar(900) not null,
	estado bool default true,
	primary key (id_maestro)
);
alter table tipos_preguntas 
add column tipo_pregunta_maestra int;

alter table tipos_preguntas 
add constraint FK_id_tipo_pregunta_maestra 
FOREIGN KEY (tipo_pregunta_maestra) 
references tipos_preguntas_maestra(id_maestro);

alter table tipos_preguntas_maestra
  add constraint UQ_titulo_tipo_maestra
  unique (titulo);
 


select * from extra_pregunta ep ;

select * from tipos_preguntas;
select * from preguntas p ;


--crear la tabla de respuestas para las preguntas 
create table respuestas(
	id_respuesta int GENERATED ALWAYS AS IDENTITY,
	id_pregunta int not null,
	opcion varchar (900) not null unique,
	correcta bool not null default false,
	estado bool not null default true,
	eliminado bool not null default false,
		primary key (id_respuesta)
);

--crear la tabla para el extra de la pregunta  
create table extra_pregunta(
	id_extra int GENERATED ALWAYS AS IDENTITY,
	id_pregunta int not null,
	extra varchar(900) not null,
	estado bool default true,
	primary key (id_extra)
);

alter table extra_pregunta 
add column tiempo_enunciado int not null;




--elminiar el contenido de la tabla pregunta para anadir una nueva colimna
--y una neuva restrccion 
delete from preguntas ;

select * from preguntas p ;
 
alter table preguntas 
add column tipo_pregunta int;


--Linkear preguntas con tipo pregunta 
select * from tipos_preguntas

alter table preguntas 
add constraint FK_id_tipo_pregunta 
FOREIGN KEY (tipo_pregunta) 
references tipos_preguntas(id_tipo_pregunta);

--linkear las repuestas a pregunta 
alter table respuestas
add constraint FK_Id_pregunta 
foreign key (id_pregunta)
references preguntas(id_pregunta)

--linkear el extra con la pregunta 
alter table extra_pregunta
add constraint FK_id_extra_pregunta
foreign key (id_pregunta)
references preguntas(id_pregunta)


--anadir una tabal de tipo_pregunta_maestra 
--esta tabla servira para establecer preguntas como opcion multiple 
--opcion unica etc 

--y tipo pregunta tendra lo personlaizado






--registrar el primer tipo de pregunta que seria el de seleccionar imagen 
--con timepo de vista de imagen 
select * from tipos_preguntas;
insert into tipos_preguntas
()


select * from tipos_preguntas_maestra;
insert into tipos_preguntas_maestra (titulo) values ('Opcion Unica')






select * from FU_tipos_preguntas_maestras();
--funcion que retorne los tipos de preguntas maestras que exisiten para esocjer al crear un tipo
create or replace function FU_tipos_preguntas_maestras()
returns table
(
	r_id_maestro int, r_titulo varchar(900)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select p.id_maestro, p.titulo from tipos_preguntas_maestra p where p.estado;
end;
$BODY$


delete from tipos_preguntas;

ALTER TABLE tipos_preguntas
DROP COLUMN timepo_enunciado;


alter table tipos_preguntas 
add column icono varchar(900) not null;
--insertar tipos de preguntas que sea de opcion multiple 
--id 1 
--select * from FU_tipos_preguntas_maestras();
select * from tipos_preguntas ;

--Primer Plantilla
insert into tipos_preguntas (titulo, descripcion, opcion_multiple, enunciado_img, tiempo_enunciado, opciones_img, tipo_pregunta_maestra, icono)
values ('Memorizar con imagenes','El enunciado y las opciones son representadas con imagenes con timepo determinado para memorizar',
		false, true, true, true, 1,'src/');


--Segunda Plantilla
_preguntas (titulo, descripcion, 
		opcion_multiple, enunciado_img, tiempo_enunciado, opciones_img, tipo_pregunta_maestra, icono)
values ('Seleccionar Imagen','Las opciones son representadas con imagenes',
		false, true, false, true, 1,'src/');

update tipos_preguntas set enunciado_img=false where titulo='Seleccionar Imagen';
	
--Tercera Plantilla
insert into tipos_preguntas (titulo, descripcion, 
		opcion_multiple, enunciado_img, tiempo_enunciado, opciones_img, tipo_pregunta_maestra, icono)
values ('Seleccion clasica','Las opciones son representadas con texto',
		false, false, false, false, 1,'src/');
	
	
	
select * from tipos_preguntas;


--funcion que retornes los tipos de preguntas segun el id del maestro 

select * from FU_plantilla_preguntas_id_maestro('1');
--drop function FU_plantilla_preguntas_id_maestro
create or replace function FU_plantilla_preguntas_id_maestro(p_id_maestro varchar(50))
returns table
(
	r_id_tipo_pregunta int, r_titulo varchar(900), r_descripcion varchar(900), r_icono varchar(900),  r_codigo varchar(9)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select p.id_tipo_pregunta, p.titulo, p.descripcion,p.icono,p.codigo from tipos_preguntas p where p.tipo_pregunta_maestra = cast(p_id_maestro as int) and p.estado;
end;
$BODY$

--2 --Memorizar con imagenes 
--4 --SeleccionClasica
--3 --Seleccionar Imagen 
update tipos_preguntas set codigo = 'MEMRZAR' where id_tipo_pregunta=2;
update tipos_preguntas set codigo = 'SELCCLA' where id_tipo_pregunta=4;
update tipos_preguntas set codigo = 'SELCIMG' where id_tipo_pregunta=3;

--'../../uploads/iconos/memorizar.png';
--../../uploads/perfiles/logo_empresa-1690769537460.png
 alter table tipos_preguntas alter column codigo set not null;

select * from tipos_preguntas tp ;
ALTER TABLE tipos_preguntas
DROP COLUMN codigo;
---añadir un campo codigo de tipo de pregunta para poder seleccionar el componente que contiene la plantilla para crear la pregunta
--ya que es complicado crear un componente que abarque todas las posibles preguntas.
alter table tipos_preguntas 
add column codigo varchar(8) unique;


select tp.id_tipo_pregunta, tp.titulo , tp.codigo from tipos_preguntas tp;

--anadir dos campos extras a preguntas
--Error --> bool por defecto va a tener true e indicara que no se podra usar en un test 
--en primera instancia porque no tiene las repuestas registras
--no tiene mas de una respuesta
--no tiene una respuesta correcta si es de opcion unica 
-- solo tiene una respuesa si es de opcion multiple 


alter table preguntas 
add column error bool default true not null;


alter table preguntas 
add column error_detalle varchar(900) not null;


select * from preguntas p ;

select * from tipos_preguntas tp ;
--crear un procedimiento para poder crear una pregunta del tipo MEMRZAR
--esta recibe el enunciado, tiempo para resolver , id tipo de pregunta, y el nivel 
--en la tabla extra tambien va un registro el cual es la url de la imagen del enunciado en extra y el tiempo del enunciado mas el id de la pregunta




select * from preguntas p ;
select * from extra_pregunta ep ;
Create or Replace Procedure SP_Crear_Pregunta_MEMRZAR(
										p_enunciado varchar(800),
										p_tiempos_segundos int,
										p_tipo_pregunta int,
										p_id_nivel int,
										p_url_imagen varchar(800),
										p_tiempo_img int
										  )
Language 'plpgsql'
AS $$
declare
	p_id_pregunta_creada int;
begin
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta');
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,p_tiempo_img);
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;


--funcion que devuelve los datos de la ultima pregunta creada segun el id de un nivel 
--esto servira para anadir las opciones de respuestas
-- para el tipo MEMRZAR
--se necesita: ID_Pregunta,Enunciado, Imagen_EXTRA

select p.id_pregunta, p.enunciado, ep.extra  from preguntas p 
		inner join extra_pregunta ep on p.id_pregunta  =ep.id_pregunta  
		where p.id_nivel =7 order by p.fecha_creacion desc limit 1;

	
--funcion que devuelve la funcion 
	select * from FU_datos_pregunta_MEMRZAR(7);
create or replace function FU_datos_pregunta_MEMRZAR(p_id_nivel int)
returns table
(
	r_id_pregunta int, r_enunciado varchar(900), r_extra varchar(900)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select p.id_pregunta, p.enunciado, ep.extra  from preguntas p 
		inner join extra_pregunta ep on p.id_pregunta  =ep.id_pregunta  
		where p.id_nivel =p_id_nivel order by p.fecha_creacion desc limit 1;
	end;
$BODY$


delete from extra_pregunta ;
delete from respuestas ;
delete from preguntas ;


select * from FU_datos_pregunta_MEMRZAR(7);
--15
select * from FU_datos_pregunta_MEMRZAR_id_pregunta(15);
create or replace function FU_datos_pregunta_MEMRZAR_id_pregunta(p_id_pregunta int)
returns table
(
	r_id_pregunta int, r_enunciado varchar(900), r_extra varchar(900)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select p.id_pregunta, p.enunciado, ep.extra  from preguntas p 
		inner join extra_pregunta ep on p.id_pregunta  =ep.id_pregunta  
		where p.id_pregunta =p_id_pregunta order by p.fecha_creacion desc limit 1;
	end;
$BODY$

select * from FU_imagen_pregunta(15)
create or replace function FU_imagen_pregunta(p_id_pregunta int)
returns table
(
	 r_url_img varchar(900)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select ep.extra  from preguntas p inner join extra_pregunta ep on p.id_pregunta = ep.id_pregunta where p.id_pregunta=p_id_pregunta;
	end;
$BODY$

select ep.extra  from preguntas p inner join extra_pregunta ep on p.id_pregunta = ep.id_pregunta ;


--funcion para ver las respuestas que tiene una pregunta 
select * from preguntas p;
select * from extra_pregunta ep ;
select * from respuestas r where id_pregunta = 25;

select * from tipos_preguntas tp ;


select * from FU_repuestas_MEMRZAR(25);
create or replace function FU_repuestas_MEMRZAR(p_id_pregunta int)
returns table
(
	r_id_repuesta int, r_opcion varchar(900), r_correcta bool, r_estado bool, r_eliminado bool 
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select r.id_respuesta, r.opcion, r.correcta, r.estado, r.eliminado from respuestas r where id_pregunta = p_id_pregunta;
	end;
$BODY$

select * from preguntas p where p.id_pregunta =25;
select opcion from respuestas r where r.id_pregunta =25;

insert into respuestas(id_pregunta, opcion, correcta, estado, eliminado)
			values(25,'Si',false,true,false)

select * from extra_pregunta ep ;

--../../uploads/respuestas/Walter_White_S5B-1703223678916.png

--hacer update para visualizar una imagen en una respuesta no ingresada por el frontend de momento 
update respuestas set opcion='../../uploads/respuestas/Walter_White_S5B-1703223678916.png'

select * from FU_ver_img_respuesta_MEMRZAR(1);
create or replace function FU_ver_img_respuesta_MEMRZAR(p_id_respuesta int)
returns table
(
	 r_url_img varchar(900)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select opcion from respuestas r where r.id_respuesta =p_id_respuesta;
	end;
$BODY$

select * from respuestas r 


select * from respuestas r ;

--procedimiento almacenado para anadir una respuesta
CREATE OR REPLACE PROCEDURE SP_anadir_respuesta_MEMRZAR(
		p_id_pregunta int,
		p_url_img varchar(500),
		p_correcta bool
		)
LANGUAGE plpgsql
AS $procedure$
Begin
	insert into respuestas(
						id_pregunta,
						opcion,
						correcta
						)values
						(
						 p_id_pregunta,
						 p_url_img,
						 p_correcta
						);

--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

--Hacer un trigger que verifique el numero de respuestas correcta con estado true en una pregunta de opcion Unica 
--ejecturarlo cada vez que se quiera anadir una nueva opcion de respuesta y cuando inserte una correcta 
--colocarle el bool error en false de la tabla pregunta

--en el trigger de insertar en repuestas
--	1. Se obtiene el id de la pregunta, para concectarla con la tabla pregunta


select * from respuestas r where r.id_pregunta =24;
--con esto se obtiene el id del pregunta maestro para saber si es respuesta unica o multiple 
select tp.opcion_multiple  from respuestas r 
inner join preguntas p on r.id_pregunta =r.id_pregunta 
inner join tipos_preguntas tp ON p.tipo_pregunta =tp.id_tipo_pregunta
where r.id_respuesta=2 limit 1;

--Si el tipo de pregunta en opcion multiple es false, entonces hacer la consulta para contar cuantas respuestas
--como correctas tiene esa pregunta 
select case when count(*) >=1 then true else false end   from respuestas r where r.id_pregunta = 24  and r.estado and r.correcta 
select *  from respuestas r where r.id_pregunta = 24  and r.estado and r.correcta 


select * from respuestas r where not r.correcta 


select * from preguntas p ;
--Creacion del trigger 
--funcion del trigger 
create or replace function FU_TR_anadir_respuesta() returns trigger 
as 
$$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;
		
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta


	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas then 
			raise exception 'Solo se admite un opcion de respuesta como correcta';
		else 
			update preguntas set error = true, error_detalle ='Esta pregunta no contiende opcion(es) correta(s)' where id_pregunta =new.id_pregunta;
		end if;
		--else if si no contiene correctas entonces actualizar el registro de preguntas bool error = true y detalle 'esta pregunta no contiende opcion(es) correta(s)'
		if new.correcta then
			update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
		end if;
		--if si la opcion es marcada como correcta acualizar el registro de preguntas bool error= false 
	end if;
return new;
end
$$
language 'plpgsql';

create trigger TR_Crear_respuesta
before insert 
on respuestas
for each row 
execute procedure FU_TR_anadir_respuesta();



--obtener la pregunta a la que se le esta andiendo las repuestas

select * from preguntas p where p.id_pregunta =25;

select  tp.opcion_multiple  from respuestas r 
	inner join preguntas p on r.id_pregunta =r.id_pregunta 
	inner join tipos_preguntas tp ON p.tipo_pregunta =tp.id_tipo_pregunta
	where /*r.id_respuesta=new.id_respuesta limit*/ r.id_pregunta=25 limit 1;

select tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
where p.id_pregunta = 25



if (opciones_multiples_op = false) then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if (contiene_correctas) then 
			raise exception 'Solo se admite un opcion de respuesta como correcta';
		end if;
	end if;


select case when count(*) >=1 then true else false end  
	from respuestas r where r.id_pregunta = 25
	and r.estado and r.correcta; 

	new.id_pregunta  and r.estado and r.correcta; 


select * from preguntas p 

select * from test t ;

--anadir dos columnas a test 
--una de error de tipo bool
--otra de tipo varchar para el detalle del error 
alter table test 
add column error_detalle varchar(500);

select * from test t ;

/*
18
 */
delete from test where id_test=13;

update test set error = true, error_detalle = 'No contiene secciones a evaluar'
where id_test = 18


select * from test t ;

--cast(LEFT(p.enunciado, 80) || '...' as varchar(900) ) as enunciad, cast(to_char(p.fecha_creacion,'DD-MON-YYYY')as varchar(500)) as fecha_crea,

--funcion para listar los test segun el id de un usuario
select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado, suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), error, error_detalle
	from test 
	where cast(id_user_crea as varchar(900))= '3b43792d-ec18-49a5-b8af-753c65cb9b21' and estado = true;

--funcion que retorna todos los test elaborados por el usuario
select * from FU_test_usuario('3b43792d-ec18-49a5-b8af-753c65cb9b21');

CREATE OR REPLACE FUNCTION FU_test_usuario(p_user_id character varying)
 RETURNS TABLE(
 	r_id_test int, r_titulo character varying, r_fecha_incio character varying, r_fecha_fin character varying, r_estado bool,
 	r_suspendido bool, r_descripcion character varying, r_ingresos_permitidos int, r_token character varying, r_error bool,
 	r_error_detalle character varying
 	)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado, suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), case when (select Count(*) from errores_test er where er.id_test=id_test and estado )>=1 then true else false end as error, error_detalle
	from test 
	where cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;
end;
$function$
;





select 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY  HH24:MI')as varchar(500)) as fecha_hora_inicio
	from test 
	where cast(id_user_crea as varchar(900))= '3b43792d-ec18-49a5-b8af-753c65cb9b21' and estado = true;

drop table errores_test

--crea tabla de errores_test 
create table errores_test(
	id_error INT GENERATED ALWAYS AS IDENTITY,
	id_test int not null,
	error_detalle varchar(300) not null ,
	Estado bool Default true not null,
		Primary Key(id_error)
);

select * from test t ;
alter table errores_test 
add constraint FK_ID_Test_errores
FOREIGN KEY (id_test) 
references test(id_test);


--insertar errores para el test que esta creado.
select * from errores_test;
select * from test t ;

insert into errores_test(id_test,error_detalle)values(18,'El test no contiene secciones');
insert into errores_test(id_test,error_detalle)values(18,'El test no contiene participantes');
--insert into errores_test(id_test,error_detalle)values(18,'El test no contiene participantes');

update errores_test set estado=true 

select * from errores_test

select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado, suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)),
	case when (select Count(*) from errores_test er where er.id_test=id_test and estado )>=1 then true else false end as error, 
	error_detalle
	from test 
	
	where cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;



delete from errores_test;
delete from participantes_test ;
delete from test ;

--este 1
--verificado no sirve
drop procedure sp_insertar_test
CREATE OR REPLACE PROCEDURE public.sp_insertar_test(
	IN p_titulo character varying, IN p_fecha_hora_cierre timestamp with time zone, IN p_fecha_hora_inicio timestamp with time zone, IN p_id_user_crea character varying, IN p_descripcion character varying, IN p_ingresos_permitidos integer)
 LANGUAGE plpgsql
AS $procedure$ 
declare 
	p_id_test int;
BEGIN
    INSERT INTO Test (Titulo, Fecha_hora_cierre, Fecha_hora_inicio, ID_User_crea, Descripcion, Ingresos_Permitidos)
    VALUES (p_Titulo, p_Fecha_hora_cierre, p_Fecha_hora_inicio, cast(p_ID_User_crea as uuid), p_Descripcion, p_Ingresos_Permitidos);
   	
   select into p_id_test t.id_test  from test t where t.titulo =p_titulo;
   --insertarlos errores la crear un test 
   --insert into errores_test(id_test,error_detalle)values(p_id_test,'El test no contiene secciones');
   --insert into errores_test(id_test,error_detalle)values(p_id_test,'El test no contiene participantes');
 EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
         RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

--este
--nuveov procedimineto corregido
--no sirve
CREATE OR REPLACE PROCEDURE public.sp_insertar_test(
    IN p_titulo character varying,
    IN p_fecha_hora_cierre timestamp with time zone,
    IN p_fecha_hora_inicio timestamp with time zone,
    IN p_id_user_crea character varying,
    IN p_descripcion character varying,
    IN p_ingresos_permitidos integer
)
LANGUAGE plpgsql
AS $procedure$ 
DECLARE 
    p_id_test int;
   p_fecha_hora_cierre_final timestamp with time zone;
    p_fecha_hora_inicio_final timestamp with time zone;
begin
	 -- Ajustar la zona horaria
    p_fecha_hora_cierre_final := p_fecha_hora_cierre AT TIME ZONE 'UTC';
    p_fecha_hora_inicio_final := p_fecha_hora_inicio AT TIME ZONE 'UTC';

    INSERT INTO Test (Titulo, p_fecha_hora_cierre_final, p_fecha_hora_inicio_final, ID_User_crea, Descripcion, Ingresos_Permitidos)
    VALUES (p_titulo, p_fecha_hora_cierre, p_fecha_hora_inicio, cast(p_id_user_crea as uuid), p_descripcion, p_ingresos_permitidos);
   
    SELECT INTO p_id_test id_test FROM test WHERE titulo = p_titulo;

    -- Insertar errores al crear un test 
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene secciones');
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene participantes');
    
EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;
END;
$procedure$;



-- DROP PROCEDURE public.sp_insertar_test(varchar, timestamp, timestamp, varchar, varchar, int4);

CREATE OR REPLACE PROCEDURE public.sp_insertar_test(IN p_titulo character varying, IN p_fecha_hora_cierre timestamp without time zone, IN p_fecha_hora_inicio timestamp without time zone, IN p_id_user_crea character varying, IN p_descripcion character varying, IN p_ingresos_permitidos integer)
 LANGUAGE plpgsql
AS $procedure$ 
DECLARE 
    p_id_test int;
BEGIN
    INSERT INTO Test (Titulo, Fecha_hora_cierre, Fecha_hora_inicio, ID_User_crea, Descripcion, Ingresos_Permitidos)
    VALUES (
        p_titulo,
        p_fecha_hora_cierre,
        p_fecha_hora_inicio,
        --cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500))
        cast(p_id_user_crea as uuid),
        p_descripcion,
        p_ingresos_permitidos
    );
   
    SELECT INTO p_id_test id_test FROM test WHERE titulo = p_titulo;

    -- Insertar errores al crear un test 
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene secciones');
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene participantes');
    
    
EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM USING HINT = 'Revisa la transacción principal.';
END;
$procedure$
;










drop procedure sp_insertar_test
--este 2 
--tampoco
CREATE OR REPLACE PROCEDURE public.sp_insertar_test(
    IN p_titulo character varying,
    IN p_fecha_hora_cierre TIMESTAMP,
    IN p_fecha_hora_inicio TIMESTAMP,
    IN p_id_user_crea character varying,
    IN p_descripcion character varying,
    IN p_ingresos_permitidos integer
)
LANGUAGE plpgsql
AS $procedure$ 
DECLARE 
    p_id_test int;
BEGIN
    INSERT INTO Test (Titulo, Fecha_hora_cierre, Fecha_hora_inicio, ID_User_crea, Descripcion, Ingresos_Permitidos)
    VALUES (
        p_titulo,
        p_fecha_hora_cierre,
        p_fecha_hora_inicio,
        --cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500))
        cast(p_id_user_crea as uuid),
        p_descripcion,
        p_ingresos_permitidos
    );
   
    SELECT INTO p_id_test id_test FROM test WHERE titulo = p_titulo;

    -- Insertar errores al crear un test 
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene secciones');
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene participantes');
    
    
EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM USING HINT = 'Revisa la transacción principal.';
END;
$procedure$;



select * from test t 

--parametros para crear un test 
	IN p_titulo character varying,
	IN p_fecha_hora_cierre timestamp with time zone,
	IN p_fecha_hora_inicio timestamp with time zone, 
	IN p_id_user_crea character varying, 
	IN p_descripcion character varying,
	IN p_ingresos_permitidos integer)

	
delete from errores_test;
delete from test;

delete from participantes_test 



select * from participantes_test pt;
select * from test t ;


ALTER TABLE test 
DROP COLUMN error_detalle;



select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado, suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), case when (select Count(*) from errores_test er where er.id_test=id_test and estado )>=1 then true else false end as error, error_detalle
	from test 
	
	
	select * from usuario u 
	
	select * from fu_test_usuario('3b43792d-ec18-49a5-b8af-753c65cb9b21');
	
	drop function fu_test_usuario
CREATE OR REPLACE FUNCTION public.fu_test_usuario(p_user_id character varying)
 RETURNS TABLE(r_id_test integer, r_titulo character varying, r_fecha_incio character varying, r_fecha_fin character varying, 
 r_estado character varying, 
 r_suspendido boolean, r_descripcion character varying, r_ingresos_permitidos integer, r_token character varying, r_error boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado_detalle, 
	suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), case when (select Count(*) from errores_test er where er.id_test=id_test and estado )>=1 then true else false end as error
	from test 
	where cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;
end;
$function$
;



--Crear una columna Estado2 para saber si:
	--Un test no puede publicarse por errores (Erroneo)
	--Un test esta apto para iniciarse (Verificado)
	--Un test esta en proceso (En proceso)
	--Un test fue Terminado (Terminado) 

--en el procedimiento agregar el primer estado (Erroneo)

select * from test t 


--funcion para listar los errores que tiene un test y que se tienen que corregir para pasar a estado = Verificado 

select * from FU_errores_test(64);
CREATE OR REPLACE FUNCTION public.FU_errores_test(p_id_test int)
 RETURNS TABLE(
 	r_id_error int,
 	r_error_detalle varchar(800),
 	r_estado bool
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select et.id_error, et.error_detalle , et.estado  from errores_test et
	where et.id_test= p_id_test and et.estado; --and estado = true;
end;
$function$
;


select * from errores_test et ;

select * from test t ;
select * from fu_detalle_test_id(64);
--funcion para ver el detalle del test, es decir, todos los datos 
drop function fu_detalle_test_id(int)
CREATE OR REPLACE FUNCTION public.fu_detalle_test_id(p_id_test int)
 RETURNS TABLE(
 r_titulo character varying,
  r_titulo_completo character varying,
 r_fecha_incio character varying, 
 r_fecha_fin character varying, 
 r_estado character varying, 
 r_suspendido boolean, 
 r_descripcion character varying, 
 r_ingresos_permitidos integer, 
 r_token character varying, 
 r_error boolean,
 r_numero_secciones int,
 r_numero_participantes int)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	--anadir el numero de secciones que tiene ese test 
	--anadir el numero de participantes que tiene el test
	select cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	titulo,
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado_detalle, 
	suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), 
	case when (select Count(*) from errores_test er where er.id_test=p_id_test and estado )>=1 then true else false end as error,
	(select cast(COUNT(*)as int) from test_secciones ts where ts.estado and ts.id_test=p_id_test),
	(select cast(COUNT(*)as int) from participantes_test pt where pt.estado and id_test=p_id_test)
	from test 
	where id_test = p_id_test; --cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;
end;
$function$
;


select * from participantes p;


--funcion para listar los participantes de un test mediante el id test 
select pt.id_participante_test ,pt.fecha_add ,pt.supero_limite ,pt.estado ,
		p.id_participante ,p.correo_institucional ,p.nombres_apellidos ,p.tipo_identificacion ,p.identificacion ,p.numero_celular
from participantes_test pt 
inner join participantes p on pt.id_participante =p.id_participante 
where pt.id_test =64;


select * from Fu_participantes_test_id(64);
--funcion para retornar los participantes de un test mediante el id 
CREATE OR REPLACE FUNCTION public.Fu_participantes_test_id(p_id_test int)
 RETURNS TABLE(
 r_id_participante_test int,
 r_fecha_add character varying,
 r_supero_limite bool,
 r_estado_particpante bool,
 r_id_participante character varying,
 r_correo_institucional character varying,
 r_nombres_apellidos character varying,
 r_tipo_identificacion character varying,
 r_identificacion character varying,
 r_numero_celular character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select pt.id_participante_test ,
			cast(to_char(pt.fecha_add,'DD-MON-YYYY')as varchar(500)) as Fecha,
			pt.supero_limite ,
			pt.estado ,
		cast(p.id_participante as varchar(800)) as id_participante ,
		p.correo_institucional ,
		p.nombres_apellidos ,
		cast(''as character varying),
		cast(''as character varying),
		cast(''as character varying)
	from participantes_test pt 
	inner join participantes p on pt.id_participante =p.id_participante 
	where pt.id_test =p_id_test;
end;
$function$
;

select * from participantes_test;
select * from participantes;


--funcion para listar a todos los participantes de 10 en 10 
select * from Fu_lista_participantes();

CREATE OR REPLACE FUNCTION public.Fu_lista_participantes()
 RETURNS TABLE(
r_id_participante character varying,
r_correo_institucional character varying,
r_nombres_apellidos character varying,
r_tipo_identificacion character varying,
r_identificacion character varying,
r_numero_celular character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(id_participante as varchar(500)), correo_institucional, nombres_apellidos, 
	cast('' as character varying), cast('' as character varying), 
	cast('' as character varying)
	from participantes p where estado order by nombres_apellidos asc limit 7;
end;
$function$
;

--funcion para buscar partipantes por palabra clave se

select * from Fu_lista_participantes_bucar('Alexander Vaca');

CREATE OR REPLACE FUNCTION public.Fu_lista_participantes_bucar(p_palabra_clave varchar(700))
 RETURNS TABLE(
r_id_participante character varying,
r_correo_institucional character varying,
r_nombres_apellidos character varying,
r_tipo_identificacion character varying,
r_identificacion character varying,
r_numero_celular character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(id_participante as varchar(500)), correo_institucional, nombres_apellidos, tipo_identificacion, identificacion, 
	numero_celular
	from participantes p where ((nombres_apellidos ILIKE '%' || p_palabra_clave || '%') or (correo_institucional ILIKE '%' || p_palabra_clave || '%')
								or (identificacion ILIKE '%' || p_palabra_clave || '%') or (numero_celular ILIKE '%' || p_palabra_clave || '%')) and estado
	order by nombres_apellidos asc limit 7;
end;
$function$
;

WHERE (nombres ILIKE '%' || palabra_clave || '%') or (correo_personal  ILIKE '%' || palabra_clave || '%') or (correo_institucional  ILIKE '%' || palabra_clave || '%') or (numero_celular  ILIKE '%' || palabra_clave || '%') or (nombre_firma  ILIKE '%' || palabra_clave || '%') or (cast(id_user as varchar(500)) ILIKE '%' || palabra_clave || '%') or (identificacion  ILIKE '%' || palabra_clave || '%')



select p.correo_institucional ,
		p.nombres_apellidos ,
		p.tipo_identificacion,
		p.identificacion,
		p.numero_celular  
from participantes p ;


select * from participantes p 

delete from participantes where correo_institucional='rcoelloc@uteq.edu.ec'


--modificar el SP donde se ingresa un participante a un test para quitarle el error de que no hay participantes 

-- DROP PROCEDURE public.sp_crear_participantes_test(varchar, int4);

CREATE OR REPLACE PROCEDURE public.sp_crear_participantes_test(IN p_id_participante character varying, IN p_id_test integer)
 LANGUAGE plpgsql
AS $procedure$ 
BEGIN
    INSERT INTO participantes_test (id_participante,id_test)
    VALUES (cast(p_id_participante as uuid),p_id_test);
   --quitar el error de que no existen participantes 
   --update errores_test set estado = false where id_test =p_id_test and error_detalle='El test no contiene participantes';
 EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        raise;
END;
$procedure$
;

select * from errores_test et;

--colocar un unique para que no se repita el id_participante y el id_test
select * from participantes_test pt 

delete from participantes_test

SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'participantes_test' order by column_name asc;



alter table participantes_test
  add constraint UQ_Test_id_participante
  unique (id_participante,id_test);
 
 
 alter table participantes_test
 drop constraint UQ_Test_id_participante
 
 
 --crear una funcion que verifique todo los estados del test y que este se llame desde el trigger de insertar 
 --y el trigger de update 
 
 --verifica si el test tiene participantes con estado true 
select * from participantes_test pt ;



 create or replace function FU_TR_test_participantes() returns trigger 
as 
$$
---Declarar variables
declare
	p_tiene_participantes bool;
	p_tiene_registro bool;
begin
	--primero verificar si tiene participantes activos el test
	 select into p_tiene_participantes case when COunt(*)>0 then true else false end from participantes_test pt 
 	where pt.id_test =new.id_test and estado ;
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =new.id_test and et.error_detalle ='El test no contiene participantes';
			
 	--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
	if p_tiene_participantes then 
		   update errores_test set estado = false where id_test =new.id_test and error_detalle='El test no contiene participantes';
	else 
			--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
			if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =new.id_test and error_detalle='El test no contiene participantes';
			else 
					--como no existe registro entonces crearlo 
			insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene participantes');
			end if;
	end if;
   
return new;
end
$$
language 'plpgsql';

create trigger TR_Test_Participantes_after
after insert 
on participantes_test
for each row 
execute procedure FU_TR_test_participantes();


--lo mismo pero para cuando se elimine un registro 
create or replace function FU_TR_test_participantes_delete() returns trigger 
as 
$$
---Declarar variables
declare
	p_tiene_participantes bool;
	p_tiene_registro bool;
begin
	--primero verificar si tiene participantes activos el test
	 select into p_tiene_participantes case when COunt(*)>0 then true else false end from participantes_test pt 
 	where pt.id_test =old.id_test and estado ;
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =old.id_test and et.error_detalle ='El test no contiene participantes';
			
 	--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
	if p_tiene_participantes then 
		   update errores_test set estado = false where id_test =old.id_test and error_detalle='El test no contiene participantes';
	else 
			--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
			if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =old.id_test and error_detalle='El test no contiene participantes';
			else 
					--como no existe registro entonces crearlo 
			insert into errores_test(id_test,error_detalle)values(old.id_test,'El test no contiene participantes');
			end if;
	end if;
   
return new;
end
$$
language 'plpgsql';

create trigger TR_Test_Participantes_after_delete
after delete 
on participantes_test
for each row 
execute procedure FU_TR_test_participantes_delete();

select * from participantes_test

select * from errores_test et ;

delete from participantes_test ;

update errores_test set estado = true

--crear un trigger cuando se crea un test 
--para insertar dos registros 

-- DROP FUNCTION public.fu_tr_test_validar_fechas();
select * from test t  et ;
--trigger after 
CREATE OR REPLACE FUNCTION public.fu_tr_test_insert_error()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin 
	insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene secciones');
   insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene participantes');
return new;
end
$function$
;

create trigger tr_test_validar_fechas_insert_error  
after insert 
on test
for each row 
execute procedure fu_tr_test_insert_error();






delete from errores_test ;
delete from participantes_test ;
delete from test ;

select * from preguntas p  



--funcion para listar las secciones que tenga niveles y que los niveles contengan preguntas xd

select * from fu_secciones_disponibles_test();

create or replace function fu_secciones_disponibles_test()
returns table
(
	r_id_seccion int, r_titulo varchar(500), r_num_niveles int
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select s.id_seccion, s.titulo, cast ((select COUNT(*) from 
								(select n.id_nivel, n.id_seccion, n.nivel  from niveles n 
								inner join preguntas p on n.id_nivel = p.id_nivel
									inner join respuestas r on p.id_pregunta=r.id_pregunta
								where n.estado 	and n.estado and p.estado and p.error = false and r.estado
								and n.id_seccion=s.id_seccion
								group by n.id_nivel, n.id_seccion, n.nivel ) as x
								)as int) as num_niveles from secciones s
	inner join niveles n on n.id_seccion=s.id_seccion	
	inner join preguntas p on n.id_nivel = p.id_nivel
	inner join respuestas r on p.id_pregunta=r.id_pregunta
	where s.estado and n.estado and p.estado and p.error = false and r.estado
	group by s.id_seccion, s.titulo; 
end;
$BODY$	


--crear una funcion que retorne datos sobre un formulario que se quiere acceder desde la app
--consulta mediante token de la URL 
/*
  IF NEW.fecha_hora_cierre <= NEW.fecha_hora_inicio THEN
    RAISE EXCEPTION 'La Fecha de cierre no puede ser menor o igual a Fecha de inicio del test';
  END IF;

 **/
select * from test t where cast(t.tokens as character varying) = '2bd38956-fbd7-4f8f-b5a2-57c8fae393ae'; 


select * from form_data('2bd38956-fbd7-4f8f-b5a2-57c8fae393ae');
--Pasar saber si esta caducado 

--retornar la tabla con los datos xd 
--drop FUNCTION form_data(p_token character varying)

--verificar tambien si la fecha y hora es correcta para poder entrar al formulario 
CREATE OR REPLACE FUNCTION form_data(p_token character varying)
 RETURNS TABLE( 
 	r_disponibilidad bool,
 	r_caducado bool,
 	r_poximo bool,
 	r_titulo character varying,
 	r_fecha_hora_inico character varying,
 	r_fecha_cierre character varying,
 	r_estado bool,
 	r_suspendio bool,
 	r_descripcion character varying,
 	r_ingresos_permitidos int,
 	r_token character varying,
 	r_estado_error bool
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select case when 
	Now()>=t.fecha_hora_inicio and Now()<= t.fecha_hora_cierre then true else false end as Verificacion_Disponibilidad,
	case when Now()>t.fecha_hora_cierre then true else false end as Caducado,
	case when Now()<t.fecha_hora_inicio then true else false end as Proximo,
	t.titulo, 
	cast(to_char(t.fecha_hora_inicio,'DD-MON-YYYY')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(t.fecha_hora_cierre,'DD-MON-YYYY')as varchar(500)) as fecha_cierre, 
	t.estado,
	t.suspendio,
	t.descripcion,
	t.ingresos_permitidos,
	cast(t.tokens as character varying),
	case when estado_detalle='Verificado' then true else false end as Estado_Error
	from test t where cast(t.tokens as character varying) = p_token; 
end;
$function$
;

select * from participantes p;

--eliminar los campos de participantes 
--tipo_identificacion
--identificacion
--numero_celular
 ALTER TABLE participantes
DROP constraint ch_tipo_identifi;


--eliminar el trigger de insertar 
CREATE OR REPLACE FUNCTION public.fu_tr_insert_participantes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	if trim(new.nombres_apellidos)='' then
            raise exception 'Nombres no puede ser vacio';
    end if;
     if trim(new.correo_institucional)='' then
            raise exception 'Correo institucional no puede ser vacio';
    end if;
   /*
    if new.identificacion  ~ '[^0-9]' then 
        raise exception 'Identificacion solo puede contener numeros';
    end if;
    if new.numero_celular  ~ '[^0-9]' then 
        raise exception 'Celular solo puede contener numeros';
    end if;
    if length(new.numero_celular) <> 10 then
        raise exception 'Celular debe tener 10 digitos';
    end if; 
    	if trim(new.tipo_identificacion)='' then
            raise exception 'Tipo de identificación no puede ser vacio';
    end if;
    --validar el tamano de la identificacion dependiendo del tipo
    if(new.tipo_identificacion='Cedula')then
        if length(new.identificacion)<>10 then
                    raise exception 'Cedula requiere 10 digitos';
        end if;
    end if;
    if(new.tipo_identificacion='Ruc')then
        if length(new.identificacion)<>13 then
                    raise exception 'Ruc requiere 13 digitos';
        end if;
    end if;
    if(new.tipo_identificacion='Pasaporte')then
        if length(new.identificacion)<>12 then
                    raise exception 'Pasaporte requiere 12 digitos';
        end if;
    end if;
    */
return new;
end
$function$
;


select * from participantes p;
--drop PROCEDURE public.sp_registrar_participantes(IN p_correo_institucional character varying, IN p_nombres_apellidos character varying, IN p_tipo_identificacion character varying, IN p_identificacion character varying, IN p_celular character varying)
--eliminar los campos que ya no existen y que se ingresan 

call sp_registrar_participantes();
--drop procedure sp_registrar_participantes(IN p_correo_institucional character varying, 
					IN p_nombres_apellidos character varying)
					
CREATE OR REPLACE PROCEDURE public.sp_registrar_participantes(IN p_correo_institucional character varying, 
					IN p_nombres_apellidos character varying)
 LANGUAGE plpgsql
AS $procedure$

Begin
	insert into participantes(
						correo_institucional,
						nombres_apellidos
						)values
						(
						 p_correo_institucional,
						 p_nombres_apellidos
						);
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


--funcion para buscar un usuario mediante el correo electronico 
select * from participantes p where p.correo_institucional ='rcoelloc2@uteq.edu.ec'




select *from auth_data_participantes('rcoelloc2@uteq.eec');
--true 
CREATE OR REPLACE FUNCTION public.auth_data_participantes(email character varying)
 RETURNS TABLE(r_verificado bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select case when COUNT(*)>0 then true else false end from participantes p where p.correo_institucional =email;
end;
$function$
;
select * from test t 

select * from id_participante_emil('rcoelloc2@uteq.edu.ec');

--funcion para retornar el id del participante segun el correo 
CREATE OR REPLACE FUNCTION public.id_participante_emil(email character varying)
 RETURNS TABLE(r_id_participante character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(p.id_participante as character varying) from participantes p where p.correo_institucional =email;
end;
$function$
;

select * from participantes p 

delete from participantes where correo_institucional = 'rcoelloc2@uteq.edu.ec'

--crear una tabla para primer ingreso donde se llenara los datos del usuario como:
--Carrera
--Facultad
--Semestre 
--entre otros posibles
--estos siempre se llenaran al ingresar a un formulario y se pegaran con el id del test-usuario 
create table Datos_Participante_Test(
	id_datos int generated always as identity,
	id_participante_test int not null,
	Facultad varchar(500) not null,
	Carrera varchar(500) not null,
	Semestre int not null,
	estado bool not null default true
);

alter table Datos_Participante_Test 
add constraint FK_ID_test_participante 
FOREIGN KEY (id_participante_test) 
references participantes_test(id_participante_test);


select * from participantes_test pt ;



create table tipos_preguntas(
	id_tipo_pregunta INT GENERATED ALWAYS AS IDENTITY,
	titulo varchar(200) not null unique,
	descripcion varchar(200) not null,
	estado bool not null default true,
	opcion_multiple bool not null default false,
	enunciado_img bool not null default false,
	timepo_enunciado int not null default 0,
	opciones_img bool not null default false,
		primary key (id_tipo_pregunta)
);


--para visualizar la primera interfaz para llenar el formulario de datos 
select * from form_data('2bd38956-fbd7-4f8f-b5a2-57c8fae393ae');

select * from data_participante_token_id('40da6252-9cf7-4d43-9b20-dbec18574769');

select * from participantes p 
--retornar los datos del participante mediante el token id

CREATE OR REPLACE FUNCTION public.data_participante_token_id(token_id character varying)
 RETURNS TABLE(
 r_correo_institucional character varying,
 r_nombres_apellidos character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.correo_institucional, p.nombres_apellidos from participantes p where cast(p.id_participante as character varying) =token_id;
end;
$function$
;

show time zone
--procedimiento almacenado para guardar la informacion del participate test 
--es decir la facultad
--carrera
--seemstre 
--    Fecha_Creacion TIMESTAMPTZ DEFAULT Now(),
select Now();
alter table Datos_Participante_Test 
add column  Fecha_Creacion TIMESTAMPTZ DEFAULT Now();


select * from Datos_Participante_Test
select * from participantes_test pt ;

delete from participantes_test

call ingresar_participante_test('794f8b91-aef1-4d9b-94ef-520ff61e8f2b','2bd38956-fbd7-4f8f-b5a2-57c8fae393ae','Ciencias de la INgenieria','SOftware','5');
select * from datos_participante_test dpt 

delete from datos_participante_test
delete from datos_participante_test 

delete from participantes_test 

--para ingresar al participante al test
--aqui generar todas las secciones y las preguntas que relizara el usuario 
--registrarlas en una tabla que se llame progreso por ejemplo 
--en el cual tenga una tabla de progreso seccion
--porgreso preguntas (todas las preguntas de la seccion sin importar el nivel)
--

select * from verificacion_participante_test('','');


--funcion para revisar si un usuario ya esta ingresado en el test de lo contrario registrarse 

CREATE OR REPLACE FUNCTION public.verificacion_participante_test(p_id_token_participante character varying, p_id_token_test character varying)
 RETURNS TABLE(r_verification bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select case when COUNT(*)>=1 then true else false end as Verification from participantes_test pt inner join test t on pt.id_test =t.id_test
where cast(t.tokens as character varying)=p_id_token_test and cast(pt.id_participante as character varying)=p_id_token_participante ;

end;
$function$
;

select * from datos_participante_test dpt ;

CREATE OR REPLACE FUNCTION public.fu_tr_insert_participantes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	if trim(new.facultad)='' then
            raise exception 'Facultad no puede ser vacio';
    end if;
     if trim(new.carrera)='' then
            raise exception 'Carrera no puede ser vacio';
    end if;
   if new.semestre>10 then 
   			raise exception 'Semestre no puede ser mayor a 10';
   end if;
  if new.semestre<1 then 
   			raise exception 'Semestre no puede ser menor a 1';
   end if;
return new;
end
$function$
;

create trigger TR_insertar_particpantes
before insert 
on datos_participante_test
for each row 
execute procedure fu_tr_insert_participantes();


--funcion para ver las secciones que tiene un test 

CREATE OR REPLACE FUNCTION public.secciones_test_id(p_id_test int)
 RETURNS TABLE(r_id_test_secciones int, r_estad_test_seccion bool, r_cantidad_niveles int, r_id_seccion int, r_descripcion character varying,r_titulo character varying, r_estado_seccion bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select ts.id_test_secciones,ts.estado ,ts.cantidad_niveles ,s.id_seccion ,s.descripcion ,s.titulo ,s.estado 
	from test_secciones ts 
	inner join secciones s on ts.id_seccion = s.id_seccion 	
	where ts.id_test =p_id_test;
end;
$function$
;

select * from secciones_test_id(1);

--anadir un campo para el numero de preguntas que va a tener cada nivel 
select * from test_secciones ts ;

alter table test_secciones 
add column numero_preguntas int not null default 1;

--procedimiento almacenado para unir una seccion al un test 

--restriccion uniqe solo puede exisitir una seccion con un test 
alter table test_secciones
  add constraint UQ_Test_Seccion
  unique (id_test,id_seccion);
 
 --procesimineot para registrar una seccion a un test 
 call SP_Crear_Seccion('Matematicas','Seccion de matematicas','3b43792d-ec18-49a5-b8af-753c65cb9b21');

select * from test t;
call SP_Ingresar_seccion_test(73,44,1);

select * from test_secciones ts 

Create or Replace Procedure SP_Ingresar_seccion_test(
										p_id_test int,
										p_id_seccion int,
										p_numero_preguntas int
										  )
Language 'plpgsql'
AS $$
declare
	p_cantidad_niveles int;
begin
	--primero obtener la cantidad de niveles disponibles en dicha seccion, es decir, los que no tengan ningun error y esten en estado true
	select into p_cantidad_niveles Count(*) as numNiveles from
	(SELECT
    n.id_nivel,
    n.id_seccion,
    cast(CONCAT('Nivel ', CAST(n.nivel AS VARCHAR)) as varchar(100)) AS nivel,
    cast(COUNT(p.id_nivel)as int) AS total_preguntas
	FROM
    niveles n
	LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
    LEFT join
    respuestas r on p.id_pregunta = r.id_pregunta 
	WHERE
    n.id_seccion = p_id_seccion
    and r.correcta 
	GROUP BY
    n.id_nivel, n.id_seccion, n.nivel
	ORDER BY
    n.id_nivel) as X;
	--insertar en test_secciones
	insert into test_secciones(id_test, id_seccion, cantidad_niveles,orden, numero_preguntas)
		values(p_id_test,p_id_seccion,p_cantidad_niveles,1,p_numero_preguntas);
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

select * from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
inner join respuestas r on p.id_pregunta = r.id_pregunta  
where r.correcta  and n.id_seccion =44;


select * from niveles n  inner join secciones s on n.id_seccion =s.id_seccion where s.id_seccion =44;


select * from secciones s 

select Count(*) as numNiveles from
(SELECT
    n.id_nivel,
    n.id_seccion,
    cast(CONCAT('Nivel ', CAST(n.nivel AS VARCHAR)) as varchar(100)) AS nivel,
    cast(COUNT(p.id_nivel)as int) AS total_preguntas
	FROM
    niveles n
	LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
    LEFT join
    respuestas r on p.id_pregunta = r.id_pregunta 
	WHERE
    n.id_seccion = 27
    and r.correcta 
	GROUP BY
    n.id_nivel, n.id_seccion, n.nivel
	ORDER BY
    n.id_nivel) as X
    
 
 --funcion que retorne el numero de preguntas validas por nivel dependiendo de una seccion 

    select * from FU_numeros_preguntas_validad_seccion(44);
    
CREATE OR REPLACE FUNCTION public.FU_numeros_preguntas_validad_seccion(p_id_seccion int)
 RETURNS TABLE(
	r_id_nivel int,
	r_id_seccion int,
	r_nivel character varying,
	r_total_preguntas int
 )
 LANGUAGE plpgsql		
AS $function$
begin
	return query
	 SELECT
    n.id_nivel,
    n.id_seccion,
    cast(CONCAT('Nivel ', CAST(n.nivel AS VARCHAR)) as varchar(100)) AS nivel,
    cast(COUNT(p.id_nivel)as int) AS total_preguntas
	FROM
    niveles n
	LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
    LEFT join
    respuestas r on p.id_pregunta = r.id_pregunta 
	WHERE
    n.id_seccion = p_id_seccion
    and r.correcta 
	GROUP BY
    n.id_nivel, n.id_seccion, n.nivel
	ORDER BY
    n.id_nivel;
end;
$function$
;


select * from test_secciones ts ;
select * from errores_test et ;
--anadir un trigger cuando se ingresa una seccion a un test para eliminar el error de que no hay secciones para el test.
create or replace function FU_TR_test_secciones() returns trigger 
as 
$$
---Declarar variables
declare
	p_tiene_secciones bool;
	p_tiene_registro bool;
begin
	--primero verificar si tiene participantes activos el test
	select into p_tiene_secciones case when COunt(*)>0 then true else false end from test_secciones ts where ts.id_test =new.id_test and ts.estado;
	
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =new.id_test and et.error_detalle ='El test no contiene secciones';
			
 	--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
	if p_tiene_secciones then 
		   update errores_test set estado = false where id_test =new.id_test and error_detalle='El test no contiene secciones';
		  --tambien actulizar el estado_detalle del test y colocar verificado
		  update test set estado_detalle ='Verificado' where id_test =new.id_test;
	else 
			--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
			if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =new.id_test and error_detalle='El test no contiene secciones';
			else 
					--como no existe registro entonces crearlo 
			insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene secciones');
			end if;
	end if;
   
return new;
end
$$
language 'plpgsql';

-- DROP FUNCTION public.fu_tr_test_participantes();






create trigger TR_Test_secciones_after
after insert 
on test_secciones
for each row 
execute procedure FU_TR_test_secciones();


create trigger TR_Test_secciones_after_update
after update  
on test_secciones
for each row 
execute procedure FU_TR_test_secciones();


delete from test_secciones ;

--corregir porque los formularios aun salen con error en obs
-- DROP FUNCTION public.fu_test_usuario(varchar);

select * from fu_test_usuario('3b43792d-ec18-49a5-b8af-753c65cb9b21');

CREATE OR REPLACE FUNCTION public.fu_test_usuario(p_user_id character varying)
 RETURNS TABLE(r_id_test integer, r_titulo character varying, r_fecha_incio character varying, r_fecha_fin character varying, r_estado character varying, r_suspendido boolean, r_descripcion character varying, r_ingresos_permitidos integer, r_token character varying, r_error boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado_detalle, 
	suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), case when (select Count(*) from errores_test er where er.id_test=t.id_test and estado )>=1 then true else false end as error
	from test t
	where cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;
end;
$function$
;

select * from test t;

--hacer un procedimiento que verifique los errores de un test 
--para actualizar el estado_detalle 
--por ejemplo si no tiene secciones = Erroneo
--si tiene secciones Verificado 
--y asi con los participantes 

--call SP_Verificar_Estado_error_Test

--este tiene llamarse dentro de los triggers  de test_particicpantes y test_secciones 
Create or Replace Procedure SP_Verificar_Estado_error_Test(
										p_id_test int
										  )
Language 'plpgsql'
AS $$
declare
	p_contien_errores bool;
begin
	--primer verificar las secciones
	select into p_contien_errores case when count(*)>=1 then true else false end as verificacion from errores_test et where et.id_test =p_id_test and et.estado ;
	if p_contien_errores then 
		  update test set estado_detalle ='Erroneo' where id_test =p_id_test;
			else 
			  update test set estado_detalle ='Verificado' where id_test =p_id_test;
			end if;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;





select * from test t ;





-- DROP FUNCTION public.fu_tr_test_participantes();

CREATE OR REPLACE FUNCTION public.fu_tr_test_participantes_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_tiene_participantes bool;
	p_tiene_registro bool;
begin
	--primero verificar si tiene participantes activos el test
	 select into p_tiene_participantes case when COunt(*)>0 then true else false end from participantes_test pt 
 	where pt.id_test =old.id_test and estado ;
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =old.id_test and et.error_detalle ='El test no contiene participantes';
			
 	--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
	if p_tiene_participantes then 
		   update errores_test set estado = false where id_test =old.id_test and error_detalle='El test no contiene participantes';
	else 
			--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
			if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =old.id_test and error_detalle='El test no contiene participantes';
			else 
					--como no existe registro entonces crearlo 
			insert into errores_test(id_test,error_detalle)values(old.id_test,'El test no contiene participantes');
			end if;
	end if;
   --verificar ele stado del test 
	call SP_Verificar_Estado_error_Test(old.id_test);
return new;
end
$function$




create trigger TR_Test_participantes_delete
after delete  
on participantes_test
for each row 
execute procedure fu_tr_test_participantes_delete();



-- DROP FUNCTION public.fu_tr_test_secciones();



create trigger TR_Test_secciones_delete
after delete  
on test_secciones
for each row 
execute procedure fu_tr_test_secciones_delete();


CREATE OR REPLACE FUNCTION public.fu_tr_test_secciones_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_tiene_secciones bool;
	p_tiene_registro bool;
begin
	--primero verificar si tiene participantes activos el test
	select into p_tiene_secciones case when COunt(*)>0 then true else false end from test_secciones ts where ts.id_test =old.id_test and ts.estado;
	
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =old.id_test and et.error_detalle ='El test no contiene secciones';
			
 	--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
	if p_tiene_secciones then 
		   update errores_test set estado = false where id_test =old.id_test and error_detalle='El test no contiene secciones';
	else 
			--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
			if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =old.id_test and error_detalle='El test no contiene secciones';
			else 
					--como no existe registro entonces crearlo 
			insert into errores_test(id_test,error_detalle)values(old.id_test,'El test no contiene secciones');
			end if;
	end if;
     --verificar ele stado del test 
	call SP_Verificar_Estado_error_Test(old.id_test);
return new;
end
$function$
;

;
select * from errores_test t ;



update errores_test  set estado = false where id_test =73 and error_detalle ='El test no contiene participantes';
delete from test_secciones ;


delete from participantes_test ;

delete from datos_participante_test ;


--Crear una tabla que sirva para registrar las secciones que va a realizar el participante 
drop table progreso_secciones;

create table progreso_secciones(
	id_progreso_seccion INT GENERATED ALWAYS AS IDENTITY,
	id_seccion int not null,
	id_participante_test int not null,
	estado_completado bool not null default false,
	bloqueado bool not null default true,
	porcentaje decimal null default 0,
	Primary Key(id_progreso_seccion)
);

alter table progreso_secciones 
add constraint FK_ID_Paritic_test 
FOREIGN KEY (id_seccion) 
references participantes_test(id_participante_test);



alter table progreso_secciones 
add constraint FK_ID_seccion 
FOREIGN KEY (id_seccion) 
references secciones(id_seccion);


select * from secciones s;



--funcino para retornar todas las secciones que tiene un test segun su token 
--esto va dentro de un cursor 
select s.id_seccion , s.titulo  from test t 
inner join test_secciones ts on t.id_test =ts.id_test 
inner join secciones s on ts.id_seccion =s.id_seccion 
where t.tokens ='df930033-4dde-4fe7-840e-b9362810dc0f'
order by ts.fecha_add asc;


select case when x.NUM = 1 then false else true end as Bloqueado,x.id_seccion from
(SELECT
    ROW_NUMBER() OVER (ORDER BY ts.fecha_add ASC) AS NUM,
    s.id_seccion
    FROM
    test t
    INNER JOIN test_secciones ts ON t.id_test = ts.id_test
    INNER JOIN secciones s ON ts.id_seccion = s.id_seccion
WHERE
    t.tokens = 'df930033-4dde-4fe7-840e-b9362810dc0f'
ORDER BY
    ts.fecha_add asc) as X;


--cursor de ejemplo del anterior proyecto

--llamada del cursor dentro de un procedimineto almacenado
PERFORM FU_Cursor_generar_seccion_participante(p_token_test,p_id_participante_test);
--ingresar_participante_test
--funcion del cursor
										--enviar el token del test    enviar tambien el id_participante_test


CREATE OR REPLACE FUNCTION FU_Cursor_generar_seccion_participante(p_token_test character varying, p_id_participante_test int)
RETURNS VOID AS
$$
DECLARE
 	p_bloqueado bool;
 	p_id_seccion int;
 	--consulta que devuelve las secciones de un test
 	--el case when devuelve si es la primera seccion desbloqueado 
    curCopiar cursor for select case when x.NUM = 1 then false else true end as Bloqueado,x.id_seccion from
			(SELECT
    			ROW_NUMBER() OVER (ORDER BY ts.fecha_add ASC) AS NUM,
    			s.id_seccion
    			FROM
    			test t
    			INNER JOIN test_secciones ts ON t.id_test = ts.id_test
    			INNER JOIN secciones s ON ts.id_seccion = s.id_seccion
				WHERE
    			cast(t.tokens as character varying) = p_token_test
				ORDER BY
   				 ts.fecha_add asc) as X;
begin
	/*Antes de Abrir el cursor se pueden declarar cosas, como por ejemplo crear un nuevo registro*/
	--
   open curCopiar;
	fetch next from curCopiar into p_bloqueado,p_id_seccion;
	while (Found) loop	
		
		/*[AQUI VA TODO LO QUE SE QUIERE REALIZAR CON EL CURSOR]*/
		--en este caso se necesita insertar las secciones en progreso secciones 
		--p_id_participante_test
		--p_bloqueado
		--p_id_seccion
		
		--EL BLOQUEADO POR DEFAULT VA A SER FALSE es decir no estaba bloqueado si el requisito cambia solo hay que enviar el p_bloqueado
		insert into progreso_secciones (
										id_seccion,
										id_participante_test,
										bloqueado
											) values(
											p_id_seccion,
											p_id_participante_test,
											false
											);
	--cerrar el cursor 
	fetch curCopiar into p_bloqueado,p_id_seccion;
	end loop;
	close curCopiar;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en el cursor: %', SQLERRM;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE public.ingresar_participante_test(
		IN p_token_id_participante character varying,
		IN p_token_id_test character varying,
		in p_facultad character varying,
		in p_carrera character varying,
		in p_semestre character varying
		)
LANGUAGE plpgsql
AS $procedure$
declare
	p_ID_Test int;
	p_Id_participante_test int;
begin
	--primero obtener el id test mediante el token para ingresar al usuario al test 
	select into p_ID_Test t.id_test from test t where cast(t.tokens as character varying) = p_token_id_test;
	--ingresar el usuario con ese id test obtenido xd 
	insert into participantes_test(id_participante, id_test) values (cast(p_token_id_participante as UUID), p_ID_Test);
	--obtener el id del registro de la tabla anterior xd 
	select into p_Id_participante_test id_participante_test from participantes_test where cast(id_participante as character varying) =p_token_id_participante and id_test = p_ID_Test;


	insert into Datos_Participante_Test(
						id_participante_test,
						facultad,
						carrera,
						semestre
						)values
						(
						 p_Id_participante_test,
						 p_facultad,
						 p_carrera,
						 cast(p_semestre as int)
						);
	--llamar al cursor para que se encargue de registrar las secciones
	PERFORM FU_Cursor_generar_seccion_participante(p_token_id_test,p_Id_participante_test);		
	--lamar al generador de preguntas
	---
	

	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select * from progreso_secciones ps ;


select ts.numero_preguntas ,* from test_secciones ts ;

--recorrer las secciones de las cuales se necesitan obtener los niveles y las preguntas


--se necesita el id_participante_test  

--con esto obtengo: 
	--id_seccion
	--cantidad_niveles
	--numero_preguntas por nivel

--id_test
--token del test
select ps.id_progreso_seccion ,ps.id_seccion,ts.cantidad_niveles,ts.numero_preguntas  from progreso_secciones ps 
inner join test_secciones ts on ps.id_seccion = ts.id_seccion
inner join test t on ts.id_test = t.id_test
where ps.id_participante_test =69 and cast(t.tokens as character varying)='df930033-4dde-4fe7-840e-b9362810dc0f';


select * from progreso_secciones ps 
select * from test_secciones


create table progreso_preguntas(
	id_progreso_preguntas INT GENERATED ALWAYS AS IDENTITY,
	id_progreso_seccion INT not null,
	id_pregunta int not null,
	Primary Key(id_progreso_preguntas)
);

alter table progreso_preguntas 
add constraint FK_ID_Progreso_seccion
FOREIGN KEY (id_progreso_seccion) 
references progreso_secciones(id_progreso_seccion);

alter table progreso_preguntas 
add constraint FK_ID_PRegunta_Progre
FOREIGN KEY (id_pregunta) 
references preguntas(id_pregunta);



select * from preguntas p  ps ;

--funcion que devuelve el progreso de las secciones de un usuario 

select * from FU_progreso_secciones_tokens('794f8b91-aef1-4d9b-94ef-520ff61e8f2b','df930033-4dde-4fe7-840e-b9362810dc0f');




CREATE OR REPLACE FUNCTION public.FU_progreso_secciones_tokens(p_id_toke_particiapnta character varying,p_id_token_test character varying)
 RETURNS TABLE(
 		r_id_progreso_seccion int,
 		r_id_seccion int,
 		r_id_participante_test int,
 		r_estado_completado bool,
 		r_bloqueado bool,
 		r_porcentaje decimal,
 		r_titulo_seccion character varying,
 		r_descripcion_seccion character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select ps.id_progreso_seccion ,ps.id_seccion ,ps.id_participante_test ,
		ps.estado_completado ,ps.bloqueado, ps.porcentaje, s.titulo, s.descripcion
	from test t 
	inner join participantes_test pt on t.id_test =pt.id_test 
	inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test
	inner join secciones s on ps.id_seccion = s.id_seccion
	where cast(t.tokens as character varying)=p_id_token_test
	and cast(pt.id_participante as character varying)=p_id_toke_particiapnta;
end;
$function$
;


select * from secciones s ;



--fncion para retornar los datos de un test mediante el token id 


select * from progreso_secciones ps ;
select *from preguntas p 



select * from FU_datos_test_token_id('df930033-4dde-4fe7-840e-b9362810dc0f');
CREATE OR REPLACE FUNCTION public.FU_datos_test_token_id(p_id_token_test character varying)
 RETURNS TABLE(
 		r_id_test int,
 		r_titulo character varying,
 		r_descripcion character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select t.id_test,t.titulo ,t.descripcion  
	from test t where cast(t.tokens as character varying)=p_id_token_test;

end;
$function$
;


select * from fu_datos_pregunta_memrzar_id_pregunta(28);


drop function fu_datos_pregunta_memrzar_id_pregunta(p_id_pregunta integer)

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_memrzar_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_extra character varying, r_tiempo_respuesta int, r_tiempo_enunciado int)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, ep.extra, p.tiempos_segundos, ep.tiempo_enunciado  from preguntas p 
		inner join extra_pregunta ep on p.id_pregunta  =ep.id_pregunta  
		where p.id_pregunta =p_id_pregunta order by p.fecha_creacion desc limit 1;
	end;
$function$
;


select * from preguntas p ;
select * from extra_pregunta ep ;






select * from secciones s 
where s.id_seccion =27



select * from respuestas r ;

select * from progreso_preguntas pp ;


create table progreso_respuestas(
	id_progreso_respuestas INT GENERATED ALWAYS AS IDENTITY,
	id_progreso_pregunta INT not null,
	respuesta character varying not null  default 'NA',
	tiempo_respuesta int not null default 0,
	Primary Key(id_progreso_respuestas)
);

alter table progreso_respuestas 
add constraint FK_ID_Progreso_pregunt
FOREIGN KEY (id_progreso_pregunta) 
references progreso_preguntas(id_progreso_preguntas);





select * from  progreso_preguntas pp  ;

select  pp.id_progreso_preguntas , pp.id_pregunta ,n.nivel , tp.codigo 
from participantes_test pt 
inner join test t on pt.id_test =t.id_test 
inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion
inner join preguntas p on pp.id_pregunta = p.id_pregunta 
inner join niveles n on p.id_nivel =n.id_nivel 
inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
--left join 
where cast(pt.id_participante as character varying)= '794f8b91-aef1-4d9b-94ef-520ff61e8f2b' and t.tokens ='df930033-4dde-4fe7-840e-b9362810dc0f'
and ps.id_seccion =27 --el id seccion tambien es parametro
order by n.nivel asc;



select * from preguntas p 

--modificar la funcion de ver las repuestas de MEMZAR para que salga la opcion 
CREATE OR REPLACE FUNCTION public.fu_repuestas_memrzar(p_id_pregunta integer)
 RETURNS TABLE(r_id_repuesta integer, r_opcion character varying, r_correcta boolean, r_estado boolean, r_eliminado boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select r.id_respuesta, r.opcion, r.correcta, r.estado, r.eliminado from respuestas r where id_pregunta = p_id_pregunta;
	end;
$function$
;


select * from tipos_preguntas tp ;

select * from preguntas p ;

delete from preguntas where tipo_pregunta in (3);

call SP_Crear_Pregunta_SELCIMG('Robalino',20,3,8);
--PROCEDIMIENTO PARA CREAR UNA PREGUNTA DE TIPO SELCIMG
CREATE OR REPLACE PROCEDURE SP_Crear_Pregunta_SELCIMG(
		p_enunciado character varying,
		p_tiempos_segundos int,
		p_tipo_pregunta int,
		p_id_nivel int
		)
LANGUAGE plpgsql
AS $procedure$
Begin
	insert into preguntas(
						enunciado,
						tiempos_segundos,
						tipo_pregunta,
						id_nivel,
						error_detalle
						)values
						(
						 p_enunciado,
						 p_tiempos_segundos,
						 p_tipo_pregunta,
						 p_id_nivel,
						 'No existen opciones de respuestas para la pregunta'
						);

--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

drop function  public.fu_datos_pregunta_selcimg(p_id_nivel integer)


CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg(p_id_nivel integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_nivel =p_id_nivel and tp.codigo ='SELCIMG' order by p.fecha_creacion desc limit 1 ;
	end;
$function$
;


drop FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(p_id_pregunta integer)

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_tiempo_segundo int)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, p.tiempos_segundos  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_pregunta =p_id_pregunta and tp.codigo ='SELCIMG' order by p.fecha_creacion desc limit 1;
	end;
$function$
;

select * from preguntas p ;
select * from tipos_preguntas tp 


-- DROP FUNCTION public.fu_preguntas_nivel1(varchar);

CREATE OR REPLACE FUNCTION public.fu_preguntas_nivel1(p_id_nivel character varying)
 RETURNS TABLE(r_enunciado character varying, r_fecha character varying, r_tiempo_segundos integer, r_estado boolean, r_id_pregunta character varying, r_id_p integer, r_error boolean, r_error_detalle character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(LEFT(p.enunciado, 80) || '...' as varchar(900) ) as enunciad, cast(to_char(p.fecha_creacion,'DD-MON-YYYY')as varchar(500)) as fecha_crea,
	p.tiempos_segundos, p.estado, tp.codigo, p.id_pregunta, p.error, p.error_detalle
	from preguntas p 
	inner join  tipos_preguntas tp on p.tipo_pregunta= tp.id_tipo_pregunta
	where p.id_nivel = cast(p_id_nivel as int) order by p.fecha_creacion asc;
end;
$function$
;

select * from progreso_secciones ps ;

select * from progreso_preguntas pp where pp.id_progreso_seccion =3; --27
select * from progreso_preguntas pp where pp.id_progreso_seccion =4; --44


select * from preguntas p where p.id_pregunta =29;

select  COUNT(*)
from  fu_lista_preguntas_faltan_resolver(
		'794f8b91-aef1-4d9b-94ef-520ff61e8f2b',
		'88611a91-a80c-434d-9401-ada38ee822b8',27);

select COUNT(*)
from  fu_lista_preguntas_faltan_resolver(
		'794f8b91-aef1-4d9b-94ef-520ff61e8f2b',
		'88611a91-a80c-434d-9401-ada38ee822b8',44);

select * from fu_verificar_hay_mas_preguntas(
'794f8b91-aef1-4d9b-94ef-520ff61e8f2b',
		'88611a91-a80c-434d-9401-ada38ee822b8',44);
	
	
select * from secciones s where s.id_seccion =27;
select * from secciones s where s.id_seccion =44;

select p.enunciado ,n.nivel  from preguntas p inner join niveles n on p.id_nivel=n.id_nivel 
where p.id_pregunta in (29,51)


select p.enunciado ,n.nivel  from preguntas p inner join niveles n on p.id_nivel=n.id_nivel 
where p.id_pregunta in (35,32,33,58,57)



--funcion para ver el progreso de un usuario en test 

		,44);

--funcion para monitorear el progreso de un participante segun las pruebas 
	
--PRUEBAS 
	delete from progreso_respuestas
select * from fu_monitoreo_progreso('794f8b91-aef1-4d9b-94ef-520ff61e8f2b','8279be02-af2c-4926-a8c9-1e9ade357b34',true,1);





call SP_REGISTRAR_RESPUESTA_UNICA(4,'si',4);
call SP_REGISTRAR_RESPUESTA_UNICA(5,'si',4);


delete from progreso_respuestas;
update extra_pregunta set tiempo_enunciado =7 where id_pregunta =29
select


--funcion para saber si existen mas preguntas por resolver xd 
CREATE OR REPLACE FUNCTION public.fu_verificar_hay_mas_preguntas(p_token_participante character varying,
													p_token_test character varying,
													p_id_seccion int)
 RETURNS TABLE(
 	r_verification bool
 )
 LANGUAGE plpgsql
AS $function$
begin
		return query
select  case when COUNT(*)<=0 then false else true end
from  fu_lista_preguntas_faltan_resolver(
		'794f8b91-aef1-4d9b-94ef-520ff61e8f2b',
		'88611a91-a80c-434d-9401-ada38ee822b8',27);
end;
$function$
;

/*
 drop function fu_monitoreo_progreso(p_token_participante character varying,
													p_token_test character varying,
													p_todo bool,
													p_id_seccion int)
 * */
CREATE OR REPLACE FUNCTION public.fu_monitoreo_progreso(p_token_participante character varying,
													p_token_test character varying,
													p_todo bool,
													p_id_seccion int)
 RETURNS TABLE(
 r_seccion character varying,
 r_enunciado character varying, 
r_nivel_pregunta int,
r_respuesta character varying,
r_id_progreso_pregunta int,
r_tiempo_respuesta int
 )
 LANGUAGE plpgsql
AS $function$
begin
	if p_todo then 
		return query
			select s.titulo ,p.enunciado ,n.nivel ,CASE WHEN pr.respuesta IS NULL THEN 'NA' ELSE pr.respuesta end, 
			pp.id_progreso_preguntas,pr.tiempo_respuesta
	from progreso_preguntas pp 
	full join progreso_respuestas pr 
	on pp.id_progreso_preguntas =pr.id_progreso_pregunta
	inner join progreso_secciones ps on pp.id_progreso_seccion =ps.id_progreso_seccion 
	inner join participantes_test pt on ps.id_participante_test =pt.id_participante_test 
	inner join test t on pt.id_test =t.id_test 
	inner join preguntas p on pp.id_pregunta = p.id_pregunta
	inner join niveles n on p.id_nivel = n.id_nivel 
	inner join secciones s on ps.id_seccion =s.id_seccion 
	where cast(pt.id_participante as character varying) =p_token_participante 
	and cast(t.tokens as character varying)  =p_token_test
	order by s.titulo,n.nivel  asc ;
	else 
			return query
		select s.titulo ,p.enunciado ,n.nivel ,CASE WHEN pr.respuesta IS NULL THEN 'NA' ELSE pr.respuesta end,
		pp.id_progreso_preguntas,pr.tiempo_respuesta
	from progreso_preguntas pp 
	full join progreso_respuestas pr 
	on pp.id_progreso_preguntas =pr.id_progreso_pregunta
	inner join progreso_secciones ps on pp.id_progreso_seccion =ps.id_progreso_seccion 
	inner join participantes_test pt on ps.id_participante_test =pt.id_participante_test 
	inner join test t on pt.id_test =t.id_test 
	inner join preguntas p on pp.id_pregunta = p.id_pregunta
	inner join niveles n on p.id_nivel = n.id_nivel 
	inner join secciones s on ps.id_seccion =s.id_seccion 
	where cast(pt.id_participante as character varying) =p_token_participante 
	and cast(t.tokens as character varying)  =p_token_test and s.id_seccion=p_id_seccion
	order by s.titulo,n.nivel  asc ;
	end if;

end;
$function$
;


--procedimiento para responder a una pregunta 
select * from progreso_respuestas pr ;

Create or Replace Procedure SP_REGISTRAR_RESPUESTA_UNICA(
										p_id_progreso_pregunta int,
										p_respuesta character varying,
										p_tiempo_respuesta int
										  )
Language 'plpgsql'
AS $$
begin
	insert into progreso_respuestas(id_progreso_pregunta,respuesta,tiempo_respuesta)values(
	p_id_progreso_pregunta,	p_respuesta,p_tiempo_respuesta
	);
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;


select * from progreso_secciones ps ;

select * from progreso_respuestas pr ;
--PRUEBAS 
select * from fu_monitoreo_progreso('794f8b91-aef1-4d9b-94ef-520ff61e8f2b','88611a91-a80c-434d-9401-ada38ee822b8',true,1);

--hacer el trigger de insertar respuesta after para poder saber si una seccion esta completa =true o incompleta = false 
--en la tabla de respuestas progreso 
select * from progreso_respuestas pr ;

--3 ejemplo

--tengo que contar las preguntas segun el id seccion
--y comprar con las registros de respuestas progreso segun el id de la seccion 

--primero obtener el id seccion que es unico para cada participante_test 
--new.id_progreso_pregunta =5 -->ejemplo
select pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=5;
-->3 id seccion 
--a este hacerle el seelect into 
select case when COUNT(*)=(select COUNT(*) from progreso_preguntas pp where pp.id_progreso_seccion =3) then true else false end 
as Completado
from progreso_respuestas pr inner join progreso_preguntas pp on pr.id_progreso_pregunta = pp.id_progreso_preguntas 
where pp.id_progreso_seccion =3;

--delete from progreso_respuestas ;
select * from progreso_secciones ps;

create or replace function FU_TR_reponder_progreso_respuestas() returns trigger 
as 
$$
---Declarar variables
declare
	p_id_progreso_seccion int;
	p_completo bool;
	p_porcentaje int;
begin
	--primero obtener el id seccion que es unico para cada participante_test 
	--new.id_progreso_pregunta =5 -->ejemplo
	select into p_id_progreso_seccion pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=new.id_progreso_pregunta;
	--hacer la comparacion para obtener el booleano 
	select into p_completo case when COUNT(*)=(select COUNT(*) from progreso_preguntas pp where pp.id_progreso_seccion =p_id_progreso_seccion) then true else false end 
	as Completado
	from progreso_respuestas pr inner join progreso_preguntas pp on pr.id_progreso_pregunta = pp.id_progreso_preguntas 
	where pp.id_progreso_seccion =p_id_progreso_seccion;
	
	--obtener el porcentaje 
	select into p_porcentaje
  	(COUNT(pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = p_id_progreso_seccion), 0) AS PorcentajeCompletado
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = p_id_progreso_seccion;
	--actualizar el registro
	update progreso_secciones set estado_completado=p_completo,porcentaje=p_porcentaje where id_progreso_seccion=p_id_progreso_seccion;

return new;
end
$$
language 'plpgsql';

create trigger TR_Responder_pregunta
after insert 
on progreso_respuestas
for each row 
execute procedure FU_TR_reponder_progreso_respuestas();

delete from progreso_respuestas ;
select * from progreso_secciones ps ;
update progreso_secciones set estado_completado  =false


-- lo mismo pero para eliminar 
create or replace function FU_TR_reponder_progreso_respuestas_delete() returns trigger 
as 
$$
---Declarar variables
declare
	p_id_progreso_seccion int;
	p_completo bool;
	p_porcentaje int;
begin
	--primero obtener el id seccion que es unico para cada participante_test 
	--new.id_progreso_pregunta =5 -->ejemplo
	select into p_id_progreso_seccion pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=old.id_progreso_pregunta;
	--hacer la comparacion para obtener el booleano 
	select into p_completo case when COUNT(*)=(select COUNT(*) from progreso_preguntas pp where pp.id_progreso_seccion =p_id_progreso_seccion) then true else false end 
	as Completado
	from progreso_respuestas pr inner join progreso_preguntas pp on pr.id_progreso_pregunta = pp.id_progreso_preguntas 
	where pp.id_progreso_seccion =p_id_progreso_seccion;
	
	--obtener el porcentaje 
	select into p_porcentaje
  	(COUNT(pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = p_id_progreso_seccion), 0) AS PorcentajeCompletado
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = p_id_progreso_seccion;
	--actualizar el registro
	update progreso_secciones set estado_completado=p_completo,porcentaje=p_porcentaje where id_progreso_seccion=p_id_progreso_seccion;

return new;
end
$$
language 'plpgsql';

create trigger TR_Responder_pregunta_delete
after delete 
on progreso_respuestas
for each row 
execute procedure FU_TR_reponder_progreso_respuestas_delete();


delete from progreso_respuestas ;


select * from progreso_respuestas;
select * from extra_pregunta

select * from preguntas p where p.enunciado ='Memorizar la imagen'
update extra_pregunta set tiempo_enunciado = 7 where id_pregunta =34 
--crear preguntas clasicas opcion unica 
select * from tipos_preguntas tp ;
--SELCCLA

select * from preguntas p ;
delete from preguntas where tipo_pregunta=4;

select * from fu_datos_pregunta_selcimg(59);
select * from fu_datos_pregunta_selcimg_id_pregunta(59);
-- DROP FUNCTION public.fu_datos_pregunta_selcimg(int4);

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg(p_id_nivel integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_nivel =p_id_nivel /*and tp.codigo ='SELCIMG'*/ order by p.fecha_creacion desc limit 1 ;
	end;
$function$
;


CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_tiempo_segundo integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, p.tiempos_segundos  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_pregunta =p_id_pregunta /*and tp.codigo ='SELCIMG'*/ order by p.fecha_creacion desc limit 1;
	end;
$function$
;





-- DROP FUNCTION public.fu_tr_reponder_progreso_respuestas();

--PRUEBAS 
	delete from progreso_respuestas
select * from fu_monitoreo_progreso('794f8b91-aef1-4d9b-94ef-520ff61e8f2b','76997343-d9d6-4bd6-b3c1-20b062f4a501',true,1);




CREATE OR REPLACE FUNCTION public.fu_tr_reponder_progreso_respuestas()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_id_progreso_seccion int;
	p_completo bool;
	p_porcentaje int;
begin
	--primero obtener el id seccion que es unico para cada participante_test 
	--new.id_progreso_pregunta =5 -->ejemplo
	select into p_id_progreso_seccion pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=new.id_progreso_pregunta;
	--hacer la comparacion para obtener el booleano 
	select into p_completo case when COUNT(*)>=(select COUNT(*) from progreso_preguntas pp where pp.id_progreso_seccion =p_id_progreso_seccion) then true else false end 
	as Completado
	from progreso_respuestas pr inner join progreso_preguntas pp on pr.id_progreso_pregunta = pp.id_progreso_preguntas 
	where pp.id_progreso_seccion =p_id_progreso_seccion;
	
	--obtener el porcentaje 
	select into p_porcentaje
  	(COUNT(pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = p_id_progreso_seccion), 0) AS PorcentajeCompletado
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = p_id_progreso_seccion;
	--actualizar el registro
	update progreso_secciones set estado_completado=p_completo,porcentaje=p_porcentaje where id_progreso_seccion=p_id_progreso_seccion;
	---verificar si la pregunta es de opcion multiple 
	--y si existe registro no dejar ingresar 
return new;
end
$function$
;


CREATE OR REPLACE FUNCTION public.fu_tr_reponder_progreso_respuestas_antes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_id_pregunta int;
	p_multiple bool;
	p_existe_registro bool;
begin
	--obtener el id pregunta
	--select * from progreso_respuestas
--20
	select into p_id_pregunta pp.id_pregunta  from progreso_preguntas pp where pp.id_progreso_preguntas =new.id_progreso_pregunta;
--id_pregunta = 64 

--con esto obtengo si es opcion multiple o no 
	select into p_multiple tp.opcion_multiple  from preguntas p 
	inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta =p_id_pregunta;

	--si es opcion unica solo debe de existir una repuesta de ese id_progreso_pregunta
	if p_multiple=false then
		select into p_existe_registro case when COUNT(*)>=1 then true else false end from progreso_respuestas pr where pr.id_progreso_pregunta =new.id_progreso_pregunta;
			if p_existe_registro=false then
				
			end if
			
	end if
	

--si no existe registro entonces se puede registrar
	---verificar si la pregunta es de opcion multiple 
	--y si existe registro no dejar ingresar 
return new;
end
$function$
;

create trigger TR_Responder_pregunta
before insert 
on progreso_respuestas
for each row 
execute procedure FU_TR_reponder_progreso_respuestas();


--PRUEBAS 
	delete from progreso_respuestas
select * from fu_monitoreo_progreso('794f8b91-aef1-4d9b-94ef-520ff61e8f2b','3da55c47-85df-4ee2-b573-a5bb7b4186af',true,1);



--obtener el id pregunta
--20
select pp.id_pregunta  from progreso_preguntas pp where pp.id_progreso_preguntas =20;
--id_pregunta = 64 

--con esto obtengo si es opcion multiple o no 
select tp.opcion_multiple  from preguntas p 
inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
where p.id_pregunta =64;

--si es opcion unica solo debe de existir una repuesta de ese id_progreso_pregunta
select case when COUNT(*)>=1 then true else false end from progreso_respuestas pr where pr.id_progreso_pregunta =20;

--si no existe registro entonces se puede registrar




alter table progreso_respuestas
drop constraint UQ_Repuestas_Preguta_progreso

alter table progreso_respuestas
  add constraint UQ_Repuestas_Preguta_progreso
  unique (respuesta,id_progreso_pregunta);
 
 select * from progreso_respuestas pr ;

delete from progreso_respuestas ;


select * from tipos_preguntas tp ;
insert into tipos_preguntas(
							titulo,
							descripcion,
							opcion_multiple,--
							enunciado_img,--
							opciones_img,--
							tipo_pregunta_maestra,--
							tiempo_enunciado, --
							icono,
							codigo
							)
						values(	
						'Localizar imagen',
						'El enunciado y las opciones se representan con imagenes',
						false,
						true,
						true,
						1,
						false,
						'memorizar',
						'LOCIMG'
						);

					
					
select * from preguntas p where p.id_pregunta =146
--crear un script para resetear la base de datos
select * from progreso_respuestas pr; 
select * from progreso_preguntas pp ; 
select * from progreso_secciones ps ;
select * from datos_participante_test dpt ;
select * from ingresos i ;
select * from participantes p ;
select * from participantes_test pt ;
select * from errores_test et ;
select * from test_niveles tn ;
select * from test_secciones ts ;
select * from test t ; 
select * from respuestas r ;
select * from extra_pregunta ep ;
select * from preguntas p ;
select * from niveles n ;
select * from secciones_usuario su ;
select * from secciones s ;

call SP_Limpiar_BD();
Create or Replace Procedure SP_Limpiar_BD()
Language 'plpgsql'
AS $$
begin
	--de momento este procedimiento no funciona debido a que se debe desahilitar cada uno de los tiggers y despues de liminar volverlos a crear 
	--por ejemplo: 
	--    ALTER TABLE extra_pregunta DROP CONSTRAINT IF EXISTS extra_pregunta_fk_pregunta;

	--eliminar los registros de la bd
delete from clave_valor_respuesta;
delete from progreso_respuestas ; 
delete from progreso_preguntas  ; 
delete from progreso_secciones  ;
delete from datos_participante_test  ;
delete from ingresos  ;
delete from participantes_test  ;
delete from participantes  ;
delete from test_niveles  ;
delete from test_secciones  ;
delete from errores_test; 


delete from test  ; 
delete from respuestas  ;
delete from extra_pregunta  ;
delete from preguntas  ;
delete from niveles  ;
delete from secciones_usuario  ;
delete from secciones ;
-- -- Habilitar nuevamente las restricciones de clave foránea
    --ALTER TABLE extra_pregunta ADD CONSTRAINT extra_pregunta_fk_pregunta FOREIGN KEY (pregunta_id) REFERENCES preguntas(id) ON DELETE CASCADE;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

select * from tipos_preguntas tp where tp.id_tipo_pregunta = 5

--arreglar el problema que no deja agregar mas repuestas despues de ingresar una como correcta xd 
-- DROP FUNCTION public.fu_tr_anadir_respuesta();

CREATE OR REPLACE FUNCTION public.fu_tr_anadir_respuesta()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;
		
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta


	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas then 
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		else 
			update preguntas set error = true, error_detalle ='Esta pregunta no contiende opcion(es) correta(s)' where id_pregunta =new.id_pregunta;
		end if;
		--else if si no contiene correctas entonces actualizar el registro de preguntas bool error = true y detalle 'esta pregunta no contiende opcion(es) correta(s)'
		if new.correcta then
			update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
		end if;
		--if si la opcion es marcada como correcta acualizar el registro de preguntas bool error= false 
	end if;
return new;
end
$function$
;


select * from respuestas r ;


select * from preguntas p 


delete from respuestas where id_pregunta = 84;
delete from extra_pregunta where id_pregunta = 84;
delete from preguntas where id_pregunta = 84


delete from progreso_respuestas ;


select * from progreso_respuestas;
select * from fu_monitoreo_progreso('3a3799d6-9cd3-4fa2-8ee9-613a4b8ea488','5d3e6965-579f-4f35-a83e-d24109fd092e',true,1);

select * from test_secciones ts ;





select * from progreso_secciones ps ;
select * from fu_verificar_hay_mas_preguntas('71a9a954-b7a3-4236-ab85-714ad817a526','5fc35a5a-fcc2-47da-b68e-173b841fcd29',57);



CREATE OR REPLACE FUNCTION public.fu_verificar_hay_mas_preguntas(p_token_participante character varying, p_token_test character varying, p_id_seccion integer)
 RETURNS TABLE(r_verification boolean)
 LANGUAGE plpgsql
AS $function$
begin
		return query
select  case when COUNT(*)<=0 then false else true end
from  fu_lista_preguntas_faltan_resolver(
		'794f8b91-aef1-4d9b-94ef-520ff61e8f2b',
		'88611a91-a80c-434d-9401-ada38ee822b8',27);
end;
$function$
;


--hacerle un group by
CREATE OR REPLACE FUNCTION public.fu_verificar_hay_mas_preguntas(p_token_participante character varying, p_token_test character varying, p_id_seccion integer)
 RETURNS TABLE(r_verification boolean)
 LANGUAGE plpgsql
AS $function$
begin
		return query
select  case when COUNT(*)<=0 then false else true end
from  fu_lista_preguntas_faltan_resolver(
		p_token_participante,
		p_token_test,p_id_seccion);
end;
$function$
;

ALTER TABLE public.preguntas drop constraint ch_tiempos_segundos
ALTER TABLE public.preguntas ADD CONSTRAINT ch_tiempos_segundos CHECK ((tiempos_segundos >= 2))

update preguntas set enunciado = 'Elige la palabra que continúa la serie.
Carro, Opción, Nunca, Angustia,
' where id_pregunta =107;
select * from preguntas p 



select * from tipos_preguntas_maestra tpm ;

insert into tipos_preguntas_maestra(titulo)values('Opcion Multiple');
--id de las preguntas de opcion multiple -->2 

select * from tipos_preguntas tp;

--insertar un tipo de pregunta de opcion multiple con imagenes sin enunciado extra 
insert into tipos_preguntas(
							titulo, --
							descripcion, --
							opcion_multiple, --
							enunciado_img, --
							opciones_img, --
							tipo_pregunta_maestra,--
							tiempo_enunciado,--
							icono, --
							codigo) values 
							(
							'Opciones imagenes',
							'Opcion mutiple con imagenes',
							true,
							false,
							true,
							2,
							false,
							'clasicoimagenes',
							'MULTIMG'
							);

--MULTIMG
--editar el trigger de insertar respuestas a una pregunta para las preguntas de opcion mutiple
-- DROP FUNCTION public.fu_tr_anadir_respuesta();
CREATE OR REPLACE FUNCTION public.fu_tr_anadir_respuesta()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;
		
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta


	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas = false  then 
		/*
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		else 
		*/
			update preguntas set error = true, error_detalle ='Esta pregunta no contiene opcion(es) correta(s)' where id_pregunta =new.id_pregunta;
		end if;
		--else if si no contiene correctas entonces actualizar el registro de preguntas bool error = true y detalle 'esta pregunta no contiende opcion(es) correta(s)'
		if new.correcta then
			update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
		end if;
		--if si la opcion es marcada como correcta acualizar el registro de preguntas bool error= false 
	--anadir el else para las preguntas multiples 
	else 
		--primero preguntar si tiene mas de 2 preguntas como correctas ya que esa es la condicion para que sea multiple 
		select into contiene_correctas case when count(*) >1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
			if contiene_correctas then 
				--como contiene mas de 2 correctas entonces la pregunta esta correcta 
				update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
			else 
				-- como no contiene mas de 2 correctas entonces colocar el error que indique que faltan respuestas correctas
				update preguntas set error = true, error_detalle ='Esta pregunta no contiene más de 2 respuestas correctas' where id_pregunta =new.id_pregunta;

			end if;
end if;
return new;
end
$function$
;

--trriger antes de insertar para verificar las preguntas de una sola opcion correcta 
CREATE OR REPLACE FUNCTION public.fu_tr_anadir_respuesta_before()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;	
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta
	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas then 
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		end if;
end if;
return new;
end
$function$
;

alter table respuestas
drop trigger tr_crear_respuesta


create trigger tr_crear_respuesta_before before
insert
    on
    public.respuestas for each row execute function fu_tr_anadir_respuesta_before()

delete from preguntas where id_pregunta =115
	delete from respuestas where id_pregunta =115


select * from respuestas r where r.id_pregunta =116



select * from preguntas where id_pregunta =116;
--112			
select * from preguntas order by preguntas.id_pregunta desc limit 1;


select  case when count(*) >=1 then true else false end
from respuestas r where r.id_pregunta = 117  and r.estado and r.correcta; 

select case when count(*) >1 then true else false end  from respuestas r where r.id_pregunta = 115  and r.estado and r.correcta; 



select * from progreso_preguntas pp i;

--crear un procedimiento almacenado que reciba como parametro el id_progreso y un json con las repuestas 
CREATE OR REPLACE PROCEDURE public.SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON(
														p_id_progreso_pregunta int,
														IN p_respuesta json, 
														p_tiempo_respuesta int)
 LANGUAGE plpgsql
AS $procedure$
declare
	--reemplazar el json para recorrerlo
	p_p_respuesta JSON;
	--variables del JSON
	r_opcion character varying;
	seleccionado bool;
begin
	
	
	FOR p_p_respuesta IN SELECT * FROM json_array_elements(p_respuesta)
    loop
	    --varibales 
       r_opcion := (p_p_respuesta ->> 'r_opcion')::varchar;
	   seleccionado := (p_p_respuesta ->> 'seleccionado')::boolean;
	  --si el seleccionado es true entonces insertar 
	  if seleccionado then 
	  		insert into progreso_respuestas(id_progreso_pregunta,
	  										respuesta,
	  										tiempo_respuesta)
	  										values (
	  										p_id_progreso_pregunta,
	  										r_opcion,
	  										p_tiempo_respuesta
	  										);
	  end if;
    end loop;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select * from progreso_respuestas pr where pr.id_progreso_pregunta =42;

delete from progreso_respuestas pr where pr.id_progreso_pregunta =42;

--arreglar esta funcion para las repuestas multiples 
-- DROP FUNCTION public.fu_tr_reponder_progreso_respuestas();

CREATE OR REPLACE FUNCTION public.fu_tr_reponder_progreso_respuestas()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_id_progreso_seccion int;
	p_completo bool;
	p_porcentaje int;
begin
	--primero obtener el id seccion que es unico para cada participante_test 
	--new.id_progreso_pregunta =5 -->ejemplo
	select into p_id_progreso_seccion pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=new.id_progreso_pregunta;
	--hacer la comparacion para obtener el booleano 
	select into p_completo case when COUNT(*)>=(select COUNT(*) from progreso_preguntas pp where pp.id_progreso_seccion =p_id_progreso_seccion) then true else false end 
	as Completado
	from progreso_respuestas pr inner join progreso_preguntas pp on pr.id_progreso_pregunta = pp.id_progreso_preguntas 
	where pp.id_progreso_seccion =p_id_progreso_seccion;
	
	--obtener el porcentaje 
	select into p_porcentaje
  	(COUNT(distinct pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = p_id_progreso_seccion), 0) AS PorcentajeCompletado
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = p_id_progreso_seccion;
	--actualizar el registro
	update progreso_secciones set estado_completado=p_completo,porcentaje=p_porcentaje where id_progreso_seccion=p_id_progreso_seccion;

return new;
end
$function$
;

--42 
	select   pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=42;

select 
  	(COUNT( distinct pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = 16), 0) AS PorcentajeCompletado
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = 16
    	group by 
  	pr.id_progreso_pregunta;
  
  
  select 
  	COUNT(pr.id_progreso_pregunta)
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = 16
    	group by 
  	pr.id_progreso_pregunta;
  
  
  
  SELECT COUNT(DISTINCT pr.id_progreso_pregunta)
FROM progreso_respuestas pr
INNER JOIN progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
WHERE pp.id_progreso_seccion = 16;
  



select * from progreso_respuestas pr ;


/*
 OPCION UNICA
-Crear pregunta de tipo Texto-->Numero
	-La pregunta tiene enunciado img.
	-La respuesta es de tipo input-->Num
-Se puede parametrizar si la pregunta es de tipo input y si el input es de tipo texto o numerico  
 * */
select * from tipos_preguntas tp;
insert into tipos_preguntas(titulo,descripcion,opcion_multiple,enunciado_img,opciones_img,tipo_pregunta_maestra,tiempo_enunciado,icono,codigo)
					values('Ingresar numero','Tipo de pregunta donde la respuesta es un numero ingresado',false,true,false,1,false,'clasico','INGRNUM');
				
--crear la funcion que permita registrar pregunta de este tipo con la respuesta ya incluida en la consulta 
-- DROP PROCEDURE public.sp_crear_pregunta_memrzar(varchar, int4, int4, int4, varchar, int4);

CREATE OR REPLACE PROCEDURE public.sp_crear_pregunta_INGRNUM(IN p_enunciado character varying, IN p_tiempos_segundos integer, IN p_tipo_pregunta integer, IN p_id_nivel integer, IN p_url_imagen character varying, IN p_tiempo_img integer)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_id_pregunta_creada int;
begin
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta');
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,0);
			
	--ahora insertar la respuesta
	insert into respuestas (id_pregunta,opcion,correcta) values (p_id_pregunta_creada,p_tiempo_img,true);		
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;
				

 select * from respuestas r ;
select * from preguntas p 

alter table respuestas drop CONSTRAINT respuestas_opcion_key
ALTER TABLE public.respuestas ADD CONSTRAINT respuestas_opcion_key UNIQUE (opcion,id_pregunta)

select * from preguntas p ;

select * from progreso_respuestas pr 
select * from usuario u 



select * from secciones s
inner join niveles n on s.id_seccion = n.id_seccion 
inner join preguntas p on p.id_nivel =n.id_nivel 
where s.titulo ='Memoria' and n.nivel =3;



--crear un nuevo tipo de pregunta en este caso se llamara Clave Valor y tendra un enunciado IMG 
--crear las tablas CLAVE y VALOR para poder registrar el nuevo tipo de pregunta 
drop table Claves_Preguntas
create table Claves_Preguntas(
	id_clave INT GENERATED ALWAYS AS IDENTITY,
	id_pregunta int not null,
	Clave character varying not null,
	Tipo character varying not null,
		primary key (id_clave)
);

ALTER TABLE public.Claves_Preguntas ADD CONSTRAINT UQclaves_preguntas UNIQUE (Clave,id_pregunta)

ALTER TABLE Claves_Preguntas 
drop CONSTRAINT CK_Tipos_Claves
CHECK (
	Clave = 'Texto' or Clave = 'Numero' 
);

alter table Claves_Preguntas 
add constraint FK_ID_pregunta_clave
FOREIGN KEY (id_pregunta) 
references preguntas(id_pregunta);


select * from preguntas p 
select * from respuestas r ;

--crear la tabla valor para las respuestas 
create table Valor_Preguntas(
	id_valor INT GENERATED ALWAYS AS IDENTITY,
	id_respuesta int not null,
	id_clave int not null,
	Valor character varying not null,
		primary key (id_valor)
);


alter table Valor_Preguntas 
add constraint FK_ID_Clave_Valor
FOREIGN KEY (id_clave) 
references Claves_Preguntas(id_clave);

alter table Valor_Preguntas 
add constraint FK_ID_Repuesta_Valor
FOREIGN KEY (id_respuesta) 
references respuestas(id_respuesta);

--anadir un campo a la tabla tipos preguntas para definir el campo ClaveValorComo Bool


select * from tipos_preguntas tp 
alter table tipos_preguntas 
add column ClaveValor bool;
update tipos_preguntas set ClaveValor = false ;
 alter table tipos_preguntas alter column ClaveValor set not null;

--crear el tipo de pregunta ClaveValor como opcion Multiple 
select * from tipos_preguntas tp 


--funcion para crear una pregunta que contenga claves para las repuestas xdxd skere modo diablo
insert into tipos_preguntas(titulo,descripcion,opcion_multiple,enunciado_img,opciones_img,tipo_pregunta_maestra,tiempo_enunciado,icono,codigo,ClaveValor)
					values('Ingreso de datos','Se pueden ingresar diferentes tipos de datos',false,true,false,2,false,'clasico','OPCLAVA',True);
		
				drop procedure SP_crear_pregunta_clave_valor_OPCLAVA
--funcion que permita crear una pregunta con clave valor
CREATE OR REPLACE PROCEDURE public.SP_crear_pregunta_clave_valor_OPCLAVA(
														p_enunciado varchar(800),
														p_tiempos_segundos int,
														p_tipo_pregunta int,
														p_id_nivel int,
														p_url_imagen varchar(800),											
														IN p_claves_valor json)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_id_pregunta_creada int;
	--reemplazar el json para recorrerlo
	p_p_claves_valor JSON;
	--variables del JSON
	r_clave character varying;
	r_tipo character varying;
begin
	--CREAR LA PREGUNTA
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta');
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,100);
	
	---RECORRER EL JSON PAR ANADIR LAS CLAVES
	FOR p_p_claves_valor IN SELECT * FROM json_array_elements(p_claves_valor)
    loop
	    --varibales 
       r_clave := (p_p_claves_valor ->> 'clave')::varchar;
	   r_tipo := (p_p_claves_valor ->> 'tipo')::varchar;
		--insertar los datos del JSON
	  		insert into claves_preguntas(
	  									id_pregunta,
	  									clave,
	  									tipo
	  									)
	  									values(	
	  									p_id_pregunta_creada,
	  									r_clave,
	  									r_tipo
	  									);

    end loop;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;
ALTER TABLE Claves_Preguntas 
add CONSTRAINT CK_Tipos_Claves
CHECK (
	tipo = 'Texto' or tipo = 'Numero' 
);

select * from 
select * from claves_preguntas ;

Create or Replace Procedure SP_Crear_Pregunta_MEMRZAR(
										p_enunciado varchar(800),
										p_tiempos_segundos int,
										p_tipo_pregunta int,
										p_id_nivel int,
										p_url_imagen varchar(800),
										p_tiempo_img int
										  )
Language 'plpgsql'
AS $$
declare
	p_id_pregunta_creada int;
begin
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta');
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,p_tiempo_img);
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

--hacer una funcion que retorne los datos de una pregunta de tipo Clave valor 
--o hacer una funcion aparte que retorne todos los datos de la clave 
drop function claves_preguntas_id
CREATE OR REPLACE FUNCTION public.claves_preguntas_id(p_id_pregunta int)
 RETURNS TABLE(r_id_clave int, r_clave character varying, r_tipo character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select id_clave , clave  , tipo from 
	claves_preguntas cp 
	where cp.id_pregunta = p_id_pregunta;
end;
$function$
;

select * from claves_preguntas_id(143);

select * from 




select * from claves_preguntas cp where cp.id_clave in (5,6);
select * from valor_preguntas vp where vp.id_clave in (5,6);















   select cast(CONCAT(uuid_generate_v1 (), CAST('.jpg' AS VARCHAR)) as varchar(100)) AS nivel


select uuid_generate_v1() as xd;


select * from preguntas p ;
select * from extra_pregunta ep ;
select * from claves_preguntas cp ;


delete from extra_pregunta where id_pregunta = 140;
delete from claves_preguntas where id_pregunta = 140;
delete from preguntas where id_pregunta = 140;


--nueva funcion para enviar preguntas con clave valor de TIPO 1 es decir solo se ingresa 1 
CREATE OR REPLACE PROCEDURE public.SP_crear_pregunta_clave_valor_OPCLAVA_no_JSON(
														p_enunciado varchar(800),
														p_tiempos_segundos int,
														p_tipo_pregunta int,
														p_id_nivel int,
														p_url_imagen varchar(800),											
														p_clave varchar(500),
														p_tiempo_enunciado int)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_id_pregunta_creada int;
begin
	--CREAR LA PREGUNTA
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta');
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,p_tiempo_enunciado);
	
	---RECORRER EL JSON PAR ANADIR LAS CLAVES
	---YA NO SE RECCORRE EL JSON SI NO QUE SE INGRESA LA CLAVE DIRECTO CUANDO ES DE TIPO 1
			insert into claves_preguntas(
	  									id_pregunta,
	  									clave,
	  									tipo
	  									)
	  									values(	
	  									p_id_pregunta_creada,
	  									p_clave,
	  									'Texto'
	  									);
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

select * from claves_preguntas cp 

--funcion para crear una repuesta con una sola clave de pregunta skere modo diablo 
drop procedure SP_anadir_respuesta_una_CLAVE_VALOR
CREATE OR REPLACE PROCEDURE SP_anadir_respuesta_una_CLAVE_VALOR(
		p_id_pregunta int,
		p_url_img varchar(500),
		--datos de la clave valor
		r_id_clave int,
			 character varying
		)
LANGUAGE plpgsql
AS $procedure$
declare 
	p_id_respuesta_creada int;
Begin
	insert into respuestas(
						id_pregunta,
						opcion,
						correcta
						)values
						(
						 p_id_pregunta,
						 p_url_img,
						 true
						);
	--obtener el id de la respuesta creada ultima
	select into p_id_respuesta_creada r.id_respuesta  from respuestas r where r.id_pregunta=id_pregunta
	order by r.id_respuesta  desc limit 1;

	--ingresar valor de la respuesta en la tabla valor xd
	insert into valor_preguntas(id_respuesta,id_clave,valor)
		values(p_id_respuesta_creada,r_id_clave,r_valor);

--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select r.id_respuesta  from respuestas r where r.id_pregunta=83 
order by r.id_respuesta  desc limit 1

select *from valor_preguntas vp ;


--Ver las respuestas con las claves 

drop FUNCTION public.fu_repuestas_con_valores1(p_id_pregunta integer)

CREATE OR REPLACE FUNCTION public.fu_repuestas_con_valores1(p_id_pregunta integer)
 RETURNS TABLE(r_id_repuesta integer, r_opcion character varying, r_correcta boolean, r_estado boolean, r_eliminado boolean, r_valor character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select r.id_respuesta, r.opcion, r.correcta, r.estado, r.eliminado, vp.valor from respuestas r 
	inner join valor_preguntas vp on r.id_respuesta = vp.id_respuesta 
	where id_pregunta = p_id_pregunta;
	end;
$function$
;
select * from valor_preguntas vp 
select * from fu_repuestas_con_valores1(141);

select * from claves_preguntas cp 




select * from tipos_preguntas tp 

select * from preguntas p where p.tipo_pregunta  = 8


--registrar las respuestas con claves-valor 
--se tiene que enviar el id_pregunta_progreso 
--el JSON las respuestas 
---
-- DROP PROCEDURE public.sp_registrar_respuesta_multiple_json(int4, json, int4);

CREATE OR REPLACE PROCEDURE public.sp_registrar_respuesta_multiple_json_CLAVE_VALOR1
(IN p_id_progreso_pregunta integer, IN p_respuesta json, IN p_tiempo_respuesta integer)
 LANGUAGE plpgsql
AS $procedure$
declare
	--reemplazar el json para recorrerlo
	p_p_respuesta JSON;
	--variables del JSON

	r_opcion character varying;
	r_id_clave int;
	r_valor character varying;
	--seleccionado bool;
	r_id_respuesta_creada int;
begin
	
	
	FOR p_p_respuesta IN SELECT * FROM json_array_elements(p_respuesta)
    loop
	    --varibales 
       r_opcion := (p_p_respuesta ->> 'opcion')::varchar;
	   r_id_clave := (p_p_respuesta ->> 'id_clave')::int;
	   r_valor := (p_p_respuesta ->> 'r_valor')::varchar;
	  		insert into progreso_respuestas(id_progreso_pregunta,
	  										respuesta,
	  										tiempo_respuesta)
	  										values (
	  										p_id_progreso_pregunta,
	  										r_opcion,
	  										p_tiempo_respuesta
	  										);
	  		--ahora buscar el id de la ultima respuesta insertada para insertar en clave valor el valor y el id_clave 
			select into r_id_respuesta_creada  id_progreso_respuestas  from progreso_respuestas pr where pr.id_progreso_pregunta = id_progreso_pregunta order by id_progreso_respuestas desc limit 1;
		--ahora insertar en clave valor 
		insert into Clave_Valor_respuesta(
											id_progreso_respuesta,
											clave,
											valor
											)values(
											r_id_respuesta_creada,
											r_id_clave,
											r_valor
											);
    end loop;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$


;

--primero crear la tabla CLAVE_VALOR EN RESPUESTAS PROGRESO 
select id_progreso_respuestas  from progreso_respuestas pr where pr.id_progreso_pregunta = 95 order by id_progreso_respuestas desc limit 1;

drop table Clave_Valor_respuesta
create table Clave_Valor_respuesta(
	id_registro INT GENERATED ALWAYS AS IDENTITY,
	id_progreso_respuesta int not null,
	Clave int not null,
	Valor character varying not null,
		primary key (id_registro)
);

alter table Clave_Valor_respuesta 
drop constraint FK_ID_progreso_respuesta_claves


alter table Clave_Valor_respuesta 
add constraint FK_ID_progreso_respuesta_claves
FOREIGN KEY (id_progreso_respuesta) 
references progreso_respuestas(id_progreso_respuestas);



alter table Clave_Valor_respuesta 
add constraint FK_ID_progreso_respuesta_claves_ID_CLAVE
FOREIGN KEY (Clave) 
references claves_preguntas(id_clave);



select * from claves_preguntas cp 


alter table Clave_Valor_respuesta 
add column tipo_pregunta_maestra int;




select * from Clave_Valor_respuesta
select * from progreso_respuestas pr ;






---CREAR UN NUEVO TIPO DE PREGUNTA PARA LOS QUE TIENEN CLAVE VALOR DE 2 INPUT
--funcion para crear una pregunta que contenga claves para las repuestas xdxd skere modo diablo
insert into tipos_preguntas(titulo,descripcion,opcion_multiple,enunciado_img,opciones_img,tipo_pregunta_maestra,tiempo_enunciado,icono,codigo,ClaveValor)
					values('Ingreso de datos 2','Se pueden ingresar 2 diferentes tipos de datos',true,true,true,2,true,'clasico','OPCLAV2',True);
	
select * from tipos_preguntas tp 



--nueva funcion para enviar preguntas con clave valor de TIPO 2 es decir 2 se ingresa 2 
CREATE OR REPLACE PROCEDURE public.SP_crear_pregunta_clave_valor_OPCLAV2_no_JSON(
														p_enunciado varchar(800),
														p_tiempos_segundos int,
														p_tipo_pregunta int,
														p_id_nivel int,
														p_url_imagen varchar(800),											
														p_clave varchar(500),
														p_clave2 varchar(500),
														p_tiempo_enunciado int)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_id_pregunta_creada int;
begin
	--CREAR LA PREGUNTA
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta');
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,p_tiempo_enunciado);
	
	---RECORRER EL JSON PAR ANADIR LAS CLAVES
	---YA NO SE RECCORRE EL JSON SI NO QUE SE INGRESA LA CLAVE DIRECTO CUANDO ES DE TIPO 1
			insert into claves_preguntas(
	  									id_pregunta,
	  									clave,
	  									tipo
	  									)
	  									values(	
	  									p_id_pregunta_creada,
	  									p_clave,
	  									'Texto'
	  									);
	  		--insertar la 2da clave 
	  		insert into claves_preguntas(
	  									id_pregunta,
	  									clave,
	  									tipo
	  									)
	  									values(	
	  									p_id_pregunta_creada,
	  									p_clave2,
	  									'Texto'
	  									);						
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select * from claves_preguntas cp 


---Anadir respeustas a clave valor 2 
drop procedure SP_anadir_respuesta_dos_CLAVE_VALOR
CREATE OR REPLACE PROCEDURE SP_anadir_respuesta_dos_CLAVE_VALOR(
		p_id_pregunta int,
		p_url_img varchar(500),
		--datos de la clave valor
		r_id_clave int,
		r_valor character varying,
		r_id_clave1 int,
		r_valor1 character varying
		)
LANGUAGE plpgsql
AS $procedure$
declare 
	p_id_respuesta_creada int;
Begin
	insert into respuestas(
						id_pregunta,
						opcion,
						correcta
						)values
						(
						 p_id_pregunta,
						 p_url_img,
						 true
						);
	--obtener el id de la respuesta creada ultima
	select into p_id_respuesta_creada r.id_respuesta  from respuestas r where r.id_pregunta=id_pregunta
	order by r.id_respuesta  desc limit 1;

	--ingresar valor de la respuesta en la tabla valor xd
	insert into valor_preguntas(id_respuesta,id_clave,valor)
		values(p_id_respuesta_creada,r_id_clave,r_valor);
	--ingresar el 2do valor clave 
	insert into valor_preguntas(id_respuesta,id_clave,valor)
		values(p_id_respuesta_creada,r_id_clave1,r_valor1);
--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select * from claves_preguntas cp 
select * from respuestas r where r.id_pregunta=143
select * from valor_preguntas vp where vp.id_respuesta=418

select * from fu_repuestas_con_valores1(143)

select * from fu_repuestas_con_valores2(143);
select * from respuestas r where r.id_pregunta =143


drop FUNCTION public.fu_repuestas_con_valores1(p_id_pregunta integer)

CREATE OR REPLACE FUNCTION public.fu_repuestas_con_valores2(p_id_pregunta integer)
 RETURNS TABLE(r_id_repuesta integer, r_opcion character varying, r_correcta boolean, r_estado boolean, r_eliminado boolean, r_valor character varying, r_valor2 character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	 select X.id_respuesta,X.opcion,X.correcta ,X.estado,X.eliminado,X.valor,X.valor2 from 
	 (
	 select r.id_respuesta as id_respuesta, 	
	 		r.opcion as opcion, 
	 		r.correcta as correcta, 
	 		r.estado as estado, 
	 		r.eliminado as eliminado, 
	 		vp.valor as valor,  
	 cast((select vp.valor from  valor_preguntas vp where vp.id_respuesta =  r.id_respuesta
	 order by vp.id_valor desc limit 1)as character varying) as 
	 		valor2,
    ROW_NUMBER() OVER (PARTITION BY r.id_respuesta ORDER BY vp.id_valor asc) AS row_number
	from respuestas r 
	inner join valor_preguntas vp on r.id_respuesta = vp.id_respuesta 
	where id_pregunta = p_id_pregunta order by vp.id_valor --asc limit 1;
	)as X where X.row_number =1 ;
		end;
$function$
;

(
	 select X.id_respuesta,X.opcion,X.correcta ,X.estado,X.eliminado,X.valor,X.valor2 from 
	 (
	 select r.id_respuesta as id_respuesta, 	
	 		r.opcion as opcion, 
	 		r.correcta as correcta, 
	 		r.estado as estado, 
	 		r.eliminado as eliminado, 
	 		vp.valor as valor,  
	 cast((select vp.valor from  valor_preguntas vp where vp.id_respuesta =  r.id_respuesta
	 order by vp.id_valor desc limit 1)as character varying) as valor2,
    ROW_NUMBER() OVER (PARTITION BY r.id_respuesta ORDER BY vp.id_valor asc) AS row_number
	from respuestas r 
	inner join valor_preguntas vp on r.id_respuesta = vp.id_respuesta 
	where id_pregunta = 143 order by vp.id_valor --asc limit 1;
	)as X where X.row_number =1 ;


select * from valor_preguntas



CREATE OR REPLACE PROCEDURE public.sp_registrar_respuesta_multiple_json_CLAVE_VALOR2
(IN p_id_progreso_pregunta integer, IN p_respuesta json, IN p_tiempo_respuesta integer)
 LANGUAGE plpgsql
AS $procedure$
declare
	--reemplazar el json para recorrerlo
	p_p_respuesta JSON;
	--variables del JSON

	r_opcion character varying;
	r_id_clave int;
	r_id_clave1 int;
	r_valor character varying;
	r_valor1 character varying;
	--seleccionado bool;
	r_id_respuesta_creada int;
begin
	
	
	FOR p_p_respuesta IN SELECT * FROM json_array_elements(p_respuesta)
    loop
	    --varibales 
       r_opcion := (p_p_respuesta ->> 'opcion')::varchar;
	   r_id_clave := (p_p_respuesta ->> 'id_clave')::int;
	   r_valor := (p_p_respuesta ->> 'r_valor')::varchar;
	   r_id_clave1 := (p_p_respuesta ->> 'id_clave1')::int;
	   r_valor1 := (p_p_respuesta ->> 'r_valor1')::varchar;
	  		insert into progreso_respuestas(id_progreso_pregunta,
	  										respuesta,
	  										tiempo_respuesta)
	  										values (
	  										p_id_progreso_pregunta,
	  										r_opcion,
	  										p_tiempo_respuesta
	  										);
	  		--ahora buscar el id de la ultima respuesta insertada para insertar en clave valor el valor y el id_clave 
			select into r_id_respuesta_creada  id_progreso_respuestas  from progreso_respuestas pr where pr.id_progreso_pregunta = id_progreso_pregunta order by id_progreso_respuestas desc limit 1;
		--ahora insertar en clave valor 
		insert into Clave_Valor_respuesta(
											id_progreso_respuesta,
											clave,
											valor
											)values(
											r_id_respuesta_creada,
											r_id_clave,
											r_valor
											);
		--insertar el segundo clave valor 
										insert into Clave_Valor_respuesta(
											id_progreso_respuesta,
											clave,
											valor
											)values(
											r_id_respuesta_creada,
											r_id_clave1,
											r_valor1
											);
    end loop;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$


;



select * from clave_valor_respuesta 

select * from progreso_respuestas pr 










--select * from usuario u where correo_institucional =${'or '1' = '1 '} and contra =''



select * from FU_SQL_Inyection1(cast('${'or '1' = '1 }', as varchar(500)),cast('${'or '1' = '1 }', as varchar(500)));
--funcion para ver el funcionamiento del hacking etico con el metodo de SQL inyection 
create or replace function FU_SQL_Inyection1(p_username varchar(500), p_contra varchar(500))
returns table
(
	 r_result varchar(500)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select case when COUNT(*)>0 then 'Verificado' else 'No autorizado' end  from usuario u where correo_institucional = p_username /*and contra =''*/;
end;
$BODY$


select case when COUNT(*)>0 then 'Verificado' else 'No autorizado' end  
from usuario u where correo_institucional = '${'or '1' = '1 }' and contra ='${'or '1' = '1 }'


--crear el tipo de pregunta igual como MULTIMG pero este si tiene enunciado img con tiempo 
select * from tipos_preguntas tp where tp.codigo ='MULTIMG';

insert into tipos_preguntas (
							titulo, 
							descripcion,
							opcion_multiple, --
							enunciado_img, --
							opciones_img,
							tipo_pregunta_maestra,--
							tiempo_enunciado,--
							icono,
							codigo,
							clavevalor
							) values (
							'Opciones imagenes con temporizador',
							'Opcion multiple con imagenes y tiempo para ver el enunciado',
							true,
							true,
							true,--opciones img.
							2,
							true,
							'clasicoimagenes',
							'MULIMGT',
							false
							); 

select * from tipos_preguntas tp 


--anadir una culmnas a las preguntas que sea de tipo columnas xdxdxd para saber en cuantas columnas se va a dividir la pregunta
alter table preguntas  
add column columnas_pc int;

alter table preguntas  
add column columnas_movil int;

select * from preguntas p; 

update preguntas set columnas_pc=0, columnas_movil=0 

--nueva funcion para crear preguntas con imagenen enunciado y el numero de columnas 
-- DROP PROCEDURE public.sp_crear_pregunta_memrzar(varchar, int4, int4, int4, varchar, int4);

CREATE OR REPLACE PROCEDURE public.sp_crear_pregunta_columnas(
IN p_enunciado character varying, IN p_tiempos_segundos integer, IN p_tipo_pregunta integer, IN p_id_nivel integer, IN p_url_imagen character varying, IN p_tiempo_img integer, in p_columnas int )
 LANGUAGE plpgsql
AS $procedure$
declare
	p_id_pregunta_creada int;
begin
	if trim(p_enunciado)='' then
			raise exception 'Enunciado no puede estar vacio';
	end if;
	--crear la pregunta
	insert into preguntas(id_nivel,tiempos_segundos,enunciado,tipo_pregunta,error_detalle, columnas_pc,columnas_movil)
				values 	 (p_id_nivel,p_tiempos_segundos,p_enunciado,p_tipo_pregunta,'No existen opciones de respuestas para la pregunta',p_columnas,p_columnas);
	--ahora obtener el id de la pregunta creada
	select into p_id_pregunta_creada id_pregunta from preguntas where enunciado = p_enunciado;

	--ahora insertar el detalle de la pregunta en este caso es una imagen para el enunciado y el tiempo para poder verla
	insert into extra_pregunta(id_pregunta, extra, tiempo_enunciado) 
				values 		  (p_id_pregunta_creada,p_url_imagen,p_tiempo_img);
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select * from preguntas p 




-- DROP FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(int4);

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_tiempo_segundo integer, r_columnas_pc integer, r_columnas_movil integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, p.tiempos_segundos,p.columnas_pc, p.columnas_movil  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_pregunta =p_id_pregunta /*and tp.codigo ='SELCIMG'*/ order by p.fecha_creacion desc limit 1;
	end;
$function$
;



-- DROP FUNCTION public.fu_datos_pregunta_selcimg(int4);

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg(p_id_nivel integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_columnas_pc integer, r_columnas_movil integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, p.columnas_pc, p.columnas_movil  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_nivel =p_id_nivel /*and tp.codigo ='SELCIMG'*/ order by p.fecha_creacion desc limit 1 ;
	end;
$function$
;


select * from progreso_preguntas pp 
inner join preguntas p on pp.id_pregunta = p.id_pregunta 



-- DROP FUNCTION public.fu_datos_pregunta_memrzar_id_pregunta(int4);
select * from preguntas p 
select * from fu_datos_pregunta_memrzar_id_pregunta(146)

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_memrzar_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_extra character varying, r_tiempo_respuesta integer, r_tiempo_enunciado integer, 
 r_columnas_pc integer, r_columnas_movil integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, ep.extra, p.tiempos_segundos, ep.tiempo_enunciado, p.columnas_pc, p.columnas_movil   from preguntas p 
		inner join extra_pregunta ep on p.id_pregunta  =ep.id_pregunta  
		where p.id_pregunta =p_id_pregunta order by p.fecha_creacion desc limit 1;
	end;
$function$
;


select * from progreso_secciones ps ;
select * from progreso_preguntas pp ;

select * from progreso_respuestas pr 


--arreglar la funcion que retorna los niveles validos de una seccion que se renderiza en el componente donde se agrega una seccion al formulario 
select * from secciones s ;

select * from FU_numeros_preguntas_validad_seccion(58);
--esta funcion devuelve numeros randoms xd 
-- DROP FUNCTION public.fu_numeros_preguntas_validad_seccion(int4);

CREATE OR REPLACE FUNCTION public.fu_numeros_preguntas_validad_seccion(p_id_seccion integer)
 RETURNS TABLE(r_id_nivel integer, r_id_seccion integer, r_nivel character varying, r_total_preguntas integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select  X.id_nivel_,p_id_seccion ,cast(CONCAT('Nivel ', CAST(X.nivel_ AS VARCHAR)) as varchar(100)),cast(Count(distinct p.id_pregunta)as int) from 
	(select n.nivel as nivel_, n.id_nivel as id_nivel_
	from preguntas pp 
	inner join niveles n ON n.id_nivel = pp.id_nivel 
	where n.id_seccion =p_id_seccion
	group by n.nivel, n.id_nivel order by n.nivel asc) as X 
	inner join preguntas p on X.id_nivel_= p.id_nivel
	inner join respuestas r on p.id_pregunta =r.id_pregunta
	group by X.nivel_, X.id_nivel_;
	--antiguo
	/*
	SELECT
    n.id_nivel,
    n.id_seccion,
    cast(CONCAT('Nivel ', CAST(n.nivel AS VARCHAR)) as varchar(100)) AS nivel,
    cast(COUNT(p.id_nivel)as int) AS total_preguntas
	FROM
    niveles n
	LEFT JOIN
    preguntas p ON n.id_nivel = p.id_nivel
    LEFT join
    respuestas r on p.id_pregunta = r.id_pregunta 
	WHERE
    n.id_seccion = 58
    and r.correcta 
	GROUP BY
    n.id_nivel, n.id_seccion, n.nivel, r.id_pregunta 
	ORDER BY
    n.id_nivel;
   */
end;
$function$
;


select n.nivel, n.id_nivel, (
								select COUNT( distinct p.id_pregunta ) from preguntas p
								inner join respuestas r on p.id_pregunta = r.id_pregunta 
								where p.id_nivel =  pp.id_nivel  and r.correcta ) as numero_pregunta
from preguntas pp 
inner join niveles n ON n.id_nivel = pp.id_nivel 
where n.id_seccion =54
group by n.nivel, n.id_nivel order by n.nivel asc;





select COUNT( distinct p.id_pregunta ) from preguntas p
inner join respuestas r on p.id_pregunta = r.id_pregunta 
where p.id_nivel =  X.id_nivel_  and r.correcta ) as numero_pregunta



select * from secciones s 

--id_nivel, id_seccion, nivel concantenado Nivel + total preguntas 







select * from preguntas p 




select COUNT( distinct p.id_pregunta ) from preguntas p
inner join respuestas r on p.id_pregunta = r.id_pregunta 
where p.id_nivel = 35 and r.correcta ;




select * from secciones s where s.id_seccion =54

select * from test_niveles tn 

select * from test_secciones ts 


--arreglar esta funcion porque sale como completado cuando hay preguntas con multiples respuestas xd 
-- DROP FUNCTION public.fu_tr_reponder_progreso_respuestas();

CREATE OR REPLACE FUNCTION public.fu_tr_reponder_progreso_respuestas()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_id_progreso_seccion int;
	p_completo bool;
	p_porcentaje int;
begin
	--primero obtener el id seccion que es unico para cada participante_test 
	--new.id_progreso_pregunta =5 -->ejemplo
	select into p_id_progreso_seccion pp.id_progreso_seccion  from progreso_preguntas pp where pp.id_progreso_preguntas=new.id_progreso_pregunta;

	--hacer la comparacion para obtener el booleano 
    /*
	select into p_completo case when COUNT(*)>=(select COUNT(*) from progreso_preguntas pp where pp.id_progreso_seccion =p_id_progreso_seccion) then true else false end 
	as Completado
	from progreso_respuestas pr inner join progreso_preguntas pp on pr.id_progreso_pregunta = pp.id_progreso_preguntas 
	where pp.id_progreso_seccion =p_id_progreso_seccion;
	*/
	--obtener el porcentaje 
	SELECT 
  (COUNT(distinct pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = p_id_progreso_seccion), 0) AS PorcentajeCompletado,
  CASE WHEN (COUNT(distinct pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = p_id_progreso_seccion), 0) = 100 THEN true ELSE false END AS Verificado  
INTO 
  p_porcentaje,
  p_completo
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = p_id_progreso_seccion;
  
  	--si el porcentaje es 100 entonces es completado 
  
	--actualizar el registro
	update progreso_secciones set estado_completado=p_completo,porcentaje=p_porcentaje where id_progreso_seccion=p_id_progreso_seccion;

return new;
end
$function$
;
select * from progreso_secciones ps ;
select * from progreso_preguntas pp ;
select * from progreso_respuestas pr ;

select 
  	(COUNT(distinct pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = 36), 0) AS PorcentajeCompletado,
  	case when (COUNT(distinct pr.id_progreso_pregunta) * 100) / NULLIF((SELECT COUNT(*) FROM progreso_preguntas pp WHERE pp.id_progreso_seccion = 36), 0)=100  then true else false end as Verificado  
	FROM
  	progreso_respuestas pr
	INNER JOIN
  	progreso_preguntas pp ON pr.id_progreso_pregunta = pp.id_progreso_preguntas
	WHERE
  	pp.id_progreso_seccion = 36;
  
  
 /*
  * AGREGAR COLUMNAS A LA TABLA DEL PERFIL QUE PERMITAN GUARDAR LA INTERFAZ XD SKERE MODO DIABLO 
  * sidenavColor: "dark",
    sidenavType: "white",
    transparentNavbar: false,
    fixedNavbar: true,
  * */
  
  
 select * from usuario u 
 --crear una tabla que permita guardar los cambios de la interfaz xd 
 CREATE TABLE interfaz_usuario (
    ID_User uuid PRIMARY KEY,
    sidenavColor character varying not null default 'dark',
    sidenavType character varying not null default 'white',
    transparentNavbar bool not null default false,
    fixedNavbar bool not null default true,
    -- Definir la clave foránea
    FOREIGN KEY (ID_User) REFERENCES usuario (ID_User)
);

insert into interfaz_usuario(ID_User)values('3b43792d-ec18-49a5-b8af-753c65cb9b21');
select * from interfaz_usuario


select * from FU_interfaz_usuario('3b43792d-ec18-49a5-b8af-753c65cb9b21');


drop FUNCTION public.FU_interfaz_usuario(p_id_user character varying)

--funcion que retorne las caracteristicas de la interfaz mediante el id del suaurio casteado xd 
CREATE OR REPLACE FUNCTION public.FU_interfaz_usuario(p_id_user character varying)
 RETURNS TABLE(sidenavColor character varying, sidenavType character varying ,transparentNavbar  bool,fixedNavbar bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select iu.sidenavColor,iu.sidenavType, iu.transparentNavbar, iu.fixedNavbar from interfaz_usuario iu where cast(iu.ID_User as character varying) = p_id_user;
end;
$function$
;



select * from secciones s 

select * from niveles n where n.id_seccion =54

select * from preguntas p where p.id_nivel =35


select * from preguntas p where p.id_pregunta = 145 
select * from tipos_preguntas tp where tp.id_tipo_pregunta = 9


select * from claves_preguntas cp where cp.id_pregunta =145
select * from valor_preguntas vp


select * from respuestas r 
inner join valor_preguntas vp on r.id_respuesta =vp.id_respuesta
where r.id_pregunta =145

delete from valor_preguntas where id_respuesta in (424,425,426,427,428,429)
delete from  preguntas  where id_pregunta =145

delete from  extra_pregunta  where id_pregunta =145




-- DROP FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(int4);

CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_tiempo_segundo integer, r_columnas_pc integer, r_columnas_movil integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, p.tiempos_segundos,p.columnas_pc, p.columnas_movil  from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_pregunta =147 /*and tp.codigo ='SELCIMG'*/ order by p.fecha_creacion desc limit 1;
	end;
$function$
;


select * from interfaz_usuario iu 


select * from test t 

select * from secciones s ;


select * from usuario u ;
select * from secciones_usuario su ;




INSERT INTO MovRcfgRutas(CodAgen,CodRuta,CodZona,Descripcion,Estado)VALUES (19,2003,2000,'OLMEDO - CAYAMBE',True); select * fromMovRcfgRutas where CodRuta = 2003;


select * from progreso_respuestas pr ;

select * from test t ;
--124 
select * from participantes_test pt where pt.id_test =124
--102
--103
select * from progreso_secciones ps where id_participante_test = 102;

delete 
--select * 
from niveles n where n.id_seccion =56 and nivel=2;
select * from secciones s ;



--listar las pregutnas de un test 
--select * from test t;


--funccion que retorne todas las preguntas de un test 
CREATE OR REPLACE FUNCTION public.preguntas_de_un_test(p_id_test int)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying)
 LANGUAGE plpgsql
AS $function$
begin
				return query
	select p.id_pregunta,p.enunciado from test_secciones ts 
	inner join secciones s on ts.id_seccion = s.id_seccion 
	inner join niveles n on n.id_seccion = s.id_seccion 
	inner join preguntas p on n.id_nivel = p.id_nivel 
	where ts.id_test =p_id_test
	order by p.id_pregunta asc;	
end;
$function$
;

select * from preguntas_de_un_test(127)




select * from progreso_preguntas pp;
select * from preguntas p;




select  r.opcion, (select Count(*) from participantes_test pt 
inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test  
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
where pt.id_test =127 and pp.id_pregunta=151 and pr.respuesta = r.opcion)   -- contar cuantas hay en respondidas segun el test 
as Num
from preguntas p 
inner join respuestas r on p.id_pregunta =r.id_pregunta
where p.id_pregunta =147
;

select * from progreso_respuestas pr; 





select Count(*) from participantes_test pt 
inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test  
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
where pt.id_test =127 and pp.id_pregunta=151 and pr.respuesta =;


select * from estadistica_por_pregunta(151,127)
--drop FUNCTION public.estadistica_por_pregunta(p_id_pregunta integer, p_id_test integer)


CREATE OR REPLACE FUNCTION public.estadistica_por_pregunta(p_id_pregunta integer, p_id_test integer)
 RETURNS TABLE(r_opcion character varying, cantidad integer)
 LANGUAGE plpgsql
AS $function$
begin
			return query
		select  r.opcion,  cast ((select Count(*) from participantes_test pt 
inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test  
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
where pt.id_test =p_id_test and pp.id_pregunta=p_id_pregunta and pr.respuesta = r.opcion)as int)   -- contar cuantas hay en respondidas segun el test 
as Num
from preguntas p 
inner join respuestas r on p.id_pregunta =r.id_pregunta
where p.id_pregunta =p_id_pregunta
order by r.id_respuesta;
end;
$function$
;


select * from respuestas r 

delete from respuestas where id_respuesta = 573

select * from participantes_test pt ;





select p.id_pregunta , p.id_nivel ,ROW_NUMBER() OVER (ORDER BY p.id_pregunta) AS numero_de_fila, p.enunciado
				--INTO p_id_pregunta_seleccionada , p_id_nivel 
				from preguntas p 
                inner join niveles n on p.id_nivel = n.id_nivel
                inner join secciones s on n.id_seccion = s.id_seccion
                inner join respuestas r on p.id_pregunta =r.id_pregunta 
                where s.id_seccion = 60 and n.nivel = 1 --and r.correcta
                group by p.id_pregunta
                
                
                
  select * from secciones s;
 


/*
 RESPALDO DEL CURSOR QUE TENIA LA BD DEL SERVER 
 
 -- DROP FUNCTION public.fu_cursor_generar_preguntas_participante(varchar, int4);

CREATE OR REPLACE FUNCTION public.fu_cursor_generar_preguntas_participante(p_token_test character varying, p_id_participante_test integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
 	p_id_seccion int;
 	p_id_progreso_seccion int;
 	p_cantidad_niveles int;
 	p_numero_preguntas int;
  	i INT;
    contador INT := 1;
   	p_id_pregunta_seleccionada int;
   	p_id_nivel int;
 	--consulta que devuelve las secciones de un test
    curCopiar cursor for 
    			select ps.id_progreso_seccion, ps.id_seccion,ts.cantidad_niveles,ts.numero_preguntas  from progreso_secciones ps 
				inner join test_secciones ts on ps.id_seccion = ts.id_seccion
				inner join test t on ts.id_test = t.id_test
				where ps.id_participante_test = p_id_participante_test 
				and cast(t.tokens as character varying)= p_token_test;
begin
	--/Antes de Abrir el cursor se pueden declarar cosas, como por ejemplo crear un nuevo registro/
	--
   open curCopiar;
	fetch next from curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	while (Found) loop	
		
		--/[AQUI VA TODO LO QUE SE QUIERE REALIZAR CON EL CURSOR]/
		--
		--p_id_progreso_seccion
		--p_id_seccion
		--p_cantidad_niveles
		--p_numero_preguntas
			
		--un for que recorra los niveles de la tabla de la consulta de arriba
		
		FOR i IN 1..p_cantidad_niveles LOOP
		
			--otro for dentro que recorra las preguntas de esa seccion y de ese nivel
			--Hacer que recora el 
			
			WHILE contador <= p_numero_preguntas LOOP
				
				--de esas preguntas que seleccione una aleatoria dependiendo de la cantidad de "numero_preguntas" a seleccionar
				--DEMANERA ALEATORIA 
				
				select p.id_pregunta , p.id_nivel 
				INTO p_id_pregunta_seleccionada , p_id_nivel from preguntas p 
                inner join niveles n on p.id_nivel = n.id_nivel
                inner join secciones s on n.id_seccion = s.id_seccion
                inner join respuestas r on p.id_pregunta =r.id_pregunta 
                where s.id_seccion = p_id_seccion and n.nivel = i and r.correcta
                ORDER BY random()
				LIMIT 1;  
				
				--DE MANERA SECUENCIAL 
				/*
				select X.IDPRE, X.PNIVEL
				INTO p_id_pregunta_seleccionada , p_id_nivel 
				from 
				(select p.id_pregunta as IDPRE , p.id_nivel as PNIVEL ,ROW_NUMBER() OVER (ORDER BY p.id_pregunta) AS numero_de_fila, p.enunciado
				--INTO p_id_pregunta_seleccionada , p_id_nivel 
				from preguntas p 
				inner join niveles n on p.id_nivel = n.id_nivel
				inner join secciones s on n.id_seccion = s.id_seccion
				inner join respuestas r on p.id_pregunta =r.id_pregunta 
				where s.id_seccion = 60 and n.nivel = 1 --and r.correcta
				group by p.id_pregunta) as X
				where numero_de_fila=contador;
				*/
			
                --Validar si el id_pregunta ya esta ingresado en la tabla progreso_preguntas
				--si la pregunta ya se encuentra registrada, volver a escoger otra pregunta, repetir bucle
				--id_progreso_seccion
				--id_pregunta
				--verificar que las preguntas no se repitan con id	
  
            	-- Validar pregunta repetida
                IF NOT EXISTS (
	                SELECT 1 FROM progreso_preguntas pr 
					inner join progreso_secciones ps on pr.id_progreso_seccion  =  ps.id_progreso_seccion
					inner join preguntas p on pr.id_pregunta = p.id_pregunta 
					WHERE pr.id_pregunta = p_id_pregunta_seleccionada
					AND pr.id_progreso_seccion = p_id_progreso_seccion
					and p.id_nivel = p_id_nivel
					and ps.id_participante_test = p_id_participante_test
                ) THEN

                	--si la pregunta no se encuentra registrada entonces ingresarla a la tabla progreso_preguntas
					--id_progreso_seccion
					--id_pregunta
                    INSERT INTO progreso_preguntas (id_progreso_seccion, id_pregunta)
                    VALUES (p_id_progreso_seccion, p_id_pregunta_seleccionada);
                   	
                   --Incrementar el contador, si se registra la pregunta no esta repetida
                   contador := contador + 1;
                   
                ELSE
                    -- Si la pregunta ya está registrada, no incrementa el contador del bucle

                END IF;
				
			END LOOP;
		contador := 1;
			
		END LOOP;
			
	--cerrar el cursor 
	FETCH NEXT FROM curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	--fetch curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	end loop;
	close curCopiar;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en el cursor: %', SQLERRM;
END;
$function$
;

 **/

--RESPALDO DE INGRESAR PARTICIPANTE 
/*
 -- DROP PROCEDURE public.ingresar_participante_test(varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE PROCEDURE public.ingresar_participante_test(IN p_token_id_participante character varying, IN p_token_id_test character varying, IN p_facultad character varying, IN p_carrera character varying, IN p_semestre character varying)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_ID_Test int;
	p_Id_participante_test int;
begin
	--primero obtener el id test mediante el token para ingresar al usuario al test 
	select into p_ID_Test t.id_test from test t where cast(t.tokens as character varying) = p_token_id_test;
	--ingresar el usuario con ese id test obtenido xd 
	insert into participantes_test(id_participante, id_test) values (cast(p_token_id_participante as UUID), p_ID_Test);
	--obtener el id del registro de la tabla anterior xd 
	select into p_Id_participante_test id_participante_test from participantes_test where cast(id_participante as character varying) =p_token_id_participante and id_test = p_ID_Test;


	insert into Datos_Participante_Test(
						id_participante_test,
						facultad,
						carrera,
						semestre
						)values
						(
						 p_Id_participante_test,
						 p_facultad,
						 p_carrera,
						 cast(p_semestre as int)
						);
	--llamar al cursor para que se encargue de registrar las secciones
	PERFORM FU_Cursor_generar_seccion_participante(p_token_id_test,p_Id_participante_test);
	--llamar al generador de preguntas
	perform FU_Cursor_generar_preguntas_participante(p_token_id_test,p_Id_participante_test);
	
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

 * */
select * from participantes_test pt;
/*
p_carrera: "Software"
p_facultad: "Ciencias de la Ingeniería"
p_semestre: "7"
p_token_id_participante: "9453f1e2-9feb-4f11-b084-591e350714f0"
p_token_id_test: "6628847f-60d2-4eb7-94b3-2aaa56fd28be"
 */
call ingresar_participante_test('9453f1e2-9feb-4f11-b084-591e350714f0','6628847f-60d2-4eb7-94b3-2aaa56fd28be','Ciencias de la Ingeniería','Software','7');
select * from Datos_Participante_Test

-- DROP PROCEDURE public.ingresar_participante_test(varchar, varchar, varchar, varchar, varchar);


CREATE OR REPLACE PROCEDURE public.ingresar_participante_test(IN p_token_id_participante character varying, IN p_token_id_test character varying, IN p_facultad character varying, IN p_carrera character varying, IN p_semestre character varying)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_ID_Test int;
	p_Id_participante_test int;
begin
	--primero obtener el id test mediante el token para ingresar al usuario al test 
	select into p_ID_Test t.id_test from test t where cast(t.tokens as character varying) = p_token_id_test;
	--ingresar el usuario con ese id test obtenido xd 
	insert into participantes_test(id_participante, id_test) values (cast(p_token_id_participante as UUID), p_ID_Test);
	--obtener el id del registro de la tabla anterior xd 
	select into p_Id_participante_test id_participante_test from participantes_test where cast(id_participante as character varying) =p_token_id_participante and id_test = p_ID_Test limit 1;


	insert into Datos_Participante_Test(
						id_participante_test,
						facultad,
						carrera,
						semestre
						)values
						(
						 p_Id_participante_test,
						 p_facultad,
						 p_carrera,
						 cast(p_semestre as int)
						);
	--llamar al cursor para que se encargue de registrar las secciones
	PERFORM FU_Cursor_generar_seccion_participante(p_token_id_test,p_Id_participante_test);
	--llamar al generador de preguntas
	perform FU_Cursor_generar_preguntas_participante(p_token_id_test,p_Id_participante_test);
	
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;
/*
 
 */

-- DROP FUNCTION public.fu_cursor_generar_preguntas_participante(varchar, int4);

CREATE OR REPLACE FUNCTION public.fu_cursor_generar_preguntas_participante(p_token_test character varying, p_id_participante_test integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
 	p_id_seccion int;
 	p_id_progreso_seccion int;
 	p_cantidad_niveles int;
 	p_numero_preguntas int;
  	i INT;
    contador INT := 1;
   	p_id_pregunta_seleccionada int;
   	p_id_nivel int;
 	--consulta que devuelve las secciones de un test
    curCopiar cursor for 
    			select ps.id_progreso_seccion, ps.id_seccion,ts.cantidad_niveles,ts.numero_preguntas  from progreso_secciones ps 
				inner join test_secciones ts on ps.id_seccion = ts.id_seccion
				inner join test t on ts.id_test = t.id_test
				where ps.id_participante_test = p_id_participante_test 
				and cast(t.tokens as character varying)= p_token_test;
begin
	--/Antes de Abrir el cursor se pueden declarar cosas, como por ejemplo crear un nuevo registro/
	--
   open curCopiar;
	fetch next from curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	while (Found) loop	
		
		--/[AQUI VA TODO LO QUE SE QUIERE REALIZAR CON EL CURSOR]/
		--
		--p_id_progreso_seccion
		--p_id_seccion
		--p_cantidad_niveles
		--p_numero_preguntas
			
		--un for que recorra los niveles de la tabla de la consulta de arriba
		
		FOR i IN 1..p_cantidad_niveles LOOP
		
			--otro for dentro que recorra las preguntas de esa seccion y de ese nivel
			--Hacer que recora el 
			
			WHILE contador <= p_numero_preguntas LOOP
				
				--de esas preguntas que seleccione una aleatoria dependiendo de la cantidad de "numero_preguntas" a seleccionar
				select p.id_pregunta , p.id_nivel 
				INTO p_id_pregunta_seleccionada , p_id_nivel from preguntas p 
                inner join niveles n on p.id_nivel = n.id_nivel
                inner join secciones s on n.id_seccion = s.id_seccion
                inner join respuestas r on p.id_pregunta =r.id_pregunta 
                where s.id_seccion = p_id_seccion and n.nivel = i and r.correcta
                ORDER BY random()
				LIMIT 1;
                --Validar si el id_pregunta ya esta ingresado en la tabla progreso_preguntas
				--si la pregunta ya se encuentra registrada, volver a escoger otra pregunta, repetir bucle
				--id_progreso_seccion
				--id_pregunta
				--verificar que las preguntas no se repitan con id	
  
            	-- Validar pregunta repetida
                IF NOT EXISTS (
	                SELECT 1 FROM progreso_preguntas pr 
					inner join progreso_secciones ps on pr.id_progreso_seccion  =  ps.id_progreso_seccion
					inner join preguntas p on pr.id_pregunta = p.id_pregunta 
					WHERE pr.id_pregunta = p_id_pregunta_seleccionada
					AND pr.id_progreso_seccion = p_id_progreso_seccion
					and p.id_nivel = p_id_nivel
					and ps.id_participante_test = p_id_participante_test
                ) THEN

                	--si la pregunta no se encuentra registrada entonces ingresarla a la tabla progreso_preguntas
					--id_progreso_seccion
					--id_pregunta
                    INSERT INTO progreso_preguntas (id_progreso_seccion, id_pregunta)
                    VALUES (p_id_progreso_seccion, p_id_pregunta_seleccionada);
                   	
                   --Incrementar el contador, si se registra la pregunta no esta repetida
                   contador := contador + 1;
                   
                ELSE
                    -- Si la pregunta ya está registrada, no incrementa el contador del bucle

                END IF;
				
			END LOOP;
		contador := 1;
			
		END LOOP;
			
	--cerrar el cursor 
	FETCH NEXT FROM curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	--fetch curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	end loop;
	close curCopiar;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en el cursor: %', SQLERRM;
END;
$function$
;


 --funcion para eliminar un formulario skere modo diablo
--Tablas a eliminar por formulario 
delete from clave_valor_respuesta;
delete from progreso_respuestas; -->
delete from progreso_preguntas; -->
delete from progreso_secciones; -->
delete from datos_participante_test; -->
delete from ingresos; --> 
delete from participantes_test  ; --> 
delete from test_niveles  ;-->
delete from test_secciones  ;-->
delete from errores_test; -->
delete from test; 

select * from test t ;
--call SP_Eliminar_Test(123);

Create or Replace Procedure SP_Eliminar_Test(
										p_id_test integer
										  )
Language 'plpgsql'
AS $$
begin
	--Paso 0
--eliminar con clave valor 
DELETE FROM clave_valor_respuesta where id_registro in (
select clr.id_registro  from participantes_test pt
inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr on pp.id_progreso_preguntas = pr.id_progreso_pregunta 
inner join clave_valor_respuesta clr on pr.id_progreso_respuestas =clr.id_progreso_respuesta 
where pt.id_test =p_id_test);

--Primero eliminar el progreso respuestas 
DELETE FROM progreso_respuestas 
WHERE id_progreso_respuestas IN (
    SELECT pr.id_progreso_respuestas  
    FROM participantes_test pt
    INNER JOIN progreso_secciones ps ON ps.id_participante_test = pt.id_participante_test 
    INNER JOIN progreso_preguntas pp ON ps.id_progreso_seccion = pp.id_progreso_seccion 
    INNER JOIN progreso_respuestas pr ON pp.id_progreso_preguntas = pr.id_progreso_pregunta 
    WHERE pt.id_test = p_id_test
);
--Segundo eliminar el progreso progreso preguntas 
DELETE FROM progreso_preguntas 
WHERE id_progreso_preguntas IN (
    SELECT pp.id_progreso_preguntas  
    FROM participantes_test pt
    INNER JOIN progreso_secciones ps ON ps.id_participante_test = pt.id_participante_test 
    INNER JOIN progreso_preguntas pp ON ps.id_progreso_seccion = pp.id_progreso_seccion 
    WHERE pt.id_test = p_id_test
);
--Tercero eliminar el progreso seccion
DELETE FROM progreso_secciones 
WHERE id_progreso_seccion IN (
    SELECT ps.id_progreso_seccion  
    FROM participantes_test pt
    INNER JOIN progreso_secciones ps ON ps.id_participante_test = pt.id_participante_test 
    WHERE pt.id_test = p_id_test
);
--Cuarto eliminar los datos de los participantes en dicho test 
delete from datos_participante_test where id_participante_test in (
select ptt.id_participante_test  from datos_participante_test ptt
inner join participantes_test pt on ptt.id_participante_test =pt.id_participante_test 
where pt.id_test =p_id_test);
--Quinto eliminar los ingresos
delete from ingresos where id_participante_test in ( 
select  ptt.id_participante_test from ingresos ptt
inner join participantes_test pt on ptt.id_participante_test =pt.id_participante_test 
where pt.id_test =p_id_test);
--Sexto eliminar participantes_test
delete from participantes_test where id_test=p_id_test;
--Septimo eliminar test_niveles
delete from test_niveles where id_test_niveles in (
select tn.id_test_niveles from test_niveles tn
inner join test_secciones ts on tn.id_test_secciones = ts.id_test_secciones 
where ts.id_test =p_id_test);
--Octavo eliminar test_secciones
delete from test_secciones where id_test =p_id_test;
--Noveno errores_test
delete from errores_test where id_test =p_id_test;
--Decimo eliminar el test
delete from test where id_test =p_id_test;
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;




select * from test t;

alter table test 
add column preguntas_aleatorias bool default true not null;

call SP_Eliminar_Pregunta(185);

--funcion para eliminar preguntas xd 
Create or Replace Procedure SP_Eliminar_Pregunta(
										p_id_pregunta integer
										  )
Language 'plpgsql'
AS $$
begin
	
	delete from valor_preguntas where id_valor in (
	select vp.id_valor  from valor_preguntas vp 
	inner join respuestas r on vp.id_respuesta =r.id_respuesta 
	where r.id_pregunta =p_id_pregunta);


	delete from claves_preguntas cp where cp.id_pregunta =p_id_pregunta;
	delete from respuestas r where r.id_pregunta =p_id_pregunta;
	delete from extra_pregunta ep where ep.id_pregunta =p_id_pregunta;
	delete from preguntas p where p.id_pregunta =p_id_pregunta;
		
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;


select * from tipos_preguntas tp ;

--funcion para eliminar una respuesta 



Create or Replace Procedure SP_Eliminar_Respuesta(
										p_id_respuesta integer
										  )
Language 'plpgsql'
AS $$
begin
	
	delete from respuestas r where r.id_respuesta =p_id_respuesta;
	delete  from valor_preguntas vp where vp.id_respuesta =p_id_respuesta;
		
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

--cambiar la restriccion para que solo se cree una pregunta repetida por nivel 
ALTER TABLE public.preguntas ADD CONSTRAINT uq_enunciado UNIQUE (enunciado, id_nivel)

select * from preguntas

--funcion para editar el enunciado de una pregunta de tipo SELCCMA

Create or Replace Procedure SP_Editar_pregunta_SELCCMA(
										p_id_pregunta integer,
										p_enunciado_new character varying
										  )
Language 'plpgsql'
AS $$
begin
	
	update preguntas set enunciado = p_enunciado_new where id_pregunta =p_id_pregunta;
		
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

--funcion para ver el registro de una respuesta 
select * from data_respuesta_id(586);

CREATE OR REPLACE FUNCTION public.data_respuesta_id(p_id_respuesta integer)
 RETURNS TABLE(r_id_respuesta integer, r_id_pregunta integer, r_opcion character varying, r_correcta bool, r_estado bool, r_eliminado bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select r.id_respuesta, r.id_pregunta, r.opcion, r.correcta, r.estado, r.eliminado from respuestas r where r.id_respuesta =p_id_respuesta;
end;
$function$
;

Create or Replace Procedure SP_Editar_respuesta_SELCCMA(
										p_id_respuesta integer,
										p_enunciado_new character varying
										  )
Language 'plpgsql'
AS $$
begin
	
	update respuestas  set opcion =p_enunciado_new  where id_respuesta =p_id_respuesta;
		
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

select * from respuestas


select * from test t 

alter table test 
add column abierta bool default true not null;


--editar la funcion de registrar o crear test para que admita los nuevos parametros 
-- DROP PROCEDURE public.sp_insertar_test(varchar, timestamp, timestamp, varchar, varchar, int4);

CREATE OR REPLACE PROCEDURE public.sp_insertar_test(IN p_titulo character varying, IN p_fecha_hora_cierre timestamp without time zone,
	IN p_fecha_hora_inicio timestamp without time zone, IN p_id_user_crea character varying, IN p_descripcion character varying, 
	IN p_ingresos_permitidos integer, 
	in p_cualquier_entrar bool,
	in p_aleatoria bool)
 LANGUAGE plpgsql
AS $procedure$ 
DECLARE 
    p_id_test int;
BEGIN
    INSERT INTO Test (Titulo, Fecha_hora_cierre, Fecha_hora_inicio, ID_User_crea, Descripcion, Ingresos_Permitidos,preguntas_aleatorias, abierta)
    VALUES (
        p_titulo,
        p_fecha_hora_cierre,
        p_fecha_hora_inicio,
        --cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500))
        cast(p_id_user_crea as uuid),
        p_descripcion,
        p_ingresos_permitidos,
        p_aleatoria,
        p_cualquier_entrar
    );
   
    --SELECT INTO p_id_test id_test FROM test WHERE titulo = p_titulo;

    -- Insertar errores al crear un test 
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene secciones');
    --INSERT INTO errores_test (id_test, error_detalle) VALUES (p_id_test, 'El test no contiene participantes');
    
    
EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM USING HINT = 'Revisa la transacción principal.';
END;
$procedure$
;


CREATE OR REPLACE FUNCTION public.fu_tr_test_insert_error()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin 
	insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene secciones');
if new.abierta = false then 
   insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene participantes');
  end if;
return new;
end
$function$
;

select * from test t 



-- DROP FUNCTION public.fu_lista_participantes_bucar(varchar);

CREATE OR REPLACE FUNCTION public.fu_lista_participantes_bucar(p_palabra_clave character varying)
 RETURNS TABLE(r_id_participante character varying, r_correo_institucional character varying, r_nombres_apellidos character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(id_participante as varchar(500)), correo_institucional, nombres_apellidos
	from participantes p where ((nombres_apellidos ILIKE '%' || p_palabra_clave || '%') or (correo_institucional ILIKE '%' || p_palabra_clave || '%'))
								 and estado
	order by nombres_apellidos asc limit 7;
end;
$function$
;
select * from participantes


-- DROP FUNCTION public.verificacion_participante_test(varchar, varchar);

CREATE OR REPLACE FUNCTION public.verificacion_participante_test(p_id_token_participante character varying, p_id_token_test character varying)
 RETURNS TABLE(r_accion character varying, r_registrado bool, r_abierta bool)
 LANGUAGE plpgsql
AS $function$
declare 
p_id_test int;
begin
	/*
	select case when COUNT(*)>=1 then true else false end as Verification from participantes_test pt inner join test t on pt.id_test =t.id_test
where cast(t.tokens as character varying)=p_id_token_test and cast(pt.id_participante as character varying)=p_id_token_participante ;
*/
	select into p_id_test t.id_test from test t  where cast (t.tokens as character varying) = p_id_token_test; 
	return query
	select case when COUNT(*)<=0 then cast('Registrar' as character varying) else cast('Registrado' as character varying) end as control,
		(select case when COUNT(*)>=1 then true else false end as verification from participantes_test pt where cast(pt.id_participante as character varying) =p_id_token_participante
		and pt.id_test =p_id_test),
	(select abierta  from test t where cast (t.tokens as character varying) = p_id_token_test)
	from datos_participante_test dpt where dpt.id_participante_test= (select pt.id_participante_test from participantes_test pt where cast(pt.id_participante as character varying) =p_id_token_participante
	and pt.id_test =p_id_test limit 1);
end;
$function$
;

--verificar si el test es abierto o cerrado
--id user: 211b8964-d7ae-443b-b4f6-c21c3224513d
--token test: 29bc2f4d-81bb-4f44-8f56-084399c8c4ac
select * from test t 

select * from verificacion_participante_test('211b8964-d7ae-443b-b4f6-c21c3224513d','d8ede920-ab80-4bce-a223-f7b5f7c4e3f7');



select * from participantes_test pt 
--primer verificar si el teste es abierto o cerrado 
--si abierta es falso entonces verificar si el usuario que se esta intentando registrar esta dentro de la lista 
	--si esta dentro entonces verificar si tiene datos y si no tiene datos enviarlo a registrar 
	
--si abierta es verdadero solo enviar a verificar 
	--return query
select case when COUNT(*)>=1 then 'RegistradoAbierto' else 'NoRegistradoAbierto' end as Verification from participantes_test pt inner join test t on pt.id_test =t.id_test
where cast(t.tokens as character varying)='29bc2f4d-81bb-4f44-8f56-084399c8c4ac' and cast(pt.id_participante as character varying)='211b8964-d7ae-443b-b4f6-c21c3224513d' ;
	
-- DROP PROCEDURE public.ingresar_participante_test(varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE PROCEDURE public.ingresar_participante_test(IN p_token_id_participante character varying, IN p_token_id_test character varying, IN p_facultad character varying, IN p_carrera character varying, IN p_semestre character varying)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_ID_Test int;
	p_Id_participante_test int;
	p_ya_registrado bool;
	p_aleatorias bool;
begin
	--primero obtener el id test mediante el token para ingresar al usuario al test 
	select into p_ID_Test t.id_test from test t where cast(t.tokens as character varying) = p_token_id_test;
	
	--Verificar si ya tiene registros en participantes_test, si ya tiene omitir este paso porque puede ser que sea cerrado el test y quiera registrarse
	select into p_ya_registrado case when COUNT (*)>=1 then true else false end as Verficiation from participantes_test where cast(id_participante as character varying) =p_token_id_participante and id_test = p_ID_Test;
	
	if p_ya_registrado = false then 
	--ingresar el usuario con ese id test obtenido xd 
		insert into participantes_test(id_participante, id_test) values (cast(p_token_id_participante as UUID), p_ID_Test);
	end if;
	
	--obtener el id del registro de la tabla anterior xd 
	select into p_Id_participante_test id_participante_test from participantes_test where cast(id_participante as character varying) =p_token_id_participante and id_test = p_ID_Test;


	insert into Datos_Participante_Test(
						id_participante_test,
						facultad,
						carrera,
						semestre
						)values
						(
						 p_Id_participante_test,
						 p_facultad,
						 p_carrera,
						 cast(p_semestre as int)
						);
	--llamar al cursor para que se encargue de registrar las secciones
	PERFORM FU_Cursor_generar_seccion_participante(p_token_id_test,p_Id_participante_test);
	--llamar al generador de preguntas
	select into p_aleatorias t.preguntas_aleatorias  from test t where t.id_test =p_ID_Test;
	perform FU_Cursor_generar_preguntas_participante(p_token_id_test,p_Id_participante_test,p_aleatorias);
	
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;
-- DROP FUNCTION public.fu_cursor_generar_preguntas_participante(varchar, int4);

CREATE OR REPLACE FUNCTION public.fu_cursor_generar_preguntas_participante(p_token_test character varying, p_id_participante_test integer, p_aleatorias bool)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
 	p_id_seccion int;
 	p_id_progreso_seccion int;
 	p_cantidad_niveles int;
 	p_numero_preguntas int;
  	i INT;
    contador INT := 1;
   	p_id_pregunta_seleccionada int;
   	p_id_nivel int;
 	--consulta que devuelve las secciones de un test
    curCopiar cursor for 
    			select ps.id_progreso_seccion, ps.id_seccion,ts.cantidad_niveles,ts.numero_preguntas  from progreso_secciones ps 
				inner join test_secciones ts on ps.id_seccion = ts.id_seccion
				inner join test t on ts.id_test = t.id_test
				where ps.id_participante_test = p_id_participante_test 
				and cast(t.tokens as character varying)= p_token_test;
begin
	--/Antes de Abrir el cursor se pueden declarar cosas, como por ejemplo crear un nuevo registro/
	--
   open curCopiar;
	fetch next from curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	while (Found) loop	
		
		--/[AQUI VA TODO LO QUE SE QUIERE REALIZAR CON EL CURSOR]/
		--
		--p_id_progreso_seccion
		--p_id_seccion
		--p_cantidad_niveles
		--p_numero_preguntas
			
		--un for que recorra los niveles de la tabla de la consulta de arriba
		
		FOR i IN 1..p_cantidad_niveles LOOP
		
			--otro for dentro que recorra las preguntas de esa seccion y de ese nivel
			--Hacer que recora el 
			
			WHILE contador <= p_numero_preguntas LOOP
				
				if p_aleatorias then 
					--DE MANERA ALEATORIA 
					select p.id_pregunta , p.id_nivel 
					INTO p_id_pregunta_seleccionada , p_id_nivel from preguntas p 
                	inner join niveles n on p.id_nivel = n.id_nivel
                	inner join secciones s on n.id_seccion = s.id_seccion
                	inner join respuestas r on p.id_pregunta =r.id_pregunta 
                	where s.id_seccion = p_id_seccion and n.nivel = i and r.correcta
                	ORDER BY random()
					LIMIT 1; 	
				else
					--DE MANERA SECUENCIAL 
					select X.IDPRE, X.PNIVEL
					INTO p_id_pregunta_seleccionada , p_id_nivel 
					from 
					(select p.id_pregunta as IDPRE , p.id_nivel as PNIVEL ,ROW_NUMBER() OVER (ORDER BY p.id_pregunta) AS numero_de_fila, p.enunciado
					--INTO p_id_pregunta_seleccionada , p_id_nivel 
					from preguntas p 
					inner join niveles n on p.id_nivel = n.id_nivel
					inner join secciones s on n.id_seccion = s.id_seccion
					inner join respuestas r on p.id_pregunta =r.id_pregunta 
					where s.id_seccion = 60 and n.nivel = 1 --and r.correcta
					group by p.id_pregunta) as X
					where numero_de_fila=contador;
				end if;
                --Validar si el id_pregunta ya esta ingresado en la tabla progreso_preguntas
				--si la pregunta ya se encuentra registrada, volver a escoger otra pregunta, repetir bucle
				--id_progreso_seccion
				--id_pregunta
				--verificar que las preguntas no se repitan con id	
  
            	-- Validar pregunta repetida
                IF NOT EXISTS (
	                SELECT 1 FROM progreso_preguntas pr 
					inner join progreso_secciones ps on pr.id_progreso_seccion  =  ps.id_progreso_seccion
					inner join preguntas p on pr.id_pregunta = p.id_pregunta 
					WHERE pr.id_pregunta = p_id_pregunta_seleccionada
					AND pr.id_progreso_seccion = p_id_progreso_seccion
					and p.id_nivel = p_id_nivel
					and ps.id_participante_test = p_id_participante_test
                ) THEN

                	--si la pregunta no se encuentra registrada entonces ingresarla a la tabla progreso_preguntas
					--id_progreso_seccion
					--id_pregunta
                    INSERT INTO progreso_preguntas (id_progreso_seccion, id_pregunta)
                    VALUES (p_id_progreso_seccion, p_id_pregunta_seleccionada);
                   	
                   --Incrementar el contador, si se registra la pregunta no esta repetida
                   contador := contador + 1;
                   
                ELSE
                    -- Si la pregunta ya está registrada, no incrementa el contador del bucle

                END IF;
				
			END LOOP;
		contador := 1;
			
		END LOOP;
			
	--cerrar el cursor 
	FETCH NEXT FROM curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	--fetch curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	end loop;
	close curCopiar;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en el cursor: %', SQLERRM;
END;
$function$
;




-- DROP FUNCTION public.fu_tr_test_participantes_delete();

CREATE OR REPLACE FUNCTION public.fu_tr_test_participantes_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_tiene_participantes bool;
	p_tiene_registro bool;
	p_is_abierto bool;
begin
	--obtener si el test es abierto o cerrado 
		select into p_is_abierto t.abierta from test t where t.id_test = old.id_test;
	--primero verificar si tiene participantes activos el test
	 select into p_tiene_participantes case when COunt(*)>0 then true else false end from participantes_test pt 
 	where pt.id_test =old.id_test and estado ;
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =old.id_test and et.error_detalle ='El test no contiene participantes';
			
 	--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
	if p_tiene_participantes then 
		   update errores_test set estado = false where id_test =old.id_test and error_detalle='El test no contiene participantes';
	else 
			if p_is_abierto = false then 
				--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
				if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =old.id_test and error_detalle='El test no contiene participantes';
				else 
					--como no existe registro entonces crearlo 
				insert into errores_test(id_test,error_detalle)values(old.id_test,'El test no contiene participantes');
				end if;
			else 
					 update errores_test set estado = false where id_test =old.id_test and error_detalle='El test no contiene participantes';
			end if;
			
	end if;
   --verificar ele stado del test 
	call SP_Verificar_Estado_error_Test(old.id_test);
return new;
end
$function$
;







-- DROP FUNCTION public.fu_test_usuario(varchar);

CREATE OR REPLACE FUNCTION public.fu_test_usuario(p_user_id character varying)
 RETURNS TABLE(r_id_test integer, r_titulo character varying, r_fecha_incio character varying, r_fecha_fin character varying, r_estado character varying, r_suspendido boolean, r_descripcion character varying, r_ingresos_permitidos integer, r_token character varying, r_error boolean, r_abierta boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select id_test , cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado_detalle, 
	suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), case when (select Count(*) from errores_test er where er.id_test=t.id_test and estado )>=1 then true else false end as error
	, t.abierta
	from test t;
	--where cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;
end;
$function$
;

select * from test;
 
select * from ingresos i ;

alter table ingresos 
add column IP_ingreso varchar(500);

alter table ingresos 
add column User_Agent varchar(500);
select * from participantes_test pt ;
--funcion para registrar un ingreso 
CREATE OR REPLACE PROCEDURE public.registrar_ingreso(
		user_id_token character varying,
		test_id_token character varying,
		ip_ingre character varying,
		user_age character varying
		)
LANGUAGE plpgsql
AS $procedure$
declare 
	p_id_participante int;
Begin
	select into p_id_participante id_participante_test from participantes_test where cast(id_participante as character varying) = user_id_token and id_test= (select id_test from test where cast(tokens as character varying)=test_id_token limit 1);
	insert into ingresos(id_participante_test, ip_ingreso, user_agent) values (
	p_id_participante,ip_ingre,user_age
	);
	
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

SELECT * from test t 

select * from datos_participante_test dpt 

-- DROP FUNCTION public.fu_cursor_generar_preguntas_participante(varchar, int4, bool);

CREATE OR REPLACE FUNCTION public.fu_cursor_generar_preguntas_participante(p_token_test character varying, p_id_participante_test integer, p_aleatorias boolean)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
 	p_id_seccion int;
 	p_id_progreso_seccion int;
 	p_cantidad_niveles int;
 	p_numero_preguntas int;
  	i INT;
    contador INT := 1;
   	p_id_pregunta_seleccionada int;
   	p_id_nivel int;
 	--consulta que devuelve las secciones de un test
    curCopiar cursor for 
    			select ps.id_progreso_seccion, ps.id_seccion,ts.cantidad_niveles,ts.numero_preguntas  from progreso_secciones ps 
				inner join test_secciones ts on ps.id_seccion = ts.id_seccion
				inner join test t on ts.id_test = t.id_test
				where ps.id_participante_test = p_id_participante_test 
				and cast(t.tokens as character varying)= p_token_test;
begin
	--/Antes de Abrir el cursor se pueden declarar cosas, como por ejemplo crear un nuevo registro/
	--
   open curCopiar;
	fetch next from curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	while (Found) loop	
		
		--/[AQUI VA TODO LO QUE SE QUIERE REALIZAR CON EL CURSOR]/
		--
		--p_id_progreso_seccion
		--p_id_seccion
		--p_cantidad_niveles
		--p_numero_preguntas
			
		--un for que recorra los niveles de la tabla de la consulta de arriba
		
		FOR i IN 1..p_cantidad_niveles LOOP
		
			--otro for dentro que recorra las preguntas de esa seccion y de ese nivel
			--Hacer que recora el 
			
			WHILE contador <= p_numero_preguntas LOOP
				/*
				if p_aleatorias then 
					--DE MANERA ALEATORIA 
					select p.id_pregunta , p.id_nivel 
					INTO p_id_pregunta_seleccionada , p_id_nivel from preguntas p 
                	inner join niveles n on p.id_nivel = n.id_nivel
                	inner join secciones s on n.id_seccion = s.id_seccion
                	inner join respuestas r on p.id_pregunta =r.id_pregunta 
                	where s.id_seccion = p_id_seccion and n.nivel = i and r.correcta
                	ORDER BY random()
					LIMIT 1; 	
				else
					--DE MANERA SECUENCIAL 
					select X.IDPRE, X.PNIVEL
					INTO p_id_pregunta_seleccionada , p_id_nivel 
					from 
					(select p.id_pregunta as IDPRE , p.id_nivel as PNIVEL ,ROW_NUMBER() OVER (ORDER BY p.id_pregunta) AS numero_de_fila, p.enunciado
					--INTO p_id_pregunta_seleccionada , p_id_nivel 
					from preguntas p 
					inner join niveles n on p.id_nivel = n.id_nivel
					inner join secciones s on n.id_seccion = s.id_seccion
					inner join respuestas r on p.id_pregunta =r.id_pregunta 
					where s.id_seccion = p_id_seccion and n.nivel = i --and r.correcta
					group by p.id_pregunta) as X
					where numero_de_fila=contador;
				end if;
				*/
				--DE MANERA SECUENCIAL 
					select X.IDPRE, X.PNIVEL
					INTO p_id_pregunta_seleccionada , p_id_nivel 
					from 
					(select p.id_pregunta as IDPRE , p.id_nivel as PNIVEL ,ROW_NUMBER() OVER (ORDER BY p.id_pregunta) AS numero_de_fila, p.enunciado
					--INTO p_id_pregunta_seleccionada , p_id_nivel 
					from preguntas p 
					inner join niveles n on p.id_nivel = n.id_nivel
					inner join secciones s on n.id_seccion = s.id_seccion
					inner join respuestas r on p.id_pregunta =r.id_pregunta 
					where s.id_seccion = p_id_seccion and n.nivel = i --and r.correcta
					group by p.id_pregunta) as X
					where numero_de_fila=contador;
                --Validar si el id_pregunta ya esta ingresado en la tabla progreso_preguntas
				--si la pregunta ya se encuentra registrada, volver a escoger otra pregunta, repetir bucle
				--id_progreso_seccion
				--id_pregunta
				--verificar que las preguntas no se repitan con id	
  
            	-- Validar pregunta repetida
                IF NOT EXISTS (
	                SELECT 1 FROM progreso_preguntas pr 
					inner join progreso_secciones ps on pr.id_progreso_seccion  =  ps.id_progreso_seccion
					inner join preguntas p on pr.id_pregunta = p.id_pregunta 
					WHERE pr.id_pregunta = p_id_pregunta_seleccionada
					AND pr.id_progreso_seccion = p_id_progreso_seccion
					and p.id_nivel = p_id_nivel
					and ps.id_participante_test = p_id_participante_test
                ) THEN

                	--si la pregunta no se encuentra registrada entonces ingresarla a la tabla progreso_preguntas
					--id_progreso_seccion
					--id_pregunta
                    INSERT INTO progreso_preguntas (id_progreso_seccion, id_pregunta)
                    VALUES (p_id_progreso_seccion, p_id_pregunta_seleccionada);
                   	
                   --Incrementar el contador, si se registra la pregunta no esta repetida
                   contador := contador + 1;
                   
                ELSE
                    -- Si la pregunta ya está registrada, no incrementa el contador del bucle

                END IF;
				
			END LOOP;
		contador := 1;
			
		END LOOP;
			
	--cerrar el cursor 
	FETCH NEXT FROM curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	--fetch curCopiar INTO p_id_progreso_seccion, p_id_seccion, p_cantidad_niveles, p_numero_preguntas;
	end loop;
	close curCopiar;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en el cursor: %', SQLERRM;
END;
$function$
;


select p.id_pregunta as IDPRE , p.id_nivel as PNIVEL ,ROW_NUMBER() OVER (ORDER BY p.id_pregunta) AS numero_de_fila, p.enunciado
					--INTO p_id_pregunta_seleccionada , p_id_nivel 
					from preguntas p 
					inner join niveles n on p.id_nivel = n.id_nivel
					inner join secciones s on n.id_seccion = s.id_seccion
					inner join respuestas r on p.id_pregunta =r.id_pregunta 
					where s.id_seccion = 60 and n.nivel = 1 --and r.correcta
					group by p.id_pregunta
					
select * from test_secciones ts where ts.id_test =132;
select * from test t 

select * from progreso_preguntas pp inner join preguntas p on pp.id_pregunta = p.id_pregunta;




-- DROP FUNCTION public.fu_lista_preguntas_faltan_resolver(varchar, varchar, int4);

CREATE OR REPLACE FUNCTION public.fu_lista_preguntas_faltan_resolver(p_id_participante character varying, p_tokens character varying, p_id_seccion integer)
 RETURNS TABLE(r_id_progreso_preguntas integer, r_id_pregunta integer, r_nivel integer, r_codigo character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select  pp.id_progreso_preguntas , pp.id_pregunta ,n.nivel , tp.codigo 
	from participantes_test pt 
		inner join test t on pt.id_test =t.id_test 
		inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test 
		inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion
		inner join preguntas p on pp.id_pregunta = p.id_pregunta 
		inner join niveles n on p.id_nivel =n.id_nivel 
		inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
		--hacer que con el left join, para que solo me muestre las preguntas que no estan registradas en la tabla progreso_respuestas
		left join progreso_respuestas pr on pp.id_progreso_preguntas  = pr.id_progreso_pregunta 
	where cast(pt.id_participante as character varying)= p_id_participante 
	and cast(t.tokens as character varying) =p_tokens
	and ps.id_seccion =p_id_seccion --el id seccion tambien es parametro
	and pr.id_progreso_pregunta is null
	order by n.nivel
	, p.id_pregunta
	asc;

end;
$function$
;

select * from participantes_test pt 
select * from test t 
select * from progreso_secciones;
select * from fu_lista_preguntas_faltan_resolver('9453f1e2-9feb-4f11-b084-591e350714f0','d8ede920-ab80-4bce-a223-f7b5f7c4e3f7',60);



--funcion para ver los ingresos de un participante 
drop function FU_Ingresos_participantes(p_id_participante integer)

create or replace function FU_Ingresos_participantes(p_id_participante integer)
returns table
(
	r_id_ingreso integer, r_fecha_ingreso varchar(50), r_ip_ingreso varchar(50), r_dispositivo varchar(500), r_hora_ingreso varchar(500)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select i.id_ingreso , cast(to_char(i.fecha_ingreso ,'DD-MON-YYYY')as varchar(500)), i.ip_ingreso , i.user_agent,
	cast(TO_CHAR(i.fecha_ingreso, 'HH24:MI:SS')as varchar(500))
	from ingresos i where i.id_participante_test =p_id_participante
	order by i.fecha_ingreso asc;
end;
$BODY$

select * from FU_Ingresos_participantes(142);

	select i.id_ingreso ,i.fecha_ingreso , i.ip_ingreso , i.user_agent  from ingresos i where i.id_participante_test =136;




create or replace function FU_Progreso_usuario_monitoreo(p_id_participante integer, p_id_progreso_seccion integer)
returns table
(
	r_id_progreso_pregunta integer, r_enunciado varchar(500), r_respuesta varchar(500), r_tiempo_respuesta int
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select pp.id_progreso_preguntas, p.enunciado ,cast(COALESCE(pr.respuesta, '::N/A')as varchar(500)),pr.tiempo_respuesta  from progreso_secciones ps 
	inner join progreso_preguntas pp on ps.id_progreso_seccion = pp.id_progreso_seccion  
	left join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
	inner join preguntas p on pp.id_pregunta =p.id_pregunta 
	where ps.id_participante_test =p_id_participante and ps.id_progreso_seccion =p_id_progreso_seccion
	order by id_progreso_preguntas;
end;
$BODY$

select pp.id_progreso_preguntas, p.enunciado ,cast(COALESCE(pr.respuesta, '::N/A')as varchar(500)) ,pr.tiempo_respuesta  from progreso_secciones ps 
	inner join progreso_preguntas pp on ps.id_progreso_seccion = pp.id_progreso_seccion  
	left join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
	inner join preguntas p on pp.id_pregunta =p.id_pregunta 
	where ps.id_participante_test =139 and ps.id_progreso_seccion =79
	order by id_progreso_preguntas;
	

select * from FU_Progreso_usuario_monitoreo(139,79);
select * from FU_Progreso_seccion_usuario_monitoreo(139);

--funcion para ver las secciones de un usuario para ver su progreso skere modo diablo


create or replace function FU_Progreso_seccion_usuario_monitoreo(p_id_participante integer)
returns table
(
	r_id_progreso_seccion integer, r_id_seccion int, r_descripcion varchar(500), r_titulo varchar(500)
)
language 'plpgsql'
as
$BODY$
begin
	return query
	select ps.id_progreso_seccion , s.id_seccion , s.descripcion , s.titulo  from progreso_secciones ps 
	inner join secciones s on ps.id_seccion=s.id_seccion 
	where ps.id_participante_test =p_id_participante;
end;
$BODY$



--procedimiento para expulsar un usuario de un test, es decir, eliminarlo 
Create or Replace Procedure SP_Eliminar_o_expulsar_participante_test(
										p_id_particpante_test integer
										  )
Language 'plpgsql'
AS $$
begin
	--eliminar o expulsa participante del test 
--primero eliminar el progreso claves respuestas 
DELETE FROM clave_valor_respuesta 
WHERE id_registro IN (
   	select clv.id_registro  from participantes_test pt 
	inner join progreso_secciones ps on pt.id_participante_test = ps.id_participante_test 
	inner join progreso_preguntas pp on ps.id_progreso_seccion = pp.id_progreso_seccion
	inner join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
	inner join clave_valor_respuesta clv on pr.id_progreso_respuestas =clv.id_progreso_respuesta  
	where pt.id_participante_test =p_id_particpante_test
);
--segundo eliminar el progreso respuestas 
DELETE FROM progreso_respuestas 
WHERE id_progreso_respuestas IN (
   	select pr.id_progreso_respuestas  from participantes_test pt 
	inner join progreso_secciones ps on pt.id_participante_test = ps.id_participante_test 
	inner join progreso_preguntas pp on ps.id_progreso_seccion = pp.id_progreso_seccion
	inner join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
	where pt.id_participante_test =p_id_particpante_test
);
--segundo eliminar el progreso pregunta 
DELETE FROM progreso_preguntas 
WHERE id_progreso_preguntas IN (
   	select pp.id_progreso_preguntas  from participantes_test pt 
	inner join progreso_secciones ps on pt.id_participante_test = ps.id_participante_test 
	inner join progreso_preguntas pp on ps.id_progreso_seccion = pp.id_progreso_seccion
	where pt.id_participante_test =p_id_particpante_test
);
--tercero eliminar el progreso secciones 
DELETE FROM progreso_secciones 
WHERE id_progreso_seccion IN (
   	select ps.id_progreso_seccion  from participantes_test pt 
	inner join progreso_secciones ps on pt.id_participante_test = ps.id_participante_test 
	where pt.id_participante_test =p_id_particpante_test
);
--eliinar los ingresos
Delete from ingresos  where id_participante_test =p_id_particpante_test;
--quinto eliminar los datos del participante 
Delete from datos_participante_test  where id_participante_test =p_id_particpante_test;
--eliminar de la tabla participante test 
delete from participantes_test  where id_participante_test =p_id_particpante_test;
	
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;


select * from usuario u;
select * from interfaz_usuario iu;

--trigger para crear la interfaz de usuario despues de crear el usuario xd 
-- DROP FUNCTION public.fu_tr_insert_usuario();

CREATE OR REPLACE FUNCTION public.fu_tr_insert_usuario_interfaz()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
		--
		insert into interfaz_usuario(id_user, sidenavcolor, sidenavtype, transparentnavbar, fixednavbar)
		values (new.id_user,'orange','dark',false,true);
return new;
end
$function$
;

create trigger tr_insert_usuario_inter after
insert
    on
    public.usuario for each row execute function fu_tr_insert_usuario_interfaz()
    
  select * from usuario u ;
 delete from usuario where identificacion in ('0928904440','1234654345');
 
call public.crear_usuario(
		'123456',
		'dparra@uteq.edu.ec',
		'1234567892',
		'DANIEL ALBERTO PARRA GAVILANES',
		'1234567982',
		'Cedula'
		)


CREATE OR REPLACE FUNCTION public.fu_progreso_secciones_tokens(p_id_toke_particiapnta character varying, p_id_token_test character varying)
 RETURNS TABLE(r_id_progreso_seccion integer, r_id_seccion integer, r_id_participante_test integer, r_estado_completado boolean, r_bloqueado boolean, r_porcentaje numeric, r_titulo_seccion character varying, r_descripcion_seccion character varying)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select ps.id_progreso_seccion ,ps.id_seccion ,ps.id_participante_test ,
		ps.estado_completado ,ps.bloqueado, ps.porcentaje, s.titulo, s.descripcion
	from test t 
	inner join participantes_test pt on t.id_test =pt.id_test 
	inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test
	inner join secciones s on ps.id_seccion = s.id_seccion
	where cast(t.tokens as character varying)=p_id_token_test
	and cast(pt.id_participante as character varying)=p_id_toke_particiapnta;
end;
$function$
;

--drop function FU_Progreso_seccion_usuario_monitoreo(p_id_participante integer)

create or replace function FU_Progreso_seccion_usuario_monitoreo(p_id_participante integer)
returns table
(
	r_id_progreso_seccion integer, r_id_seccion int, r_descripcion varchar(500), r_titulo varchar(500),
	r_id_participante_test integer, r_estado_completado bool, r_bloqueado bool, porcentaje decimal
)
language 'plpgsql'
as
$BODY$
begin
	return query
	/*select ps.id_progreso_seccion , s.id_seccion , s.descripcion , s.titulo  from progreso_secciones ps 
	inner join secciones s on ps.id_seccion=s.id_seccion 
	where ps.id_participante_test =p_id_participante;*/

	select ps.id_progreso_seccion ,ps.id_seccion ,s.descripcion, s.titulo
		,ps.id_participante_test ,
		ps.estado_completado ,ps.bloqueado, ps.porcentaje
	from test t 
	inner join participantes_test pt on t.id_test =pt.id_test 
	inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test
	inner join secciones s on ps.id_seccion = s.id_seccion
	where pt.id_participante_test =p_id_participante;
	--where cast(t.tokens as character varying)=p_id_token_test
	--and cast(pt.id_participante as character varying)=p_id_toke_particiapnta;
end;
$BODY$

select * from FU_Progreso_seccion_usuario_monitoreo(147)
select * from participantes_test pt ;




CREATE OR REPLACE FUNCTION public.secciones_test_id(p_id_test integer)
 RETURNS TABLE(r_id_test_secciones integer, r_estad_test_seccion boolean, r_cantidad_niveles integer, r_id_seccion integer, r_descripcion character varying, r_titulo character varying, r_estado_seccion boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select ts.id_test_secciones,ts.estado ,ts.cantidad_niveles ,s.id_seccion ,s.descripcion ,s.titulo ,s.estado 
	from test_secciones ts 
	inner join secciones s on ts.id_seccion = s.id_seccion 	
	where ts.id_test =131--p_id_test;
end;
$function$
;

select * from test t ;

---funcoin para ver si a un test se le puede agregar mas secciones o eliminarlas si esque no tiene test_participantes

CREATE OR REPLACE FUNCTION public.FU_IS_EDITABLE_TEST(p_id_test integer)
 RETURNS TABLE(r_is_editable boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select case when COUNT(*)=0 then true else false end as Editable from participantes_test pt where pt.id_test =p_id_test;
end;
$function$
;


select * from FU_IS_EDITABLE_TEST(131);


select 
--pt.id_participante_test, 
    cast(DENSE_RANK() OVER (ORDER by p.nombres_apellidos)as varchar(500)) AS Participante,
p.nombres_apellidos  ,p.correo_institucional,
s.Titulo,
    cast(ROW_NUMBER() OVER (PARTITION BY pt.id_participante_test ORDER BY p.nombres_apellidos, p2.id_pregunta)as varchar(500)) AS Numero_Pregunta
,p2.enunciado,
cast(COALESCE(pr.respuesta, '::N/A')as varchar(500)) as Respuesta,
cast(COALESCE(pr.tiempo_respuesta,0)as varchar(500)) as Tiempo_Respuesta
from participantes_test pt 
inner join participantes p on pt.id_participante =p.id_participante
inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
left join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
inner join preguntas p2 on pp.id_pregunta =p2.id_pregunta 
inner join secciones s on ps.id_seccion=s.id_seccion
where id_test =132
order by p.nombres_apellidos,p2.id_pregunta;

--funcion para imprimir un excel con los resultados de un test skere modo diablo
select * from FU_Generate_Excel(132);
--DROP FUNCTION public.FU_Generate_Excel(p_id_test integer)

CREATE OR REPLACE FUNCTION public.FU_Generate_Excel(p_id_test integer)
 RETURNS TABLE(
 	r_numero_participante character varying, r_nombres_apellidos character varying, r_correo_institucional character varying,
 	r_seccion character varying
 	,r_numero_pregunta character varying, r_enunciado character varying,r_respuesta character varying, r_tiempo_respuesta character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
		select * from 
		((select 'Numero_Participante','Nombres y Apellidos','Correo_Institucional','Seccion','Numero_Pregunta','Enunciado','Respuesta','Tiempo_Respuesta')
		union all
		(select 
--pt.id_participante_test, 
    cast(DENSE_RANK() OVER (ORDER by p.nombres_apellidos)as varchar(500)) AS Participante,
p.nombres_apellidos  ,p.correo_institucional,
s.Titulo as Seccion,
    cast(ROW_NUMBER() OVER (PARTITION BY pt.id_participante_test ORDER BY p.nombres_apellidos, p2.id_pregunta)as varchar(500)) AS Numero_Pregunta
,p2.enunciado,
cast(COALESCE(pr.respuesta, '::N/A')as varchar(500)) as Respuesta,
cast(COALESCE(pr.tiempo_respuesta,0)as varchar(500)) as Tiempo_Respuesta
from participantes_test pt 
inner join participantes p on pt.id_participante =p.id_participante
inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
left join progreso_respuestas pr on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
inner join preguntas p2 on pp.id_pregunta =p2.id_pregunta 
inner join secciones s on ps.id_seccion=s.id_seccion
where id_test =p_id_test
order by p.nombres_apellidos,p2.id_pregunta))as X;
end;
$function$
;


--funcion para ver el progreso general de un usuario skere 
select * from test t ;

--Progreso de Cada seccion de cada User
select p.nombres_apellidos,p.correo_institucional, s.titulo,ps.porcentaje   from participantes_test pt 
inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test
inner join participantes p on pt.id_participante =p.id_participante 
inner join secciones s on ps.id_seccion = s.id_seccion 
where pt.id_test =137;



select p.nombres_apellidos,p.correo_institucional, ROUND(SUM(ps.porcentaje) / (SELECT COUNT(*) FROM test_secciones ts WHERE ts.id_test = 137)::numeric, 2) AS ProgresoGeneral   from participantes_test pt 
inner join progreso_secciones ps on pt.id_participante_test =ps.id_participante_test
inner join participantes p on pt.id_participante =p.id_participante 
inner join secciones s on ps.id_seccion = s.id_seccion 
where pt.id_test =137
group by p.nombres_apellidos,p.correo_institucional
;



--TODO EN UN JSON
SELECT json_agg(participante) AS resultados
FROM (
    SELECT p.nombres_apellidos AS Nombre, p.correo_institucional AS Correo, 
           ROUND(SUM(ps.porcentaje) / (SELECT COUNT(*) FROM test_secciones ts WHERE ts.id_test = 137)::numeric, 2) AS Porcentaje,
           json_agg(json_build_object('Nombre', s.titulo, 'Porcentaje', ps.porcentaje)) AS Progresos
    FROM participantes_test pt 
    INNER JOIN progreso_secciones ps ON pt.id_participante_test = ps.id_participante_test
    INNER JOIN participantes p ON pt.id_participante = p.id_participante 
    INNER JOIN secciones s ON ps.id_seccion = s.id_seccion 
    WHERE pt.id_test = 137
    GROUP BY p.nombres_apellidos, p.correo_institucional
) participante;


SELECT json_agg(participante) AS resultados
FROM (
    SELECT p.nombres_apellidos AS Nombre, p.correo_institucional AS Correo, 
           ROUND(SUM(ps.porcentaje) / (SELECT COUNT(*) FROM test_secciones ts WHERE ts.id_test = 132)::numeric, 2) AS Porcentaje,
           json_agg(json_build_object('Nombre', s.titulo, 'Porcentaje', ps.porcentaje)) AS Progresos
    FROM participantes_test pt 
    INNER JOIN progreso_secciones ps ON pt.id_participante_test = ps.id_participante_test
    INNER JOIN participantes p ON pt.id_participante = p.id_participante 
    INNER JOIN secciones s ON ps.id_seccion = s.id_seccion 
    WHERE pt.id_test = 132
    GROUP BY p.nombres_apellidos, p.correo_institucional
    order by p.nombres_apellidos
) participante;


select * from obtener_progreso_participantes(132);
--funcion para devolver el JSON 
CREATE OR REPLACE FUNCTION obtener_progreso_participantes(test_id integer )
RETURNS json AS
$$
DECLARE
    resultado json;
BEGIN
    SELECT json_agg(participante) INTO resultado
    FROM (
        SELECT p.nombres_apellidos AS Nombre, p.correo_institucional AS Correo, 
               ROUND(SUM(ps.porcentaje) / (SELECT COUNT(*) FROM test_secciones ts WHERE ts.id_test = test_id)::numeric, 2) AS Porcentaje,
               json_agg(json_build_object('Nombre', s.titulo, 'Porcentaje', ps.porcentaje)) AS Progresos
        FROM participantes_test pt 
        INNER JOIN progreso_secciones ps ON pt.id_participante_test = ps.id_participante_test
        INNER JOIN participantes p ON pt.id_participante = p.id_participante 
        INNER JOIN secciones s ON ps.id_seccion = s.id_seccion 
        WHERE pt.id_test = test_id
        GROUP BY p.nombres_apellidos, p.correo_institucional
        order by p.nombres_apellidos
    ) participante;

    RETURN resultado;
END;
$$
LANGUAGE plpgsql;



--Retornar tambien los parametros de las plantillas, es decir si tiene tiempo enunciado, tiempo respuesta.
-- DROP FUNCTION public.fu_plantilla_preguntas_id_maestro(p_id_maestro character varying);

CREATE OR REPLACE FUNCTION public.fu_plantilla_preguntas_id_maestro(p_id_maestro character varying)
 RETURNS TABLE(r_id_tipo_pregunta integer, r_titulo character varying, r_descripcion character varying, 
 r_icono character varying, r_codigo character varying,
 r_enunciado_img bool, r_opciones_img bool, r_tiempo_enunciado bool, r_tiempo_respuesta bool, r_opcion_multiple bool
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_tipo_pregunta, p.titulo, p.descripcion,p.icono,p.codigo,
	p.enunciado_img, p.opciones_img, p.tiempo_enunciado,p.tiempo_respuesta, p.opcion_multiple
	from tipos_preguntas p ;
	--where p.tipo_pregunta_maestra = cast(p_id_maestro as int) and p.estado;
end;
$function$
;


select * from tipos_preguntas
		select p.id_tipo_pregunta, p.titulo, p.descripcion,p.icono,p.codigo,
	p.enunciado_img, p.opciones_img, p.tiempo_enunciado, p.tiempo_respuesta
	from tipos_preguntas p 
	
--agregar campo a la tabla tipos preguntas para saber si una pregunta tiene tiempo para resolverse 
alter table tipos_preguntas 
add column tiempo_respuesta bool not null default true;	

update tipos_preguntas set tiempo_respuesta= true 
where codigo not in (
'SELCCMA' )


--drop function fu_datos_pregunta_selcimg_id_pregunta()
---Editar la funcion para que retorne los datos para todas las preguntas xd 
CREATE OR REPLACE FUNCTION public.fu_datos_pregunta_selcimg_id_pregunta(p_id_pregunta integer)
 RETURNS TABLE(r_id_pregunta integer, r_enunciado character varying, r_tiempo_segundo integer, r_columnas_pc integer, r_columnas_movil integer,
 r_tiempo_enunciado integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.id_pregunta, p.enunciado, p.tiempos_segundos,coalesce(p.columnas_pc,0) , coalesce(p.columnas_movil,0) ,
			coalesce ((select ep.tiempo_enunciado from extra_pregunta ep where ep.id_pregunta=p.id_pregunta),0) TiempoEnunciado
	from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
		where p.id_pregunta =p_id_pregunta /*and tp.codigo ='SELCIMG'*/ order by p.fecha_creacion desc limit 1;
	end;
$function$
;
--anadir el extra pregunta para saber el tiempo de resupuesta
	select p.id_pregunta, p.enunciado, p.tiempos_segundos,coalesce(p.columnas_pc,0) , coalesce(p.columnas_movil,0) ,
			coalesce ((select ep.tiempo_enunciado from extra_pregunta ep where ep.id_pregunta=p.id_pregunta),0) TiempoEnunciado
	from preguntas p  
		inner join tipos_preguntas tp on p.tipo_pregunta = tp.id_tipo_pregunta
	
		
	select * from extra_pregunta ep 
	
	
--hacer una funcion que edite todos los prametros de un enunciado:
	--Tiempo respuesta si lo tiene, 
	--Tiempo enunciado si lo tiene,
	--Enunciado  obviamente
CREATE OR REPLACE procedure editar_parametros_preguntas(
IN p_id_pregunta integer, 
IN p_enunciado_new character varying,
in tiene_tiempo_resp bool,
in tiempo_responder integer,
in tiene_tiempo_ver bool,
in tiempo_ver integer
)
 LANGUAGE plpgsql
AS $procedure$
begin
	--enunciado de ley tiene skere 
	update preguntas set enunciado = p_enunciado_new where id_pregunta =p_id_pregunta;
--preguntar si tiene tiempo para responder?
if tiene_tiempo_resp then 
	--select * from preguntas
update preguntas set tiempos_segundos = tiempo_responder where id_pregunta =p_id_pregunta;
end if;
--preguntar si tiene tiempo para ver el enunciado
if tiene_tiempo_ver then 
	--select * from extra_pregunta
update extra_pregunta set tiempo_enunciado = tiempo_ver where id_pregunta =p_id_pregunta;
end if;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;
	

select * from progreso_preguntas pp 
inner join progreso_secciones ps on pp.id_progreso_seccion =ps.id_progreso_seccion 
inner join participantes_test pt on ps.id_participante_test =pt.id_participante_test 
where pt.id_test = 139


update progreso_preguntas  set id_pregunta = 83
where id_progreso_preguntas = 1032


select * from extra_pregunta ep where ep.id_pregunta =83
select * from test t 


--funcion para cambiar la imagene de una pregunta skere modo diablo 
-- DROP PROCEDURE public.sp_crear_pregunta_memrzar(varchar, int4, int4, int4, varchar, int4);

CREATE OR REPLACE PROCEDURE public.actualizar_imagen_pregunta(
 IN p_url_imagen character varying, IN p_id_pregunta_creada integer)
 LANGUAGE plpgsql
AS $procedure$
begin
	update extra_pregunta set extra=p_url_imagen where id_pregunta=p_id_pregunta_creada;
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;


select * from extra_pregunta where id_pregunta =83;

select * from preguntas p where id_pregunta =83




select * from respuestas r 

--SP para editar respuesta y actualizarla
select * from respuestas r 


CREATE OR REPLACE PROCEDURE public.actualizar_respuesta(
 IN p_url_imagen character varying, IN p_id_respuesta integer, in _correcta bool)
 LANGUAGE plpgsql
AS $procedure$
begin
	update respuestas set opcion=p_url_imagen--,  correcta=_correcta 
where id_respuesta=p_id_respuesta;
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

--cambiar el estado de una respuesta es decir que sea correcta o incorrecta 
CREATE OR REPLACE PROCEDURE public.actualizar_respuesta_correcta(
  IN p_id_respuesta integer, in _correcta bool)
 LANGUAGE plpgsql
AS $procedure$
begin
	update respuestas set correcta=_correcta 
where id_respuesta=p_id_respuesta;
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;



select * from tipos_preguntas tp 

---disparador para controlar el numero de opciones correctas dependiendo del tipo de pregunta 
-- DROP FUNCTION public.fu_tr_anadir_respuesta();

CREATE OR REPLACE FUNCTION public.fu_tr_anadir_respuesta()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;
		
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta


	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas = false  then 
		/*
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		else 
		*/
			update preguntas set error = true, error_detalle ='Esta pregunta no contiene opcion(es) correta(s)' where id_pregunta =new.id_pregunta;
		end if;
		--else if si no contiene correctas entonces actualizar el registro de preguntas bool error = true y detalle 'esta pregunta no contiende opcion(es) correta(s)'
		if new.correcta then
			update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
		end if;
		--if si la opcion es marcada como correcta acualizar el registro de preguntas bool error= false 
	--anadir el else para las preguntas multiples 
	else 
		--primero preguntar si tiene mas de 2 preguntas como correctas ya que esa es la condicion para que sea multiple 
		select into contiene_correctas case when count(*) >1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
			if contiene_correctas then 
				--como contiene mas de 2 correctas entonces la pregunta esta correcta 
				update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
			else 
				-- como no contiene mas de 2 correctas entonces colocar el error que indique que faltan respuestas correctas
				update preguntas set error = true, error_detalle ='Esta pregunta no contiene más de 2 respuestas correctas' where id_pregunta =new.id_pregunta;

			end if;
end if;
return new;
end
$function$
;



create trigger tr_editar_respuesta_after after
update
    on
    public.respuestas for each row execute function fu_tr_anadir_respuesta()

    
    
    
    create trigger tr_editar_respuesta_before before
update
    on
    public.respuestas for each row execute function fu_tr_anadir_respuesta_before()

-- DROP FUNCTION public.fu_tr_anadir_respuesta_before();

    
CREATE OR REPLACE FUNCTION public.fu_tr_anadir_respuesta_before()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;	
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta
	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas then 
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		end if;
end if;
return new;
end
$function$
;

--restringir las funciones de las estadisiticas si el test no contiene registros de haberse resuelto por lo menos por un particpante \
-- DROP FUNCTION public.fu_detalle_test_id(int4);

CREATE OR REPLACE FUNCTION public.fu_detalle_test_id(p_id_test integer)
 RETURNS TABLE(r_titulo character varying, r_titulo_completo character varying, r_fecha_incio character varying, r_fecha_fin character varying, r_estado character varying, r_suspendido boolean, r_descripcion character varying, r_ingresos_permitidos integer, r_token character varying, r_error boolean, r_numero_secciones integer,
 r_numero_participantes integer, r_preguntas_aleatorias boolean, r_abierta boolean, r_tiene_progreso bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	--anadir el numero de secciones que tiene ese test 
	--anadir el numero de participantes que tiene el test
	select cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	titulo,
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado_detalle, 
	suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), 
	case when (select Count(*) from errores_test er where er.id_test=p_id_test and estado )>=1 then true else false end as error,
	(select cast(COUNT(*)as int) from test_secciones ts where ts.estado and ts.id_test=p_id_test),
	(select cast(COUNT(*)as int) from participantes_test pt where pt.estado and id_test=p_id_test),
	preguntas_aleatorias,
	abierta,
	(select case when COUNT(*)>0 then true else false end as TieneProgreso from participantes_test pt  
inner join progreso_secciones ps ON pt.id_participante_test =ps.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr  on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
where pt.id_test =p_id_test)
	from test 
	where id_test = p_id_test; --cast(id_user_crea as varchar(900))= p_user_id; --and estado = true;
end;
$function$
;

select * from test t 


select cast(LEFT(titulo, 80) || '...' as varchar(900) ) as titulo, 
	titulo,
	cast(to_char(fecha_hora_inicio,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(fecha_hora_cierre,'DD-MON-YYYY HH24:MI')as varchar(500)) as fecha_hora_cierre,
	estado_detalle, 
	suspendio, descripcion, ingresos_permitidos, cast(tokens as varchar(900)), 
	case when (select Count(*) from errores_test er where er.id_test=140 and estado )>=1 then true else false end as error,
	(select cast(COUNT(*)as int) from test_secciones ts where ts.estado and ts.id_test=140),
	(select cast(COUNT(*)as int) from participantes_test pt where pt.estado and id_test=140),
	preguntas_aleatorias,
	abierta,
	--anadir el campo para ver si contiene progresos
	(select case when COUNT(*)>0 then true else false end as TieneProgreso from participantes_test pt  
inner join progreso_secciones ps ON pt.id_participante_test =ps.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr  on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
where pt.id_test =140)
	from test 
	where id_test = 140;

select case when COUNT(*)>0 then true else false end as TieneProgreso from participantes_test pt  
inner join progreso_secciones ps ON pt.id_participante_test =ps.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr  on pp.id_progreso_preguntas =pr.id_progreso_pregunta 
where pt.id_test =140;

/*
 132
 140
 137
 * */


select * from fu_detalle_test_id(140)

select * from data_respuesta_id(89)

--editar el procedimiento almacenado para poder editar preguntas con estado check o uncheck

-- DROP PROCEDURE public.sp_editar_respuesta_selccma(int4, varchar);

CREATE OR REPLACE PROCEDURE public.sp_editar_respuesta_selccla(IN p_id_respuesta integer, IN p_enunciado_new character varying,
in estado_correcta bool)
 LANGUAGE plpgsql
AS $procedure$
begin
	
	update respuestas  set opcion =p_enunciado_new,correcta=estado_correcta
where id_respuesta =p_id_respuesta;
		
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

select * from respuestas



--colocar el trigger para que controle cada vez que se elimine una opcion de respuesta
create trigger tr_eliminar_respuesta_before before
delete
    on
    public.respuestas for each row execute function fu_tr_eliminar_respuesta()
    
--
    -- DROP FUNCTION public.fu_tr_anadir_respuesta();

-- DROP FUNCTION public.fu_tr_anadir_respuesta();

CREATE OR REPLACE FUNCTION public.fu_tr_eliminar_2_respuesta()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = new.id_pregunta;
		
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta


	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas = false  then 
		/*
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		else 
		*/
			update preguntas set error = true, error_detalle ='Esta pregunta no contiene opcion(es) correta(s)' where id_pregunta =new.id_pregunta;
		end if;
		--else if si no contiene correctas entonces actualizar el registro de preguntas bool error = true y detalle 'esta pregunta no contiende opcion(es) correta(s)'
		if new.correcta then
			update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
		end if;
		--if si la opcion es marcada como correcta acualizar el registro de preguntas bool error= false 
	--anadir el else para las preguntas multiples 
	else 
		--primero preguntar si tiene mas de 2 preguntas como correctas ya que esa es la condicion para que sea multiple 
		select into contiene_correctas case when count(*) >1 then true else false end  from respuestas r where r.id_pregunta = new.id_pregunta  and r.estado and r.correcta; 
			if contiene_correctas then 
				--como contiene mas de 2 correctas entonces la pregunta esta correcta 
				update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
			else 
				-- como no contiene mas de 2 correctas entonces colocar el error que indique que faltan respuestas correctas
				update preguntas set error = true, error_detalle ='Esta pregunta no contiene más de 2 respuestas correctas' where id_pregunta =new.id_pregunta;

			end if;
end if;
return new;
end
$function$
;



create trigger tr_eliminar_respuesta_after after
delete
    on
    public.respuestas for each row execute function fu_tr_anadir_respuesta_eliminado()
    
    
-- DROP FUNCTION public.fu_tr_anadir_respuesta();

CREATE OR REPLACE FUNCTION public.fu_tr_anadir_respuesta_eliminado()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	opciones_multiples_op bool;
	contiene_correctas bool;
	--Pref_cat varchar(5);
begin
	--primero consulta si la la pregunta admite opciones multiples o solo una 
	select into opciones_multiples_op tp.opcion_multiple  from preguntas p inner join tipos_preguntas tp on p.tipo_pregunta =tp.id_tipo_pregunta 
	where p.id_pregunta = OLD.id_pregunta;
		
	--hacer un update al registro de la pregunta colocando el bool error = falso porque ya se esta ingresando una repuesta


	--hacer el conteo de opciones marcadas como correctas en caso de que solo admita una opcion not
	if opciones_multiples_op = false then 
		--consultar cuantas preguntas correctas tiene marcadas porque solo admite 1 este tipo de pregunta
		select into contiene_correctas case when count(*) >=1 then true else false end  from respuestas r where r.id_pregunta = OLD.id_pregunta  and r.estado and r.correcta; 
		--comprar si es true es porque ya tiene respuestas marcadas como correctas 
		if contiene_correctas = false  then 
		/*
		---aqui preguntar si lo que se quiere ingreesar es una opcion coore 
			if new.correcta then
					raise exception 'Solo se admite un opcion de respuesta como correcta';
			end if;
		else 
		*/
			update preguntas set error = true, error_detalle ='Esta pregunta no contiene opcion(es) correta(s)' where id_pregunta =OLD.id_pregunta;
		end if;
		--else if si no contiene correctas entonces actualizar el registro de preguntas bool error = true y detalle 'esta pregunta no contiende opcion(es) correta(s)'
		
	--if new.correcta then
			--update preguntas set error = false, error_detalle ='' where id_pregunta =new.id_pregunta;
		--end if;
	
	
	--if si la opcion es marcada como correcta acualizar el registro de preguntas bool error= false 
	--anadir el else para las preguntas multiples 
	else 
		--primero preguntar si tiene mas de 2 preguntas como correctas ya que esa es la condicion para que sea multiple 
		select into contiene_correctas case when count(*) >1 then true else false end  from respuestas r where r.id_pregunta = OLD.id_pregunta  and r.estado and r.correcta; 
			if contiene_correctas then 
				--como contiene mas de 2 correctas entonces la pregunta esta correcta 
				update preguntas set error = false, error_detalle ='' where id_pregunta =OLD.id_pregunta;
			else 
				-- como no contiene mas de 2 correctas entonces colocar el error que indique que faltan respuestas correctas
				update preguntas set error = true, error_detalle ='Esta pregunta no contiene más de 2 respuestas correctas' where id_pregunta =OLD.id_pregunta;

			end if;
end if;
return new;
end
$function$
;


---lista de los tipos de preguntas
select distinct(tp.codigo) from tipos_preguntas tp 


select * from valor_preguntas vp 


--Editar la funcion que devuelve los valores de las claves de cada pregunta para obtener su id y poder editarlo
-- DROP FUNCTION public.fu_repuestas_con_valores1(int4);

CREATE OR REPLACE FUNCTION public.fu_repuestas_con_valores1(p_id_pregunta integer)
 RETURNS TABLE(r_id_repuesta integer, r_opcion character varying, r_correcta boolean, r_estado boolean, r_eliminado boolean, r_valor character varying,r_id_valor integer)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select r.id_respuesta, r.opcion, r.correcta, r.estado, r.eliminado, vp.valor, vp.id_valor from respuestas r 
	inner join valor_preguntas vp on r.id_respuesta = vp.id_respuesta 
	where id_pregunta = p_id_pregunta;
	end;
$function$
;



--funcion para devolver los valores de un respuesta de opcion OPVCLAV and OPCLAV2 
--ejemeplo de valor con 2 atributos: 464


select * from fu_opciones_OPCLAVA_OPCLAV2(464);

CREATE OR REPLACE FUNCTION public.fu_opciones_OPCLAVA_OPCLAV2(p_id_respuesta integer)
 RETURNS TABLE(
 	r_id_valor integer, r_id_respuesta integer, r_id_clave integer, r_valor character varying, r_id_pregunta integer, r_clave character varying,
 	r_tipo character varying
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select vp.id_valor ,vp.id_respuesta , vp.id_clave , vp.valor , cp.id_pregunta , cp.clave , cp.tipo 
from valor_preguntas vp 
inner join claves_preguntas cp  on cp.id_clave = vp.id_clave  
where vp.id_respuesta =p_id_respuesta;
	end;
$function$
;

--Crear un procedimiento almacenado que reciba como parametro un JSON y que este sea el encargado de editar los valores de las claves 
--Buscar en la API para copiar y pegar la funcion : SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON

CREATE OR REPLACE PROCEDURE public.SP_EDITAR_VALORES_CLAVES(									
														IN p_claves_valores json
														)
 LANGUAGE plpgsql
AS $procedure$
declare
	--reemplazar el json para recorrerlo
	p_p_respuesta JSON;
	--variables del JSON
	--r_opcion character varying;
	--seleccionado bool;
	r_id_valor int;
	r_valor character varying;
begin
	
	
	FOR p_p_respuesta IN SELECT * FROM json_array_elements(p_claves_valores)
    loop
	    --varibales 
       r_id_valor := (p_p_respuesta ->> 'r_id_valor')::integer;
	   r_valor := (p_p_respuesta ->> 'r_valor')::character varying;
	 --Aqui hacer el update segun el r_id_valor 
	  	update valor_preguntas set valor =r_valor where id_valor =r_id_valor;
    end loop;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$procedure$
;

select * from valor_preguntas vp 



select * from claves_preguntas cp  where cp.id_pregunta =142

--consulta para saber si el ultimo nivel de una seccion contiene preguntas validas para poder crear un nuevo nivel









--fu_tr_insert_niveles_sum_nivel
create trigger tr_insert_niveles_sum_nivel before
insert
    on
    public.niveles for each row execute function fu_tr_insert_niveles_sum_nivel()
    
    
---Editar la funcion del trigger para controlar la creacion de nuevos niveles 
    -- DROP FUNCTION public.fu_tr_insert_niveles_sum_nivel();

CREATE OR REPLACE FUNCTION public.fu_tr_insert_niveles_sum_nivel()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	p_nivel int =0;
	p_contiene_niveles bool;
	P_ContienePreguntasNivel bool;
	P_NivelConErrrores bool;
begin
	--hacer una condicion para controlar si la seccion tiene mas de un nivel y poder realizar los cambios
	select into p_contiene_niveles case when COUNT(*)>0 then true else false end as ContieneMasNiveles from niveles n where n.id_seccion =new.id_seccion;
	if p_contiene_niveles then 
			---Si el nivel no tiene preguntas entonces no dejar crear niveles 
			select into P_ContienePreguntasNivel case when count(*)>0 then true else false end as ContienePreguntasNivel from 
			(select id_nivel,nivel from niveles n where n.id_seccion =new.id_seccion order by nivel desc limit 1) as x
			inner join preguntas p on p.id_nivel = x.id_nivel;
		--Exepction
			if P_ContienePreguntasNivel=false then 
				 raise exception 'No puede crear niveles porque el ultimo creado no contiene preguntas';
			end if;
		--
			--Si el nivel contiene preguntas con erorres entonces no dejar crear niveles
			select into P_NivelConErrrores case when count(*)>0 then true else false end as NivelConErrrores from 
			(select id_nivel,nivel from niveles n where n.id_seccion =new.id_seccion order by nivel desc limit 1) as x
			inner join preguntas p on p.id_nivel = x.id_nivel
			where p.error ;
			
			if P_NivelConErrrores then 
				raise exception 'No puede crear niveles porque el ultimo creado contiene preguntas con errores';
			end if;
	end if;

	--Si no hay exepciones entonces ejecutar esto 
	select into p_nivel count(*)+1 from niveles where id_seccion = new.id_seccion;
	new.nivel = p_nivel;
return new;
end
$function$
;

--funcion para eliminar un nivel con todo y sus preguntas skere modo diablo
/*
 * Ejemplo de una eliminacion mediante un subconsulta:
 * DELETE FROM clave_valor_respuesta where id_registro in (
select clr.id_registro  from participantes_test pt
inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test 
inner join progreso_preguntas pp on ps.id_progreso_seccion =pp.id_progreso_seccion 
inner join progreso_respuestas pr on pp.id_progreso_preguntas = pr.id_progreso_pregunta 
inner join clave_valor_respuesta clr on pr.id_progreso_respuestas =clr.id_progreso_respuesta 
where pt.id_test =p_id_test);
 * */
--Lista en cascada de las tablas afectadas para eliminar un nivel 
/*
valor_preguntas LISTO
claves_preguntas LISTO
respuestas 			LISTO
extra_pregunta			LISTO
preguntas			Listo 
niveles 
**/
--Paso 0 eliminar los valores_preguntas de una respuesta 
--tomar de ejemplo el nivel 4 de la seccion memoria: id = 54

--delete from valor_preguntas where id_respuesta in
select * from valor_preguntas vp where vp.id_respuesta in (
select r.id_respuesta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
inner join respuestas r on p.id_pregunta =r.id_pregunta
where 
n.id_nivel = 35 --id del nivel a eliminar 
and n.id_seccion =54--Seccion Memoria de ejemplo
)
--Paso 1 eliminar las claves_preguntas
--delete from claves_preguntas where id_pregunta in 
select * from claves_preguntas where id_pregunta in (
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = 35 --id del nivel a eliminar 
and n.id_seccion =54--Seccion Memoria de ejemplo
)
--Paso 2 eliminar respuestas
--delete from respuestas where id_pregunta in 
select * from respuestas   where id_pregunta in (
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = 35 --id del nivel a eliminar 
and n.id_seccion =54--Seccion Memoria de ejemplo
)
--Paso 3 eliminar extra_pregunta
--delete from extra_pregunta where id_pregunta in 
select * from extra_pregunta   where id_pregunta in (
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = 35 --id del nivel a eliminar 
and n.id_seccion =54--Seccion Memoria de ejemplo
)
--Paso 4 eliminar preguntas
--delete from preguntas where id_nivel= 35; --id del nivel 
select * from preguntas  where id_nivel= 35;
--Paso 5 eliminar niveles 
--delete from niveles where id_nivel= 35; --id del nivel 
select * from niveles  where id_nivel= 35;
--Paso 6 actualizar los numeros de los niveles con un for por ejemplo skere modo diablo


DO $$
DECLARE
    contador INTEGER;
   	finalizador INTEGER;
   	p_id_nivel_editable integer;
BEGIN
    contador := 1;
   --finalizador:=10; --el numero total de niveles que tiene la seccion a la que se le esta eliminado el nivel actual
   --obtener el numero de niveles de una seccion 
	select into finalizador COUNT(*) as NumeroNiveles
	from niveles n where n.id_seccion =54; --id de la seccion a editar 

	--Recorrer el for para hacer el update de los numeros de los niveles
    FOR contador IN 1..finalizador loop
	    --aqui obtener el id del nivel y actualizar segun la iteracion 
	    select into p_id_nivel_editable x.id_nivel from 
		(select n.id_nivel,n.id_seccion,n.nivel,
	    ROW_NUMBER() OVER (PARTITION BY id_seccion ORDER BY id_nivel) AS num
		from niveles n where n.id_seccion =54) as X 
		where X.num=contador; --escojer segun el contador
			
		--actualizar el nivel segun el id del nivel obtenido y con el nivel del contador
			update niveles set nivel =contador where id_nivel =p_id_nivel_editable;
        --RAISE NOTICE 'Nivel %', contador;
    END LOOP;
END $$;



--Ahora guardar todo en un procedimiento almacenado que reciba como parametro dos variables,
--el id del nivel y el id de la seccion 
Create or Replace Procedure SP_Eliminar_nivel_y_actualizarlos(
										p_id_nivel integer,
										p_id_seccion integer
										  )
Language 'plpgsql'
AS $$
declare
	contador INTEGER;
   	finalizador INTEGER;
   	p_id_nivel_editable integer;
begin
	
--Paso 0 eliminar los valores_preguntas de una respuesta 
--tomar de ejemplo el nivel 4 de la seccion memoria: id = 54

delete from valor_preguntas where id_respuesta in
 (
select r.id_respuesta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
inner join respuestas r on p.id_pregunta =r.id_pregunta
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 1 eliminar las claves_preguntas
delete from claves_preguntas where id_pregunta in (
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 2 eliminar respuestas
delete from respuestas where id_pregunta in(
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 3 eliminar extra_pregunta
delete from extra_pregunta where id_pregunta  in(
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 4 eliminar preguntas
delete from preguntas where id_nivel= p_id_nivel; --id del nivel 
--select * from preguntas  where id_nivel= p_id_nivel;
--Paso 5 eliminar niveles 
delete from niveles where id_nivel= p_id_nivel; --id del nivel 
--select * from niveles  where id_nivel= p_id_nivel;
--Paso 6 actualizar los numeros de los niveles con un for por ejemplo skere modo diablo

	 contador := 1;
   --finalizador:=10; --el numero total de niveles que tiene la seccion a la que se le esta eliminado el nivel actual
   --obtener el numero de niveles de una seccion 
	select into finalizador COUNT(*) as NumeroNiveles
	from niveles n where n.id_seccion =p_id_seccion; --id de la seccion a editar 

	--Recorrer el for para hacer el update de los numeros de los niveles
    FOR contador IN 1..finalizador loop
	    --aqui obtener el id del nivel y actualizar segun la iteracion 
	    select into p_id_nivel_editable x.id_nivel from 
		(select n.id_nivel,n.id_seccion,n.nivel,
	    ROW_NUMBER() OVER (PARTITION BY id_seccion ORDER BY id_nivel) AS num
		from niveles n where n.id_seccion =p_id_seccion) as X 
		where X.num=contador; --escojer segun el contador
			
		--actualizar el nivel segun el id del nivel obtenido y con el nivel del contador
			update niveles set nivel =contador where id_nivel =p_id_nivel_editable;
        --RAISE NOTICE 'Nivel %', contador;
    END LOOP;
	
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;



--Funcion para eliminar toda la seccion completa, es decir, los valores, claves, respuestas, preguntas, extras,niveles
--hacer un procedimiento que se encargue de eliminar todo uno a uno para luego recorrelo con un for segun los niveles
Create or Replace Procedure SP_Eliminar_niveles_y_contenido(
										p_id_nivel integer,
										p_id_seccion integer
										  )
Language 'plpgsql'
AS $$
declare
	contador INTEGER;
   	finalizador INTEGER;
   	p_id_nivel_editable integer;
begin
	
--Paso 0 eliminar los valores_preguntas de una respuesta 
--tomar de ejemplo el nivel 4 de la seccion memoria: id = 54

delete from valor_preguntas where id_respuesta in
 (
select r.id_respuesta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
inner join respuestas r on p.id_pregunta =r.id_pregunta
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 1 eliminar las claves_preguntas
delete from claves_preguntas where id_pregunta in (
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 2 eliminar respuestas
delete from respuestas where id_pregunta in(
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 3 eliminar extra_pregunta
delete from extra_pregunta where id_pregunta  in(
select p.id_pregunta  from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where 
n.id_nivel = p_id_nivel --id del nivel a eliminar 
and n.id_seccion =p_id_seccion--Seccion Memoria de ejemplo
);
--Paso 4 eliminar preguntas
delete from preguntas where id_nivel= p_id_nivel; --id del nivel 
--select * from preguntas  where id_nivel= p_id_nivel;
--Paso 5 eliminar niveles 
delete from niveles where id_nivel= p_id_nivel; --id del nivel 

	
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción secundaria: %', SQLERRM;	
END;
$$;


--La fucnion principal tiene que tener un for que recorrar nivel por nivel y obtenga el id del nivel para llamar la 2da parte creada 
Create or Replace Procedure SP_eliminar_Seccion_Contenido(
										p_id_seccion integer
										  )
Language 'plpgsql'
AS $$
declare
	contador INTEGER;
   	finalizador INTEGER;
   	p_id_nivel_editable integer;
begin


	 contador := 1;
   --finalizador:=10; --el numero total de niveles que tiene la seccion a la que se le esta eliminado el nivel actual
   --obtener el numero de niveles de una seccion 
	select into finalizador COUNT(*) as NumeroNiveles
	from niveles n where n.id_seccion =p_id_seccion; --id de la seccion a editar 

	--Recorrer el for para hacer el update de los numeros de los niveles
    FOR contador IN 1..finalizador loop
	    --aqui obtener el id del nivel y actualizar segun la iteracion 
	    select into p_id_nivel_editable x.id_nivel from 
		(select n.id_nivel,n.id_seccion,n.nivel,
	    ROW_NUMBER() OVER (PARTITION BY id_seccion ORDER BY id_nivel) AS num
		from niveles n where n.id_seccion =p_id_seccion) as X ;
		--where X.num=contador; --escojer segun el contador
		--llamar a la funcion que se encarga de eliminar los niveles con su contenido 
		call SP_Eliminar_niveles_y_contenido(
										p_id_nivel_editable,
										p_id_seccion
										  );
	
    END LOOP;
	--al finalizar el for loop hay que eliminar la seccion 
   delete from secciones_usuario where id_seccion=p_id_seccion;
   	delete from secciones  where id_seccion=p_id_seccion;
	--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal1: %', SQLERRM;	
END;
$$;

select * from secciones_usuario su 


select * from secciones s ;



--funcion con data para editar sobre una seccion mediante el id de la seccion 

select * from FU_info_edit_section(54)

CREATE OR REPLACE FUNCTION public.FU_info_edit_section(p_id_seccion integer)
 RETURNS TABLE(r_descripcion  character varying, r_titulo character varying, r_Estado bool)
 LANGUAGE plpgsql
AS $function$

begin
			return query
			select s.descripcion, s.titulo ,s.Estado 
				from secciones s where s.id_seccion =p_id_seccion;
end;
$function$
;


--Procedimiento almacenado para editar los paramatros de la seccion 
Create or Replace Procedure SP_Editar_Seccion(
										p_titulo varchar(500),
										p_descripcion varchar(500),
										p_new_Estado bool,
										p_id_seccion integer
										  )
Language 'plpgsql'
AS $$

begin
	--Editar la seccion
	update secciones set titulo=p_titulo, descripcion=p_descripcion, estado=p_new_Estado where id_seccion=p_id_seccion;
	
--EXCEPTION
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;

select * from secciones s 

--añadir el estado a la funcion que devuelve la lista de las seccioens 
--añadir si las preguntas de esa seccion contienen errores skere modo diablo
-- DROP FUNCTION public.fu_secciones_usuario(varchar);

CREATE OR REPLACE FUNCTION public.fu_secciones_usuario(p_idu character varying)
 RETURNS TABLE(r_id_seccion integer, r_titulo character varying, r_descripcion character varying,
 r_admin_seccion boolean, r_estado boolean, r_erroneo boolean )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select s.id_seccion ,s.titulo ,s.descripcion, su.admin_seccion,s.estado,
	--Para identificar si la seccion tiene algun tipo de error 
	(select 
case when COUNT(*)>=1 then true --indica que si hay un error
else 
	--hacer otro case when que cuente todas las preguntas para ver si da un error
	case when (select COUNT(*) from niveles n 
inner join preguntas p on n.id_nivel =p.id_nivel 
where n.id_seccion =s.id_seccion and p.error ) = 0 then false else true end 
end as Verificador
from 
(select 
n.id_nivel,
(select Count(*) from preguntas p where n.id_nivel=p.id_nivel) as ContadorPreguntas
from niveles n 
where n.id_seccion =s.id_seccion and (select Count(*) from preguntas p where n.id_nivel=p.id_nivel)=0) as X
)
	from secciones s  
	inner join secciones_usuario su on s.id_seccion = su.id_seccion  
	where cast(su.id_usuario as varchar(800)) = p_idu;
end;
$function$
;

--55
--primero ver si los niveles tienen preguntas
--Si la primer subconsulta da = entonces hay un error

select * from secciones s 

select 
case when COUNT(*)>=1 then true --indica que si hay un error
else false end 
from 
(select 
n.id_nivel,
(select Count(*) from preguntas p where n.id_nivel=p.id_nivel) as ContadorPreguntas
from niveles n 
where n.id_seccion =54 and (select Count(*) from preguntas p where n.id_nivel=p.id_nivel)=0) as X



select * from test t 



--Modficar la siguiente funcion para poder controlar si un formulario esta erroneo o esta caducado skere 
-- DROP FUNCTION public.form_data(varchar);

CREATE OR REPLACE FUNCTION public.form_data(p_token character varying)
 RETURNS TABLE(r_disponibilidad boolean, r_caducado boolean, r_poximo boolean, r_titulo character varying, r_fecha_hora_inico character varying, r_fecha_cierre character varying, r_estado boolean, r_suspendio boolean, r_descripcion character varying, r_ingresos_permitidos integer, r_token character varying, r_estado_error boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select case when 
	Now()>=t.fecha_hora_inicio and Now()<= t.fecha_hora_cierre then true else false end as Verificacion_Disponibilidad,
	case when Now()>t.fecha_hora_cierre then true else false end as Caducado,
	case when Now()<t.fecha_hora_inicio then true else false end as Proximo,
	t.titulo, 
	cast(to_char(t.fecha_hora_inicio,'DD-MON-YYYY')as varchar(500)) as fecha_hora_inicio,
	cast(to_char(t.fecha_hora_cierre,'DD-MON-YYYY')as varchar(500)) as fecha_cierre, 
	t.estado,
	t.suspendio,
	t.descripcion,
	t.ingresos_permitidos,
	cast(t.tokens as character varying),
	case when estado_detalle='Verificado' then true else false end as Estado_Error
	from test t where cast(t.tokens as character varying) = '06b20f76-8cc6-457d-beb5-cff15a136e19';--p_token; 
end;
$function$
;

--funcion que retorne ciertos parametros para saber los estados de un formulario 
select t.tokens ,* from test t ;
/*
d8ede920-ab80-4bce-a223-f7b5f7c4e3f7
06b20f76-8cc6-457d-beb5-cff15a136e19
3e656c86-bebf-44f0-afca-b33ab3b3f56a
c391f32e-cc07-45bd-ba2c-48eded0b6460
 * */
select Toek,* from test t 
select * from Estado_Formulario('c391f32e-cc07-45bd-ba2c-48eded0b64260') order by r_estado desc limit 1;

CREATE OR REPLACE FUNCTION public.Estado_Formulario(p_token character varying)
 RETURNS TABLE(r_estado integer )
 LANGUAGE plpgsql
AS $function$
declare 
	p_erroneo bool;
	p_caducado bool;
	p_proximo bool;
	p_suspendido bool;
	p_no_exite bool;
begin
	--return query
	 --Primero Verificar si el test contiene errores 
	select into p_erroneo case when Count(*)>=1 then true else false end as Verificador
	from test t 
	inner join errores_test et  on t.id_test= et.id_test 
	where et.estado and cast(t.tokens as character varying) = p_token;
	--y asi ir verificando cada uno de los errores para saber de que tipo son y si se tiene que mostrar el formulario o no skere 
	
	--case when Now()>t.fecha_hora_cierre then true else false end as Caducado,
	select into p_caducado case when Now()>t.fecha_hora_cierre then true else false end as Caducado from test t 
	where  cast(t.tokens as character varying) = p_token;
	
	--para el proximo
	--	case when Now()<t.fecha_hora_inicio then true else false end as Proximo,
	select into p_proximo case when Now()<t.fecha_hora_inicio then true else false end as Proximo
	from test t 
	where  cast(t.tokens as character varying) = p_token;
	
	--para el estado suspendido
	select into p_suspendido t.suspendio
	from test t 
	where  cast(t.tokens as character varying) = p_token;

	--No existe 
	select into p_no_exite case when Count(*) =0 then true else false end as Existe
	from test t 
	where  cast(t.tokens as character varying) = p_token;
	--'06b20f76-8cc6-457d-beb5-cff15a136e19'

	--select * from test
	--Preguntar si contiene el error entonces retornar erroneo skere modo diablo 
	-- Primer IF para verificar p_erroneo
	if p_erroneo = true then
		return query
		select 1; -- Cuando sea erróneo, retornar 1
	end if;
	
	-- Segundo IF para verificar p_caducado
	if p_caducado = true then
		return query
		select 2; -- Cuando sea caducado, retornar 2
	end if;
	
	-- Tercer IF para verificar p_proximo
	if p_proximo = true then
		return query
		select 3; -- Cuando sea próximo, retornar 3
	end if;
	--p_suspendido
	if p_suspendido = true then
		return query
		select 4; -- Cuando sea próximo, retornar 3
	end if;
if p_no_exite = true then
		return query
		select 5; -- Cuando sea próximo, retornar 3
	end if;
	-- Si ninguno de los casos anteriores se cumple, retornar 0, quiere decir que es correcto skere modo diablo
	return query
	select 0;
end;
$function$
;


select * from errores_test et ;


--trigger que cuente los ingresos que tiene un usuario segun el test al que esta ingresando 





create or replace function FU_TR_controlar_ingresos_usuarios() returns trigger 
as 
$$
---Declarar variables
declare
	p_numero_de_ingresos integer;
	p_ingresos_permitidos integer;
begin
	--el numero de ingresos que tiene el usuario en dicho test
	select into p_numero_de_ingresos COUNT(*) from ingresos i where i.id_participante_test = new.id_participante_test;
	--el numero de ingresos permitidos por el test skere modo diablo 
	select into p_ingresos_permitidos t.ingresos_permitidos  from ingresos i
	inner join participantes_test pt  on i.id_participante_test =pt.id_participante_test 
	inner join test t on pt.id_test = t.id_test 
	where i.id_participante_test =new.id_participante_test limit 1;
	
	if p_numero_de_ingresos>=p_ingresos_permitidos then 
			--entonces es porque cumplio con los ingresos permitidos skere modo diablo
				update participantes_test set supero_limite=true 
			    where id_participante_test =new.id_participante_test;
	else
		update participantes_test set supero_limite=false 
			    where id_participante_test =new.id_participante_test;
	end if;
return new;
end
$$
language 'plpgsql';

create trigger Tr_control_ingresos
after insert 
on ingresos
for each row 
execute procedure FU_TR_controlar_ingresos_usuarios();





-- DROP FUNCTION public.fu_progreso_secciones_tokens(varchar, varchar);

CREATE OR REPLACE FUNCTION public.fu_progreso_secciones_tokens(p_id_toke_particiapnta character varying, p_id_token_test character varying)
 RETURNS TABLE(r_id_progreso_seccion integer, r_id_seccion integer, r_id_participante_test integer, r_estado_completado boolean, r_bloqueado boolean, r_porcentaje numeric, r_titulo_seccion character varying, r_descripcion_seccion character varying, r_supero_limite bool)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select ps.id_progreso_seccion ,ps.id_seccion ,ps.id_participante_test ,
		ps.estado_completado ,ps.bloqueado, ps.porcentaje, s.titulo, s.descripcion, pt.supero_limite
	from test t 
	inner join participantes_test pt on t.id_test =pt.id_test 
	inner join progreso_secciones ps on ps.id_participante_test =pt.id_participante_test
	inner join secciones s on ps.id_seccion = s.id_seccion 
	where cast(t.tokens as character varying)=p_id_token_test
	and cast(pt.id_participante as character varying)=p_id_toke_particiapnta;
end;
$function$
;

select * from test t where t.id_test = 144;

call sp_editar_test('Progresos Editado1',144,'Descripcion Editada',20,false ,false)
--Procedimiento almacenado para editar cosas del test skere modo diablo 
--el procedimiento no editara la fecha de inicio ni la fecha de fin 
-- DROP PROCEDURE public.sp_insertar_test(varchar, timestamp, timestamp, varchar, varchar, int4, bool, bool);

CREATE OR REPLACE PROCEDURE 
public.sp_editar_test
(IN p_titulo character varying, 
p_id_test int,
IN p_descripcion character varying,
IN p_ingresos_permitidos integer,
IN p_cualquier_entrar boolean, 
IN p_aleatoria boolean)
 LANGUAGE plpgsql
AS $procedure$ 
declare 
	p_bool_diferente bool;
	p_accesos bool;
BEGIN
 	update Test set titulo=p_titulo, descripcion=p_descripcion, Ingresos_Permitidos=p_ingresos_permitidos
 					--preguntas_aleatorias=p_aleatoria,
 					--abierta=p_cualquier_entrar
 					where id_test=p_id_test;
--Mejor si se envia un tru para cambiar el estado del test cambiarlo skere modo diablo
 if p_aleatoria then
 		select into p_bool_diferente not preguntas_aleatorias from Test where id_test=p_id_test;
 		update Test set 
 					preguntas_aleatorias=p_bool_diferente
 					where id_test=p_id_test;
 end if;
--Hacer lo mismo para el tipo de acceso al formulario 
if p_cualquier_entrar then
	select into p_accesos not abierta from Test where id_test=p_id_test;
 		update Test set 
 					abierta=p_accesos
 					where id_test=p_id_test;
end if;
EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM USING HINT = 'Revisa la transacción principal.';
END;
$procedure$
;

--anadir el trigger despues de hacer el update xq se cambia el tipo de ingreso de ingreso del formulario
--esta funcion solo valida si tiene o no registros de participantes el formulario 
CREATE OR REPLACE FUNCTION public.fu_tr_test_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
---Declarar variables
declare
	p_tiene_participantes bool;
	p_tiene_registro bool;
	p_tipo_acceso bool;
	p_contien_errores bool;
begin
	--primero verificar si tiene participantes activos el test
	 select into p_tiene_participantes case when COunt(*)>0 then true else false end from participantes_test pt 
 	where pt.id_test =new.id_test; --and estado ;
	--Verificar si tiene registro de errores de tipo pariticpantes en la tabla errores_test
 	select into p_tiene_registro case when COUNT(*)>0 then true else false 
	end from errores_test et where et.id_test =new.id_test and et.error_detalle ='El test no contiene participantes';
	SELECT into p_tipo_acceso abierta FROM test WHERE id_test = new.id_test;	
	--primero preguntar si el nuevo estado de acceso al test es abierto o registringo 
    
IF p_tipo_acceso THEN
        --si es de tipo abierta borrar el mensaje de error en participantes 
       update errores_test set estado = false where id_test =new.id_test and error_detalle='El test no contiene participantes';
    else 
 		--si tiene participantes con estado true entonces actualizar el registro de errores_test y poner 
 	--false el error contiene participantes
			if p_tiene_participantes then 
		 	  	update errores_test set estado = false where id_test =new.id_test and error_detalle='El test no contiene participantes';
			else 
			--si no tiene participantes verificar si ya existe el registro para crear o modificarlo 
				if p_tiene_registro then 
					--como si tiene registro y el numero de participantes es 0 entonces colocar el estado en false
					 update errores_test set estado = true where id_test =new.id_test and error_detalle='El test no contiene participantes';
				else 
					--como no existe registro entonces crearlo 
				insert into errores_test(id_test,error_detalle)values(new.id_test,'El test no contiene participantes');
				end if;
	 		end if;
 	---
    END IF;	
   /*
	select into p_contien_errores case when count(*)>=1 then true else false end as verificacion from errores_test et where et.id_test =new.id_test and et.estado ;
	if p_contien_errores then 
		  update test set estado_detalle ='Erroneo' where id_test =new.id_test;
			else 
			  update test set estado_detalle ='Verificado' where id_test =new.id_test;
			end if; 
		*/
return new;
end
$function$
;

select * from test where id_test =142;

DROP TRIGGER IF EXISTS tr_test_update ON test;




create  trigger tr_test_update after
update
    on
    public.test for each row execute function fu_tr_test_update()
    
    
    select * from errores_test where id_test=142;
   
   
CREATE OR REPLACE FUNCTION public.fu_tr_errores_test()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	p_contien_errores bool;
begin
	--primer verificar las secciones
	select into p_contien_errores case when count(*)>=1 then true else false end as verificacion from errores_test et where et.id_test =new.id_test and et.estado ;
	if p_contien_errores then 
		  update test set estado_detalle ='Erroneo' where id_test =new.id_test;
			else 
			  update test set estado_detalle ='Verificado' where id_test =new.id_test;
			end if;
return new;
end
$function$
;



select * from test t where t.id_test ='142'

---funcion para editar la fecha de inicio y cierre del test 
-- DROP PROCEDURE public.sp_insertar_test(varchar, timestamp, timestamp, varchar, varchar, int4, bool, bool);

CREATE OR REPLACE PROCEDURE public.sp_cambiar_fecha_hora_test
( IN p_fecha_hora_update timestamp without time zone,
  in p_id_test integer, in cual_fecha_editar bool)
 LANGUAGE plpgsql
AS $procedure$ 

begin
	--si el indicar es true entonces actualizar la fecha de inicio sino actualizar la fecha de cierre 
	if cual_fecha_editar then 
		update Test set Fecha_hora_inicio=p_fecha_hora_update where id_test=p_id_test;
	else 
		update Test set Fecha_hora_cierre=p_fecha_hora_update where id_test=p_id_test;
	end if;

EXCEPTION
    -- Si ocurre algún error, revierte la transacción
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM USING HINT = 'Revisa la transacción principal.';
END;
$procedure$
;


--colocar los disparadores para controlar las actualizaciones de las fechas
create trigger tr_test_validar_fechas_update before
update
    on
    public.test for each row execute function fu_tr_test_validar_fechas()

    
--funcion para eliminar unas seccion de un test 
select * from test_secciones ts where ts.id_test =142;

--procedimiento almacenado para eliminar una seccion 
    Create or Replace Procedure SP_Eliminar_seccion_test(
    in p_id_test integer, in p_id_seccion integer
    )
Language 'plpgsql'
AS $$
begin
		delete  from test_secciones ts where ts.id_test =p_id_test and id_seccion=p_id_seccion;
	EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	
END;
$$;


select * from usuario u;


-- DROP PROCEDURE public.crear_usuario(varchar, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE PROCEDURE public.crear_usuario
	(IN p_contrasena character varying,
	IN p_correo_institucional character varying,
	IN p_identificacion character varying, 
	IN p_nombres_apellidos character varying,
	IN p_celular character varying)
 LANGUAGE plpgsql
AS $procedure$

Begin
	insert into usuario(
						contra,
						correo_institucional,
						identificacion,
						nombres_apellidos,
						numero_celular,
						tipo_identificacion
						)values
						(
						 PGP_SYM_ENCRYPT(p_contrasena::text,'SGDV_KEY'),
						 p_correo_institucional,
						 p_identificacion,
						 p_nombres_apellidos,
						 p_celular,
						 'Cedula'
						);

EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	

END;
$procedure$
;

--hacer un trigger que verifique los dominios permitidos para que los usuarios se puedan registrar 
-- DROP FUNCTION public.fu_tr_insert_usuario();

CREATE OR REPLACE FUNCTION public.fu_tr_insert_usuario()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare 
	p_dominio character varying;
begin
	if trim(new.nombres_apellidos)='' then
            raise exception 'Nombres no puede ser vacio';
    end if;
    if new.identificacion  ~ '[^0-9]' then 
        raise exception 'Identificacion solo puede contener numeros';
    end if;
    if new.numero_celular  ~ '[^0-9]' then 
        raise exception 'Celular solo puede contener numeros';
    end if;
    if length(new.numero_celular) <> 10 then
        raise exception 'Celular debe tener 10 digitos';
    end if; 
    if trim(new.correo_institucional)='' then
            raise exception 'Correo institucional no puede ser vacio';
    end if;
   	if trim(new.tipo_identificacion)='' then
            raise exception 'Tipo de identificación no puede ser vacio';
    end if;
    --validar el tamano de la identificacion dependiendo del tipo
    if(new.tipo_identificacion='Cedula')then
        if length(new.identificacion)<>10 then
                    raise exception 'Cedula requiere 10 digitos';
        end if;
    end if;
    if(new.tipo_identificacion='Ruc')then
        if length(new.identificacion)<>13 then
                    raise exception 'Ruc requiere 13 digitos';
        end if;
    end if;
    if(new.tipo_identificacion='Pasaporte')then
        if length(new.identificacion)<>12 then
                    raise exception 'Pasaporte requiere 12 digitos';
        end if;
    end if;
   --crear una exepcion cuando el correo que se quiere ingresar no pertenece a la UTEQ 
   --new.correo_institucional
    p_dominio := SUBSTRING(NEW.correo_institucional, strpos(NEW.correo_institucional, '@') + 1);
   --comparar el dominio 
   if p_dominio <>'uteq.edu.ec' then 
     raise exception 'El dominio del correo no pertenece a la empresa';
   end if;
   
return new;
end
$function$
;


select * from interfaz_usuario iu ;
select * from usuario u ;
--añadir un campo para saber si la cuenta es verificada o no skere modo diablo
--si no esta verificada entonces no dar paso al inicio de sesion 

alter table usuario
add column CuentaVerificada bool  default false;


ALTER TABLE usuario
ALTER COLUMN CuentaVerificada SET NOT NULL;


-- DROP FUNCTION public.verification_auth(varchar, varchar);

CREATE OR REPLACE FUNCTION public.verification_auth(email character varying, contra1 character varying)
 RETURNS TABLE(verification integer, mensaje character varying)
 LANGUAGE plpgsql
AS $function$
declare
	User_Deshabili bool;
	User_Exit bool;
	User_Verificado bool;
begin
	--Primero Verificar si el correo que se esta ingresando existe
	select into User_Exit case when COUNT(*)>=1 then True else false end  from usuario where correo_institucional=email;	
	select into User_Verificado CuentaVerificada from usuario where correo_institucional  = email 
			and  PGP_SYM_DECRYPT(contra ::bytea, 'SGDV_KEY') = contra1
   			and estado=true;
   	--verficiar que la cuenta este verificada 
   	if User_Verificado=false then 
   					return query
   					select cast(5 as int), cast('La cuenta no esta verificada' as varchar(500));
   	end if ;
	--Segundo  Verificar si el usuario tiene un estado habilitado o deshabilitado
	if (User_Exit) then 
		select into User_Deshabili estado from usuario where correo_institucional=email;
		if (User_Deshabili) then 
			return query
			select
			cast(case when COUNT(*)>=1 then 1 else 2 end as int),
			 cast(case when COUNT(*)>=1 then 'Login Correcto' else 'Contraseña incorrecta' end as varchar(500))
			from usuario
			where correo_institucional  = email 
			and  PGP_SYM_DECRYPT(contra ::bytea, 'SGDV_KEY') = contra1
   			and estado=true;
   		else 
   			return query
			select cast(3 as int), cast('Usuario deshabilitado contacte con un administrador' as varchar(500));
		end if;
	else 
	   		return query
			select cast(4 as int), cast('Este correo no esta registrado' as varchar(500));
	end if;
end;
$function$
;


select * from usuario u  ;
select * from interfaz_usuario iu ;

--funcion que retorne el id del usuario segun el correo ingresado 
--drop FUNCTION public.RetornoIDUserGmail(email character varying)
CREATE OR REPLACE FUNCTION public.RetornoIDUserGmail(email character varying)
 RETURNS TABLE( mensaje character varying, nombreUser character varying)
 LANGUAGE plpgsql
AS $function$
begin
   	return query
    select cast(id_user as character varying),nombres_apellidos  from usuario u where correo_institucional =email;
end;
$function$
;

select * from RetornoIDUserGmail('rcoelloc2@uteq.edu.ec');



--hacer una funcion para verificar la cuenta 

select * from usuario u 

call verificar_cuenta('3b43792d-ec18-49a5-b8af-753c65cb9b21');

CREATE OR REPLACE PROCEDURE public.verificar_cuenta
	(IN p_token character varying)
 LANGUAGE plpgsql
AS $procedure$
declare verification bool;
Begin
	--primero preguntar si esa cuenta existe para poderla modificar 
	select into verification case when COUNT(*)>0 then true else false end as Verification
	from usuario u where cast (u.id_user as character varying) =p_token;
	if verification then
	--hacer la veri	ficacion del usuario 
		update usuario set CuentaVerificada=true where cast (id_user as character varying) =p_token;
	else 
		--crear una exepcion porque el token del usuario no existe 
		 raise exception 'Este usuario no existe';
	end if;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	

END;
$procedure$
;


--aqui para agregar usuarios invitados a las seccion para que puedan crear niveles y preguntas
select * from secciones_usuario;

--funcion que retorne la lista de usuarios segun el id del test 




select * from participantes_test_id_test(54);

CREATE OR REPLACE FUNCTION public.participantes_test_id_test(p_id_seccion integer)
 RETURNS TABLE( toke_user character varying, nombreUser character varying, correo_user character varying, isadmin bool)
 LANGUAGE plpgsql
AS $function$
begin
   	return query
		select
		cast(u.id_user as character varying),
		u.nombres_apellidos ,
		u.correo_institucional ,
		u.isadmin
		from secciones_usuario su 
		inner join usuario u  on su.id_usuario =u.id_user 
		where su.id_seccion =p_id_seccion order by su.admin_seccion desc;
end;
$function$
;



select
		cast(u.id_user as character varying),
		u.nombres_apellidos ,
		u.correo_institucional ,
		u.isadmin
		from secciones_usuario su 
		inner join usuario u  on su.id_usuario =u.id_user 
		where su.id_seccion =54 order by su.admin_seccion desc;
	
--funcion que retorne la informacion del usuario con respecto a esa secion 
CREATE OR REPLACE FUNCTION public.informacion_seccion_usuario(p_id_seccion integer, p_id_usuario character varying)
 RETURNS table
 (isadmin bool)
 LANGUAGE plpgsql
AS $function$
begin
   	return query
		select 
		u.admin_seccion 
		from secciones_usuario u 
	   where u.id_seccion =p_id_seccion and 
       cast(u.id_usuario as character varying)=p_id_usuario;
end;
$function$
;


--funcion para eliminar a un participante de una seccion 


CREATE OR REPLACE PROCEDURE public.eliminar_usuario_seccion
	(IN p_token character varying, in p_id_seccion integer)
 LANGUAGE plpgsql
AS $procedure$
declare verification bool;
Begin
	delete from secciones_usuario where id_seccion=p_id_seccion and cast(id_usuario as character varying)=p_token;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	

END;
$procedure$
;

--funcion para buscar participantes y agregarlos a la seccion para crear preguntas y niveles 


--or (identificacion ILIKE '%' || p_palabra_clave || '%') or (numero_celular ILIKE '%' || p_palabra_clave || '%')) and estado

--buscar usuario por filtros 
--drop FUNCTION public.search_users(p_palabra_clave character varying)
CREATE OR REPLACE FUNCTION public.search_users(p_palabra_clave character varying)
 RETURNS table
 ( toke_user character varying,nombreuser character varying, correo_user character varying, isadmin bool )
 LANGUAGE plpgsql
AS $function$
begin
   	return query
		select cast (u.id_user as character varying),
		u.nombres_apellidos ,
		u.correo_institucional ,
		cast(false as bool)
		from usuario u where 
		(nombres_apellidos ILIKE '%' || p_palabra_clave || '%') or 
		(identificacion ILIKE '%' || p_palabra_clave || '%') or
		(correo_institucional ILIKE '%' || p_palabra_clave || '%') or
		(numero_celular ILIKE '%' || p_palabra_clave || '%') ;
end;
$function$
;

select * 
		from usuario u
select * from search_users('rcoello')

--agregar usuario a la seccion
select * from secciones_usuario su ;


CREATE OR REPLACE PROCEDURE public.agregar_usuario_seccion
	(IN p_token character varying, in p_id_seccion integer)
 LANGUAGE plpgsql
AS $procedure$
declare verification bool;
Begin
	delete from secciones_usuario where id_seccion=p_id_seccion and cast(id_usuario as character varying)=p_token;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ha ocurrido un error en la transacción principal: %', SQLERRM;	

END;
$procedure$
;

