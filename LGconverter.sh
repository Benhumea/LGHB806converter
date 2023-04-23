#!/bin/bash

# Solicitar la ruta
read -p "Introduce la ruta de búsqueda: " ruta

# Solicitar un numero de videos a convertir
read -p "Cuantos videos quieres seleccionar:" seleccion

# Buscar los archivos de video en la ruta y subcarpetas
videos=$(find "$ruta" -type f -name "*.mp4" -o -name "*.mkv" -o -name "*.avi")

# Seleccion de n cantidad de videos al azar
selected_videos=($(echo "$videos" | shuf -n "$seleccion"))

# Directorio donde se guardaran los videos codificados
videos_path="$HOME/LGtelevision"

# Eliminar archivos antiguos si existen
if [[ -d "$videos_path" ]] && [[ "$(ls -A "$videos_path")" ]]; then
  read -p "Ya existen archivos en $videos_path. ¿Está seguro que desea eliminarlos y continuar? [S/n]: " confirmacion
  if [[ "$confirmacion" == "S" ]] || [[ "$confirmacion" == "s" ]]; then
    rm -r "$videos_path"/*
  else
    echo "Proceso abortado."
    exit 1
  fi
fi

mkdir -p "$videos_path"
i=1
for video in "${selected_videos[@]}"; do
  output_name="LGtelevision$(printf '%04d' "$i").mp4"
  ffmpeg -i "$video" -c:v libx264 -crf 20 -preset slow -vf "scale=-2:720,setsar=1" -c:a aac -b:a 128k -ac 2 "$videos_path/$output_name"
  echo "Convertido $output_name"
  ((i++))
done

echo "Proceso finalizado."
