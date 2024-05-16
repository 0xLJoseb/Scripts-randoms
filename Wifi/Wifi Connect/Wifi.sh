#!/bin/bash


# Author: Josesito

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c(){

	echo -e "\n${yellowColour}[*]${endColour}${grayColour}Saliendo...${endColour}"
  systemctl restart NetworkManager
  rm wpa_suppl* 2>/dev/null

 	exit 0
}

function banner (){

echo "                                  "
echo " ▄▄▄██▀▀▀▒█████    ██████ ▓█████  ▄▄▄▄   "
sleep 0.05
echo "   ▒██  ▒██▒  ██▒▒██    ▒ ▓█   ▀ ▓█████▄ "
sleep 0.05
echo "   ░██  ▒██░  ██▒░ ▓██▄   ▒███   ▒██▒ ▄██"
sleep 0.05
echo "▓██▄██▓ ▒██   ██░  ▒   ██▒▒▓█  ▄ ▒██░█▀  "
sleep 0.05
echo " ▓███▒  ░ ████▓▒░▒██████▒▒░▒████▒░▓█  ▀█▓"
sleep 0.05
echo " ▒▓▒▒░  ░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░░░ ▒░ ░░▒▓███▀▒"
sleep 0.05
echo " ▒ ░▒░    ░ ▒ ▒░ ░ ░▒  ░ ░ ░ ░  ░▒░▒   ░ "
sleep 0.05
echo " ░ ░ ░  ░ ░ ░ ▒  ░  ░  ░     ░    ░    ░ "
sleep 0.05
echo " ░   ░      ░ ░        ░     ░  ░ ░      "
sleep 0.05
echo "                                       ░ "


}

function helpPanel(){
	echo -e "\n${yellowColour}[*]${endColour}${grayColour}Uso: ./WifiConnect.sh\n${endColour}"
	echo -e "\t${purpleColour}[-o]${endColour}${yellowColour} Escoja una opcion:${endColour}\n"
	echo -e "\t\t${redColour}• consultar${endColour}"
	echo -e "\t\t${redColour}• conectar${endColour}"
  echo -e "\t\t${redColour}• reset${endColour}\n"

	
	echo -e "\t${purpleColour}[-h]${endColour}${yellowColour} Para mostrar este panel de ayuda${endColour}\n"
exit 0
}

function startFunction(){
		clear 
	
  if [ "$(echo $options)" == "reset" ]; then

    clear
    echo -ne "${redColour}A continuacion se ejecutaran algunos comandos para solucionar posibles errores\n${endColour}"
    sleep 1; 
    echo -ne "\n${yellowColour}A continuacion se listaran sus tarjetas de red\n${endColour}"; iwconfig  
    echo -ne "${yellowColour}Inserte el nombre de la tarjeta de red a analizar: ${endColour}" && read networkCardDiag
    echo -ne "\n${greenColour}Espere un momento...${endColour}"
    systemctl stop NetworkManager
    systemctl restart NetworkManager
    ifconfig ${networkCardDiag} down > /dev/null 2>&1
    
    if [ "$(echo $?)" == "0" ]; then

        sleep 2;
        ifconfig ${networkCardDiag} up
        echo -ne "\n${greenColour}Perfecto!${endColour}\n"
        echo -ne "${purpleColour}Intente utilizar nuevamente la opcion${endColour}${yellowColour} [consultar] ${endColour}${purpleColour}de este script${endColour}"

    else
        echo -ne "\n${redColour}Algo ha salido mal.${endColour}"
        echo -ne "\n${yellowColour}La tarjeta de red ingresada si existe?${endColour}"
    fi


	elif [ "$(echo $options)" == "consultar" ]; then
    echo -ne "En seguida apareceran aquellas redes Wifi a las que puede conectarse: \n"
    sudo iwlist scan | grep ESSID | sort -u
    echo -ne "\n${turquoiseColour}Si no ve nada en pantalla es posible que ninguna de sus tarjetas de red sea inalambrica.${endColour}"
    echo -ne "\n${redColour}Si se presenta algun otro inconveniente intente utilizando la opcion${endColour}${yellowColour} [reset] ${endColour}${redColour}de este script${endColour}"

    echo -ne "\n${yellowColour}La informacion se eliminara de la pantalla en ${endColour}${redColour}5 segundos${endColour}" ;sleep 15; clear


	elif [ "$(echo $options)" == "conectar" ]; then
		clear
    echo -ne "\n${yellowColour}A continuacion se listaran sus tarjetas de red:${endColour}\n "
    iwconfig
    sleep 3

    echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Nombre de la interfaz de red a utilizar: ${endColour}" && read networkCard
    echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Nombre de la red a conectarse [ESSID]: ${endColour}" && read ESSID
		echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Contraseña de la red: ${endColour}" && read Passwd
    
    wpa_passphrase ${ESSID} ${Passwd} > wpa_supplicant.conf
    echo -ne "${yellowColour}wpa_supplicant.conf ha sido creado ${endColour}${greenColour}exitosamente -->${endColour}\n"
    more wpa_supplicant.conf
    sleep 2; echo -ne "\n..."; echo -ne "\n..";
    systemctl stop NetworkManager
    sudo wpa_supplicant -c wpa_supplicant.conf -i ${networkCard} -B -Dnl80211 > /dev/null 2>&1

    if [ "$(echo $?)" == "0" ]; then
        sleep 2; rm wpa_supplicant.conf

		    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Iniciando proceso de asignacion de IP...${endColour}\n"
        sleep 2
			  echo -ne "\nEsto podria tardar un momento...\n"
        sudo dhclient ${networkCard} 
         echo -ne "${greenColour}Ahora deberia encontrarse conectado a la red!${endColour}"


		else

			echo -e "\n${redColour}[!]${endColour}${grayColour} No se ha logrado realizar la conexion...${endColour}\n"
      echo -e "\n${redColour}[!]${endColour}${grayColour} Nombre de red, tarjeta de red y contraseña son correctos?${endColour}\n" 
			rm wpa_supplicant.conf; sleep 2
		fi

	else
			echo -e "\n${redColour}[*]${endColour}${grayColour} Esta opcion no es válida${endColour}\n"
			
	fi

}

# Main Function

if [ "$(id -u)" == "0" ]; then

 declare -i	parameter_counter=0; while getopts "o:h:" arg; do
	  	  case $arg in

		  	  o) options=$OPTARG; let parameter_counter+=1 ;;
		  	  h) helpPanel;;
	  	  
        esac

    done

	  if [ $parameter_counter -ne 1 ]; then
		
      banner
		  helpPanel

	  else

		  startFunction
		
	  fi

else
	echo -e "\n${redColour}No soy root${endColour}\n"
fi
