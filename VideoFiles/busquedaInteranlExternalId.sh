#!/bin/bash

#Variables de rutas y paths
RAW_PATH='/var/raw/'
BUILDING_PATH=$RAW_PATH'building/'
PUBLISHED_PATH=$RAW_PATH'published/'
TEST_PATH='./raw/'
OUTPUT_PATH='xml_files/'
EXTERNAL_INTERNAL_ID_FILE="external_internal_id_file.txt"
CURRENT_DIR=$(pwd)

#Variables de archivos
SUFIJO='.tar'

# Declaramos los arrays
path_array[0]=$RAW_PATH
path_array[1]=$BUILDING_PATH
path_array[2]=$PUBLISHED_PATH

# Podemos combinar los arrays con bucles utilizando
for x in ${path_array[*]}; do
    #Declaramos el path para trabajar
    WD_PATH=${x}

    #Ejecutamos el comando
    LISTA=$(find $WD_PATH -type f -printf "%f\n")

    #Nos cambiamos para sacar el archivo
    cd $OUTPUT_PATH

    # imprimir_encabezado "IMPRIMIMOS NOMBRE DE LOS ARCHIVOS"
    for item in $LISTA; do

        #Verificamos si existe el archivo
        if [[ ! -f $WD_PATH$item ]]; then
            continue
        fi

        #Verificamos si es un archivo tar
        if [[ ! $item =~ $SUFIJO ]]; then
            #echo "False"
            continue
        fi

        #Quitamos el sufijo tar
        string=$item

        #Verificamos si el elmento lo tenemos en la lista
        cleanItem=${string/%$SUFIJO/}
        
        
        #Verificamos si existe el archivo
        if [[ ! -f $EXTERNAL_INTERNAL_ID_FILE ]]; then
            #echo "El carchivo no existe."
            touch $EXTERNAL_INTERNAL_ID_FILE
        fi

        c=$(grep -n $cleanItem "./"$EXTERNAL_INTERNAL_ID_FILE | wc -l)

        #Verificamos si existe el directorio
        if [[ ! $c -gt 0 ]]; then

            #Ejecutamos la extraccion de los archivos xml
            tar -xvf $WD_PATH$item --wildcards --no-anchored '*events.xml*'

            #Obtenemos los ids de la grabacion
            externalId=$(sed -ne 's/.*externalId=//gp' ./$cleanItem/events.xml | sed 's/\s.*$//' | sed 's/"//g')
            internalId=$(sed -ne 's/.*meeting\ id=//gp' ./$cleanItem/events.xml | sed 's/\s.*$//' | sed 's/"//g')

            #Definimos la linea de llave valor
            key_value_line="External: "$externalId" Internal: "$internalId

            #Eliminamos el archivo creado
            rm -R ./$internalId

            #Agregamos la linea
            echo $key_value_line >>$EXTERNAL_INTERNAL_ID_FILE
        fi
    done

    #Nos regresamos a la carpeta original
    cd $CURRENT_DIR

done
