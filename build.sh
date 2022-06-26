FILE="~/createPR"
if [ -f "$FILE" ]; then
    rm $FILE
fi

swift build && cp .build/arm64-apple-macosx/debug/PRfromJira ../createPR
