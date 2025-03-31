FILE="/usr/local/bin/createPR"
if [ -f "$FILE" ]; then
    sudo rm -rf $FILE
fi

swift build && sudo cp .build/debug/PRfromJira $FILE
