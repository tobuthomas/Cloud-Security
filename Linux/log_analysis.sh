#!/bin/bash

#Replace Incorrect Password with Access Denied

sed /s/INCORRECT_PASSWORD/ACCESS_DENIED/ LogA.txt > anotherfile.txt
awk -F" " '{print s4,s6}' anotherfile.txt > yetanotherfile.txt
echo "Script completed successfully"

