#Script to process a windows executable from a working game build
#Main folder must contain a working game build
#dist folder must contain all the required dlls, from the official windows 64 bit love distribution

MAIN_FOLDER="$HOME/GGJ_2019"
FILES_FOLDER="$MAIN_FOLDER/GGJ_2019_files/"
DIST_FOLDER="$MAIN_FOLDER/dist/"
TITLE="game"

cd $FILES_FOLDER
zip -9 -r $DIST_FOLDER/$TITLE.love . 
cd $DIST_FOLDER
cat love.exe $TITLE.love > $TITLE.exe
cd $MAIN_FOLDER
zip -9 -r 'game.zip' 'dist'
