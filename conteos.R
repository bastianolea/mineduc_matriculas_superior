datos2 |> glimpse()
datos2 |> count(clasificacion_institucion_nivel_1)



# Cobertura Educación Superior ----
# Cuantificar la cantidad de estudiantes matriculados activos en la educación terciaria respecto del total de la población en edad típica de ingreso en el territorio.	
# Población a nivel territorial que cuenta con matrícula vigente en la educación superior respecto del total de la población activa del territorio.

# total matriculados por comuna
datos2 |> 
  group_by(año, region, provincia, comuna) |> 
  summarise(total_matriculados = sum(total_matriculados))

# matriculados por comuna por género
datos2 |> 
  group_by(año, region, provincia, comuna) |> 
  summarise(
    across(c(matriculados_mujeres_por_programa, 
             matriculados_no_binario_por_carrera, 
             matriculados_hombres_por_programa, 
             total_matriculados),
           \(variable) sum(variable, na.rm = TRUE)
    )
  )

# Cobertura en Educación Superior según dependencia del establecimiento de origen y territorio ----
# Caracterizar factores institucionales y territoriales en el acceso a la educación terciaria	
# Mide la proporción de estudiantes que ingresan a la educación superior tras egresar de establecimientos escolares, desagregando los datos según el tipo de dependencia administrativa del establecimiento de origen (como público, subvencionado o privado) y la región o territorio en la que se ubica dicho establecimiento. Por tanto, busca analizar patrones de acceso a la educación superior considerando factores institucionales y territoriales.

# matriculados según establecimiento de origen
datos2 |> 
  group_by(año, region, provincia, comuna) |> 
  summarise(
    across(c(total_tes, starts_with("tes_")), 
           \(variable) sum(variable, na.rm = TRUE)
    )
  )

