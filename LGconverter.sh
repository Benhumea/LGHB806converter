#!/bin/bash

# Solicitar la ruta
read -p "Introduce la ruta de búsqueda: " ruta

# Muestra el numero de videos disponibles en la ruta especificada
num_videos=$(find "$ruta" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.wmv" -o -name "*.m4v" -o -name "*.flv" -o -name "*.3gp" -o -name "*.mpg" -o -name "*.mpeg" -o -name "*.webm" -o -name "*.ogv" -o -name "*.vob" -o -name "*.mp2" -o -name "*.m2v" -o -name "*.mpv" -o -name "*.divx" -o -name "*.xvid" -o -name "*.asf" -o -name "*.qt" -o -name "*.rm" -o -name "*.rmvb" -o -name "*.ts" -o -name "*.mxf" -o -name "*.asf" -o -name "*.mpg4" -o -name "*.mpe" -o -name "*.swf" -o -name "*.drc" -o -name "*.nut" \) | wc -l)
echo "Disponemos de  $num_videos archivos de video en la ruta $ruta."


# Solicitar un numero de videos a convertir
read -p "Cuantos videos quieres seleccionar:" seleccion

# Buscar los archivos de video en la ruta y subcarpetas
videos=$(find "$ruta" -type f -name "*.mp4" -o -name "*.mkv" -o -name "*.avi")


# Seleccion de n cantidad de videos al azar con mayor aleatoriedad
while true; do
  selected_videos=($(echo "$videos" | tr ' ' '\n' | shuf -rn $seleccion | tr '\n' ' '))
  echo "Se han seleccionado $seleccion videos del directorio $ruta. Se guardará una lista de los videos seleccionados en $videos_path."
  if grep -qFf <(printf '%s\n' "${selected_videos[@]}") "$HOME/seleccionDiaria.list"; then
    echo "Algunos de los archivos seleccionados ya existen en seleccionDiaria.list. Seleccionando otros."
  else
    break
  fi
done


# Crea una lista de los videos que se convirtieron en la secion
echo "$(date '+%A, %B %d, %Y %r')" >> "$HOME/seleccionDiaria.list"
echo "${selected_videos[@]/%/$'\n'}" >> "$HOME/seleccionDiaria.list"


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
# Funcion de conversion de video a un formato que soprte el dispositivo LG HB806

i=1
for video in "${selected_videos[@]}"; do
  #La siguiente linea renombra el archivo de salida a la cadena LGtelevisiony una cadena de 4 caracteres consecutivos
  output_name="$(basename "$video")"
  ffmpeg -i "$video" -c:v libx264 -crf 20 -preset slow -vf "scale=-2:720,setsar=1" -c:a aac -b:a 128k -ac 2 -loglevel panic -n "$videos_path/$output_name"
  echo "Convertido $output_name"
  ((i++))
done

echo "Proceso finalizado."

