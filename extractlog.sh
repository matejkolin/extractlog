#!/bin/bash

EXT=$AKASHLOGPATH
echo "Writing to $AKASHLOGPATH"

LOGTXT=$(kubectl logs -n akash-services akash-provider-0 | grep -i "wanted=")
if [ -n "$LOGTXT" ]; then
    # Extract the timestamp and text in the same sed operation
    timestamps_and_exttxt=$(echo "$LOGTXT" | sed -n 's/^\(D\[[^]]*\).*order=\([^ ]*\).*wanted="\(.*\)" have.*$/\1|\2|\3/p')

    formatted_output=$(echo "$timestamps_and_exttxt" | sed -e 's/|/ /' -e 's/^D\[//' -e 's/]$//')

	while IFS= read -r line; do
	    if grep -qF "$line" "$EXT"; then
	        #echo "Entry already exists. Skipping to next line."
	        continue
	    fi
	    
	    # Append the line to the output file
	    if [ -n "$line" ]; then
	        echo "$line" >> "$EXT"
	        echo "New entry added to $EXT"
	    else
	        #echo "Line is empty. Not adding to $EXT"
		continue
	    fi
	done <<< "$formatted_output"

else
    echo "LOGTXT is empty. Not processing further."
fi


EXCL_BIDS=$(kubectl logs -n akash-services akash-provider-0 | grep -oP '(?<=PSF\|).*[^"]')
if [ -n "$EXCL_BIDS" ]; then
        while IFS= read -r line; do
            if grep -qF "$line" "$EXCL_LOG"; then
                #echo "Entry already exists. Skipping to next line."
                continue
            fi

            # Append the line to the output file
            if [ -n "$line" ]; then
                echo "$line" >> "$EXCL_LOG"
                echo "New entry added to $EXCL_LOG"
            else
                #echo "Line is empty. Not adding to $EXCL_LOG"
                continue
            fi
        done <<< "$EXCL_BIDS"

else
    echo "No bids. Not processing further."
    exit
fi

