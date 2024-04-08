#!/bin/bash

EXT=$AKASHLOGPATH

LOGTXT=$(kubectl logs -n akash-services akash-provider-0 | grep -i wanted=)
if [ -n "$LOGTXT" ]; then
    # Extract the timestamp and text in the same sed operation
    timestamps_and_exttxt=$(echo "$LOGTXT" | sed -n 's/^\(D\[[^]]*\).*order=\([^ ]*\).*wanted="\(.*\)" have.*$/\1|\2|\3/p')

    formatted_output=$(echo "$timestamps_and_exttxt" | sed -e 's/|/ /' -e 's/^D\[//' -e 's/]$//')

    if grep -qF "$formatted_output" "$EXT"; then
        echo "Entry already exists. Appending new lines..."
        # Append only the new lines to the existing entry
        grep -Fv "$formatted_output" "$EXT" >"$EXT.tmp"
        if [ -n "$formatted_output" ]; then
            echo "$formatted_output" >>"$EXT.tmp"
        fi
        mv "$EXT.tmp" "$EXT"
    else
        # Append the formatted output to the output file
        if [ -n "$formatted_output" ]; then
            echo "$formatted_output" >>"$EXT"
            echo "New entry added to $EXT"
        else
            echo "Formatted output is empty. Not adding to $EXT"
        fi
    fi
else
    echo "LOGTXT is empty. Not processing further."
fi
