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
insert into tipos_preguntas (titulo, descripcion, 
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
	select pt.id_participante_test ,cast(to_char(pt.fecha_add,'DD-MON-YYYY')as varchar(500)) as Fecha
		,pt.supero_limite ,pt.estado ,
		cast(p.id_participante as varchar(800)) as id_participante ,p.correo_institucional ,p.nombres_apellidos ,p.tipo_identificacion ,p.identificacion ,p.numero_celular
	from participantes_test pt 
	inner join participantes p on pt.id_participante =p.id_participante 
	where pt.id_test =p_id_test;
end;
$function$
;



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
	select cast(id_participante as varchar(500)), correo_institucional, nombres_apellidos, tipo_identificacion, identificacion, 
	numero_celular
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







							