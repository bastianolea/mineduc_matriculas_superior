library(dplyr)
library(readr)

# obtener ruta del archivo
# (porque como el nombre de archivo tiene fecha, puede que el nombre cambie)
ruta_archivo <- list.files("datos/datos_originales/", full.names = T) |> stringr::str_subset("csv")

# cargar datos
datos <- read_csv2(ruta_archivo, locale = locale(encoding = "latin1"))

datos2 <- datos |> 
  janitor::clean_names() |> 
  rename(año = 1)

# datos2 |> glimpse()

# guardar ----
write_csv2(datos2, "datos/mineduc_matriculas_superior.csv")
writexl::write_xlsx(datos2, "datos/mineduc_matriculas_superior.xlsx")
