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

select * from verification_auth('rcoelloc2@uteq.edu.ec','123456')

--Funcion para retornar los datos del inicio de sesion como los nombres, etc 
CREATE OR REPLACE FUNCTION public.auth_data(email character varying, contra1 character varying)
 RETURNS TABLE(userd character varying, verification boolean)
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select cast(ID_User as varchar(500)) as UserT  from usuario where correo_institucional  = email;
end;
$function$
;
