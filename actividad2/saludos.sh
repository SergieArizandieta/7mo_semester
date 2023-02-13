#!/bin/bash
#Lo anterior es Shebang

#NOTA** JQ debe estar instalado
# sudo apt-get install jq 

#puede haberlo dejado desconemntado para que no importe quien lo vea lo instale
#Pero siento que es muy intrusivo asi que lo comente

GITHUB_USER=""
echo "---------------------------------------"
echo "---------------------------------------"
echo "Ingresa tu nombre de usuario de GitHub:"
read GITHUB_USER
echo "---------------------------------------"

response=$(curl -sL https://api.github.com/users/$GITHUB_USER) #Get con curl

if [ "$(echo $response | jq -r '.message')" != "Not Found" ]; then #Validando que el mensaje de repuesta no sea Not Found
  
   #Concatenendo mensaje con User, ID, Created_at
   msg="Hola $GITHUB_USER User ID: $(echo $response | jq -r '.id'). La cuentaa fue creada el: $(echo $response | jq -r '.created_at')" 
   echo -e "\e[0;36m$msg\e[0m" #Imprimiendo el mensaje generado

   crr_path="/tmp/$(date +%Y-%m-%d)" #Concatenando el path donde se escribira 

   mkdir -p $crr_path  #Creando las carpetas si estas no existieran
   echo $msg >> "$crr_path/saludos.log" #Agreagando al contenido anterior el mensaje creado (crea el .log de ser necesario)
   
else
   echo -e "\e[0;31mNo se puedo obtener informacion sobre: $GITHUB_USER\e[0m" #Imprimiendo si el usuario ingresado no existiera
fi