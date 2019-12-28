#!/bin/bash
rm -rf Fantheon.dmg

./copyAndCreateIcon.sh && \
appdmg appdmg.json Fantheon.dmg