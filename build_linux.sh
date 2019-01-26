#Script to process a .love file from a working game build
#Main folder must contain a working game build

MAIN_FOLDER="."
FILES_FOLDER="$MAIN_FOLDER/GGJ_2019_files/"
TITLE="game"

cd $FILES_FOLDER
zip -9 -r $TITLE.love .
cp $TITLE.love $MAIN_FOLDER
