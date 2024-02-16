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
				/*
				select p.id_pregunta , p.id_nivel 
				INTO p_id_pregunta_seleccionada , p_id_nivel from preguntas p 
                inner join niveles n on p.id_nivel = n.id_nivel
                inner join secciones s on n.id_seccion = s.id_seccion
                inner join respuestas r on p.id_pregunta =r.id_pregunta 
                where s.id_seccion = p_id_seccion and n.nivel = i and r.correcta
                ORDER BY random()
				LIMIT 1; */ 
				
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
