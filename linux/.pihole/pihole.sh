#!/bin/bash

PIHOLE_PORT=""

# set default port (80 by default)
if [ -n "$PIHOLE_PORT" ]; then
    sudo pihole-FTL --config webserver.port "$PIHOLE_PORT"
fi
