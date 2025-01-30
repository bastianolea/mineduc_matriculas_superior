# carga resultados del paso procesar.R y genera indicadores

library(dplyr)
library(readr)
library(pins)

# cargar datos
datos <- read_csv2("datos/mineduc_matriculas_superior.csv")

# limpiar datos
datos1 <- datos |> 
  # corregir comunas
  mutate(comuna = recode(comuna,
                         "AISEN" = "AYSEN",
                         "COIHAIQUE" = "COYHAIQUE",
                         "LA CALERA" = "CALERA"))

# filtrar datos
datos2 <- datos1 |> 
  filter(nivel_global == "Pregrado",
         año == "MAT_2024")

# seleccionar variables
datos3 <- datos2 |> 
  select(region, provincia, comuna, 
         matriculados = total_matriculados,
         starts_with("tes_"))

datos2 |> glimpse()

# sumar por comuna
datos4 <- datos3 |> 
  group_by(region, comuna) |> 
  summarize(matriculados = sum(matriculados, na.rm = TRUE),
            across(starts_with("tes_"), ~sum(.x, na.rm = TRUE))) |> 
  ungroup()


# cargar códigos únicos territoriales
cut_comunas <- read_csv2("datos/datos_externos/cut_comuna.csv") |> 
  mutate(comuna = nombre_comuna |> toupper() |> 
           stringr::str_replace_all(c("Á"="A", "É"="E", "Í"="I", "Ó"="O", "Ú"="U")))

# agregar códigos únicos territoriales
datos5 <- datos4 |> 
  # unir datos de cut
  left_join(cut_comunas,
            by = join_by(comuna), 
            relationship = "one-to-one") |> 
  relocate(nombre_comuna, .after = comuna) |> 
  relocate(codigo_comuna, .after = nombre_comuna) |> 
  select(-comuna) |> 
  mutate(codigo_comuna = as.numeric(codigo_comuna))


# cargar población
# proyeccion_2024 <- board |> pin_read("censo_proyeccion_2024")
poblacion_ed_superior <- read_csv2("datos/datos_externos/censo_proyecciones_ed_superior.csv")
# desde https://github.com/bastianolea/censo_proyecciones_poblacion

# # agregar población
# datos6 <- datos5 |> 
#   left_join(proyeccion_2024 |> 
#               select(cut_comuna, poblacion = población), 
#             by = join_by(codigo_comuna == cut_comuna),
#             relationship = "one-to-one") |> 
#   relocate(poblacion, .after = matriculados)
# # aquí tendría que ser "población activa"

# agregar población
datos6 <- datos5 |> 
  left_join(poblacion_ed_superior |> 
              filter(año == 2024) |> 
              select(cut_comuna, poblacion_ed_superior = pob_activa, poblacion_ed_superior_p = ed_superior_porcentaje), 
            by = join_by(codigo_comuna == cut_comuna),
            relationship = "one-to-one") |> 
  relocate(starts_with("poblacion_ed"), .after = matriculados)



# cobertura educación superior ----

# calcular tasa
tasa_matriculados <- datos6 |> 
  mutate(tasa_matriculados = matriculados/poblacion_ed_superior*1000) |> 
  relocate(tasa_matriculados, .before = matriculados) |> 
  select(codigo_comuna, nombre_comuna, nombre_region, codigo_region, 
         contains("matriculados"), contains("poblacion"))

# guardar 
write_rds(tasa_matriculados, "/Users/baolea/R/subdere/indicadores/mineduc_matriculados.rds")



# cobertura en educación superior según dependencia del establecimiento de origen ----

# calcular tasa
tasa_matriculados_establecimiento <- datos6 |> 
  mutate(across(starts_with("tes_"), ~.x/poblacion_ed_superior*1000, 
                .names = "tasa_{.col}")) |> 
  relocate(starts_with("tasa_"), .after = matriculados)

tasa_matriculados_establecimiento

# guardar 
write_rds(tasa_matriculados_establecimiento, "/Users/baolea/R/subdere/indicadores/mineduc_matriculados_establecimiento.rds")