# Estructura de Computadores I
En esta práctica final se implementará, en lenguaje ensamblador del 68K, un
programa que emule la ejecución de programas escritos para una máquina elemental dada.
Estos programas deberán estar escritos usando el conjunto de instrucciones de la
máquina en cuestión, y el emulador deberá funcionar para cualquier programa que respete
dicho conjunto. Para llevar a cabo esta emulación, todas las partes de la máquina elemental se
definirán en la memoria del 68K. Por un lado, el programa debe ser capaz de leer de la memoria
del 68K una secuencia de instrucciones codificadas como words, de acuerdo al conjunto de
instrucciones de la propia máquina elemental. Para cada una de estas instrucciones, el programa
aplicará un proceso de decodificación para determinar de qué instrucción del conjunto se trata
y, a continuación, emulará su ejecución. Debido a que la máquina elemental dada está diseñada
siguiendo una arquitectura Von Neumann, junto con las instrucciones que forman el programa
también se almacenarán los datos. Por otro lado, además de la memoria para el programa y los
datos, el emulador también reservará una serie de posiciones de memoria en el 68K para
representar todos los registros de la máquina elemental a emular, así como un registro de
estado que contendrá los flags. 
