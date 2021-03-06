#Creado por: Juan Hernández Sánchez
#Fecha: 03/11/2016
#Materia: Almacenamiento de datos y su administración

system("defaults write org.R-project.R force.LANG en_US.UTF-8")
#El directorio de trabajo debe ser cambiado dependiendo del sistema operativo:
#MAC: /Users/DirectorioDeTrabajo
#Windows: C:/DirectorioDeTrabajo
#Para ejecutar el siguiente código, es necesario contar con privilegios de administrador
#para entornos Windows es suficiente con ejecutar el programa R con permisos de administrador
#para entornos Unix como es el caso de Mac, se debe ejecutar el siguiente comando: sudo chmod -R 777 /Users  
#en una terminal e ingresar la contraseña del usuario administrador.

packUtils<-"utils"
packRutils<-"R.utils"

#Declaración de constantes
PACKAGES<-c(packUtils,packRutils)
wd <- "/Users/DirectorioDeTrabajo"
Descargas <- "/Users/DirectorioDeTrabajo/Descargas/"
Archivos <- "/Users/DirectorioDeTrabajo/Archivos/"
extension=".gz"
rutaDescarga="http://www1.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/"
file1="StormEvents_fatalities-ftp_v1.0_d1985_c20160223.csv"
file2="StormEvents_fatalities-ftp_v1.0_d1986_c20160223.csv"
file3="StormEvents_fatalities-ftp_v1.0_d1987_c20160223.csv"
file4="StormEvents_fatalities-ftp_v1.0_d1988_c20160223.csv"
file5="StormEvents_fatalities-ftp_v1.0_d1989_c20160223.csv"
file6="StormEvents_fatalities-ftp_v1.0_d1990_c20160223.csv"
file7="StormEvents_fatalities-ftp_v1.0_d1991_c20160223.csv"
file8="StormEvents_fatalities-ftp_v1.0_d1992_c20160223.csv"
file9="StormEvents_fatalities-ftp_v1.0_d1993_c20160223.csv"
file10="StormEvents_fatalities-ftp_v1.0_d1994_c20160223.csv"
fileExt <- ""
rutaGunzip <- "" 
archivosParaDescomprimir<-FALSE

#Se inicia validando si los paquetes a utilizar se encuentran disponibles en la sesión, si no es así, se instalan y cargan
for (package in PACKAGES ) {
  if (!require(package, character.only=T, quietly=T)) {
     install.packages(package, repos="https://cran.itam.mx/")
     library(package, character.only=T)
  }else{ print('El paquete se encuentra cargado')}
  }

#Validar si existe el directorio de trabajo
if( !dir.exists(wd) ) {
  #Se ha crea y establece el directorio de trabajo
  dir.create(file.path(wd), recursive=TRUE)
  print("Directorio de trabajo creado correctamente") 
    setwd(wd)
    
  } else {
    #Si ya existe el directorio de trabajo, sólo se asigna para trabajar sobre él
    print("Ya existe el directorio de trabajo")
    setwd(wd)
  }
#Validar si existe la carpeta de descargas donde se guardarán los archivos comprimidos
if( !dir.exists(Descargas) ) {
  #Se crea la carpeta de descargas para archivos .gz
  dir.create(file.path(Descargas), recursive=TRUE) 
  print('Se ha creado la carpeta Descargas')  
  }else{
    print('Ya existe la carpeta Descargas')
  }
#Validar si existe la carpeta de los archivos csv
if( !dir.exists(Archivos) ) {
  #Se crea la carpeta donde se guardaran los archivos descomprimidos .csv
  dir.create(file.path(Archivos), recursive=TRUE) 
  print('Se ha creado la carpeta Archivos')
 }else{
   print('Ya existe la carpeta Archivos')
 } 

#Se crea un vector con los nombres de los archivos
FILES = c(file1,file2,file3,file4,file5,file6,file7,file8,file9,file10)

#Validación de la existencia de los archivos en las carpetas locales

for( file in FILES ){
  # Se valida si el archivo descompactado ya existe en el área de datos.
  setwd(Archivos)
   if( ! file.exists( file )) {
    # Si no existe se busca el archivo compactado en el área de descarga.
      #No existe en la carpeta de archivos
      #Buscando en descargas
      setwd(Descargas)
      fileExt <- paste(file,extension,sep="")#arc.gz
      print('El archivo .csv no existe, se busca en Descargas')
      if( ! file.exists( fileExt ) && !fileExt=="") {
        print('El archivo .gz no existe en Descargas, se procede a obtenerlo del repositorio en linea')
      # Si no existe en ela carpeta de Descargas, se procede a descargar el archivo
        fileLink <- paste(rutaDescarga,fileExt,sep="") 
        rutaGunzip<-paste(Descargas,fileExt,sep="") 
        rutaArchivoDescargado <- paste(Descargas,fileExt,sep="") 
         download.file(fileLink,rutaArchivoDescargado)
         #Al finalizar el ciclo se descomprimen todos los archivos descargados
         archivosParaDescomprimir<-TRUE
      } else {
         #Existe el archivo en la carpeta de descargas, solo se descomprime en 'Archivos'
         print('El archivo .gz si existe en Descargas, se descomprime en Archivos')
         setwd(Descargas)
         rutaGunzip<-paste(Archivos,file,sep="")
         gunzip(fileExt,rutaGunzip,overwrite = FALSE, remove=FALSE)
     }
   } 
}

if(archivosParaDescomprimir){
  print('Existen archivos para descomprimir, se procede con la extracción en la carpeta Archivos')
  setwd(Descargas)
  for( file in FILES ){
    fileExt<- paste(file,extension,sep="")
    rutaGunzip<-paste(Archivos,file,sep="")
    gunzip(fileExt,rutaGunzip,overwrite = FALSE, remove=FALSE)
  }
}
#Se empieza a trabajar con los datos obtenidos
setwd(Archivos)
#######################
#A continuación se presenta la cantidad de registros por cada archivo:
for( file in FILES ){
  print(nrow(read.csv(file, header = TRUE, sep = ",")))
}
#######################

#Se juntan todos los archivos csv en 'Fatalities'
for( file in FILES ){
    if( !exists("Fatalities" ) ) {
        Fatalities<-read.csv( file, header=T, sep=",", na.strings="")
    } else {
        data<-read.csv(file, header=T, sep=",", na.strings="")
        Fatalities<-rbind(Fatalities,data)
    }
}
#Tomando en cuenta todos los archivos, el numero total de registros es:
nrow(Fatalities)
#Se eliminan los temporales
rm(Fatalities)
rm(data)
