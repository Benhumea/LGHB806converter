#!/bin/bash

echo "
 __      __        .__   __   .__ 
/  \    /  \_____  |  | |  | _|__|
\   \/\/   /\__  \ |  | |  |/ /  |
 \        /  / __ \|  |_|    <|  |
  \__/\  /  (____  /____/__|_ \__|
       \/        \/          \/   
LGconverter 1.0 beta
"

sleep 1

function random_converter {
    # Solicitar la ruta
    read -p "Introduce la ruta de búsqueda: " ruta

    # Muestra el numero de videos disponibles en la ruta especificada
    num_videos=$(find "$ruta" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.wmv" -o -name "*.m4v" -o -name "*.flv" -o -name "*.3gp" -o -name "*.mpg" -o -name "*.mpeg" -o -name "*.webm" -o -name "*.ogv" -o -name "*.vob" -o -name "*.mp2" -o -name "*.m2v" -o -name "*.mpv" -o -name "*.divx" -o -name "*.xvid" -o -name "*.asf" -o -name "*.qt" -o -name "*.rm" -o -name "*.rmvb" -o -name "*.ts" -o -name "*.mxf" -o -name "*.asf" -o -name "*.mpg4" -o -name "*.mpe" -o -name "*.swf" -o -name "*.drc" -o -name "*.nut" \) | wc -l)
    echo "Disponemos de  $num_videos archivos de video en la ruta $ruta."

    # Solicitar un numero de videos a convertir
    read -p "Cuantos videos quieres seleccionar: " seleccion

    # Buscar los archivos de video en la ruta y subcarpetas
    videos=$(find "$ruta" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \))

    # Seleccion de n cantidad de videos al azar con mayor aleatoriedad
    while true; do
        selected_videos=($(echo "$videos" | tr ' ' '\n' | shuf -rn "$seleccion" | tr '\n' ' '))
        echo "Se han seleccionado $seleccion videos del directorio $ruta."
        if grep -qFf <(printf '%s\n' "${selected_videos[@]}") "$HOME/seleccionDiaria.list"; then
            echo "Algunos de los archivos seleccionados ya existen en seleccionDiaria.list. Seleccionando otros."
        else
            break
        fi
    done

    # Guardar lista de videos seleccionados
    videos_path="$HOME/seleccionDiaria.list"
    printf '%s\n' "${selected_videos[@]}" >> "$videos_path"

    echo "La lista de videos seleccionados se ha guardado en $videos_path."
}

function simple_converter {
    # Solicitar la ruta
    read -p "Introduce la ruta de búsqueda: " ruta

    # Solicitar la cantidad de videos a convertir
    read -p "¿Cuántos videos quieres convertir? Escribe 'all' si deseas convertir todos los videos de la ruta: " cantidad
    if [ "$cantidad" == "all" ]; then
    videos=$(find "$ruta" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \))
    selected_videos=($videos)
    echo "Se van a convertir todos los videos de la ruta $ruta."
else
    read -p "Introduce el número de videos a convertir: " seleccion
    videos=$(find "$ruta" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \))
    selected_videos=($(echo "$videos" | tr ' ' '\n' | shuf -rn "$seleccion" | tr '\n' ' '))
    echo "Se han seleccionado $seleccion videos del directorio $ruta."
fi

# Directorio donde se guardarán los videos codificados
videos_path="$HOME/LGtelevision"

# Eliminar archivos antiguos si existen
if [[ -d "$videos_path" ]] && [[ "$(ls -A "$videos_path")" ]]; then
    read -p "Ya existen archivos en $videos_path. ¿Estás seguro de que deseas eliminarlos y continuar? [S/n]: " confirmacion
    if [[ "$confirmacion" == "S" ]] || [[ "$confirmacion" == "s" ]]; then
        rm -r "$videos_path"/*
    else
        echo "Proceso abortado."
        exit 1
    fi
fi

mkdir -p "$videos_path"

# Función de conversión de video
for video in "${selected_videos[@]}"; do
    output_name=$(basename "$video")
    ffmpeg -i "$video" -c:v libx264 -crf 20 -preset slow -vf "scale=-2:720,setsar=1" -c:a aac -b:a 128k -ac 2 -loglevel panic -n "$videos_path/$output_name"
    echo "Convertido $output_name"
done

echo "Proceso finalizado."
}
Menú principal

while true; do
echo "Selecciona una opción:"
echo "1. Conversor aleatorio"
echo "2. Conversor simple"
echo "3. Salir"
read -p "Opción: " opcion

case $opcion in
    1)
        random_converter
        ;;
    2)
        simple_converter
        ;;
    3)
        echo "Saliendo del programa."
        exit 0
        ;;
    *)
        echo "Opción inválida. Inténtalo de nuevo."
        ;;
esac
