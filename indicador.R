# carga resultados del paso procesar.R y genera indicadores

library(dplyr)
library(readr)

# cargar datos
datos <- readr::read_csv2("datos/mineduc_matriculas_superior.csv")

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
  select(-comuna, -region) |> 
  relocate(nombre_region, codigo_region, .after = codigo_comuna) |> 
  mutate(codigo_comuna = as.numeric(codigo_comuna),
         codigo_region = as.numeric(codigo_region))


datos5

# guardar el proyecto
readr::write_csv2(datos5, "/Users/baolea/R/subdere/indice_brechas/datos/mineduc_matriculas_superior.csv")


