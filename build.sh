FILE="~/createPR"
if [ -f "$FILE" ]; then
    rm -rf $FILE
fi

swift build && cp .build/arm64-apple-macosx/debug/PRfromJira /usr/local/bin/createPR
make format
