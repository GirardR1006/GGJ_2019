#Script to process a windows executable from a working game build
#Main folder must contain a working game build
#dist folder must contain all the required dlls, from the official windows 64 bit love distribution

MAIN_FOLDER="."
FILES_FOLDER="$MAIN_FOLDER/GGJ_2019_files/"
DIST_FOLDER="$MAIN_FOLDER/dist/"
TITLE="Tandem"

cd $FILES_FOLDER
zip -9 -r $TITLE.love . 
cd "../dist"
cat "love.exe" "../GGJ_2019_files/$TITLE.love" > $TITLE.exe
#zip -9 -r "game.zip" . 
#cp game.zip ../
