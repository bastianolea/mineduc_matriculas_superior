# https://www.mifuturo.cl/bases-de-datos-de-matriculados/

library(rvest)
library(dplyr)
library(stringr)

# obtener datos desde el sitio web
sitio <- session("https://www.mifuturo.cl/bases-de-datos-de-matriculados/") |> 
  read_html()

elementos <- sitio |> 
  html_elements(".col-content") |> 
  html_elements("a")

texto <- elementos |> html_text()
enlace <- elementos |> html_attr("href")

tabla_enlaces <- tibble(texto, enlace)

# extraer enlace correcto
archivo <- tabla_enlaces |>
  filter(str_detect(texto, "2024")) |> 
  filter(!str_detect(texto, "2007")) |> 
  pull(enlace)

# definir ruta donde guardar el archivo
dir.create("datos")
dir.create("datos/datos_originales")

ruta <- paste0("datos/datos_originales/", str_extract(archivo, "MAT.*zip"))

# descargar
download.file(archivo,
              ruta)

# descomprimir
unzip(ruta, exdir = "datos/datos_originales/")
