#!/bin/bash

# Set a single value in an XML file
xml-set() {
    local xpath="$1"
    local value="$2"
    local file="$3"

    xmllint --shell "${file}" <<EOF_XML_SHELL >> /dev/null
        cd $xpath
        set $value
        save
        bye
EOF_XML_SHELL
}
