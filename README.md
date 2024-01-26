# Italiano
## csv_to_kml
Uno script in Ruby per convertire dinamicamente da csv a kml, geocodificando le coordinate dall'inidirizzo completo. È NECESSARIA UNA CHIAVE API PER MAPS
Non hai bisogno di un file CSV strutturato come con altri tool! Basta dire allo script come saranno le colonne per il nome e l'indirizzo, e lo script estrarrà il resto per te.

### Installazione 
1. [Installa Ruby](https://www.ruby-lang.org/it/documentation/installation/) (3+ Consigliato)
2. Nel tuo ~/.bashrc o ~/.bash_aliases o ~/.profile aggiungi `export MAPS_API=TUA_CHIAVE` per evitare di avere la chiave in chiaro nello script

### Uso
`MAPS_API=$MAPS_API ruby csv-to-kml.rb /path/to/csv /path/to/kml "Name Column" "Address Column"`
Lo script estrarrà tutti le altre colonne e le metterà come descrizione. Lo script userà `ARGV[2]` e `ARGV[3]` per sapere rispettivamente la colonna nome e indirizzo

# English
## csv_to_kml
A Ruby script to convert dynamically from csv to kml while geocoding coordinates from full addresses. MAPS API KEY NEEDED
You won't need a fixed CSV file like other tools! Just tell the script what the name and address column will look like and it will extrapolate everything else for you

### Installation
1. [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/) (3+ recommended)
2. In your ~/.bashrc or ~/.bash_aliases or ~/.profile file add `export MAPS_API=YOUR_KEY` to avoid having it cleartext in the script.

### Usage
`MAPS_API=$MAPS_API ruby csv-to-kml.rb /path/to/csv /path/to/kml "Name Column" "Address Column"`
The script will extrapolate all the other columns and put it in the description. The script will use `ARGV[2]`and `ARGV[3]` to know name and location columns respectively
 
