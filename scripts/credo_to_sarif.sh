#!/bin/bash

awk 'BEGIN { print "{\n\t\"version\": \"2.1.0\",\n\t\"runs\": [{\n\t\t\"tool\": {\n\t\t\t\"driver\": {\n\t\t\t\t\"name\": \"Credo\",\n\t\t\t\t\"informationUri\": \"https://github.com/rrrene/credo\",\n\t\t\t\t\"rules\": []\n\t\t\t}\n\t\t}\n\t}]\n}" }' > credo.sarif

while IFS= read -r line; do
    filename=$(echo $line | cut -d: -f1)
    lineno=$(echo $line | cut -d: -f2)
    colno=$(echo $line | cut -d: -f3)
    message=$(echo $line | cut -d: -f4-)
    message=$(echo -e "${message}" | sed -e 's/^[[:space:]]*//')
    ruleId=$(echo $message | cut -d' ' -f1)
    message=$(echo $message | cut -d' ' -f2-)

    jq ".runs[0].tool.driver.rules += [{\"id\": \"$ruleId\", \"shortDescription\": {\"text\": \"$message\"}}]" credo.sarif | sponge credo.sarif
    jq ".runs[0].results += [{\"ruleId\": \"$ruleId\", \"level\": \"error\", \"message\": {\"text\": \"$message\"}, \"locations\": [{\"physicalLocation\": {\"artifactLocation\": {\"uri\": \"$filename\"}, \"region\": {\"startLine\": $lineno, \"startColumn\": $colno}}}]}]" credo.sarif | sponge credo.sarif
done < credo.txt
