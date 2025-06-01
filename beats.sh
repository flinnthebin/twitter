#!/bin/bash

beats() {
    DEVICE_MAC="F8:66:5A:4E:F9:75"
    MAX_RETRIES=10
    RETRY_DELAY=2
    TIMEOUT=10

    pulseaudio -k >/dev/null 2>&1
    pulseaudio --start >/dev/null 2>&1
    echo "Starting connection attempts to $DEVICE_MAC"
    for ((i=1; i<=MAX_RETRIES; i++)); do
        echo "Attempt $i of $MAX_RETRIES..."
        OUTPUT=$(timeout "$TIMEOUT" bluetoothctl connect "$DEVICE_MAC" 2>&1)
        echo "$OUTPUT"
        if echo "$OUTPUT" | grep -q "Connection successful\|Connected: yes"; then
            echo "Connected successfully on attempt $i"
            return 0
        fi
        if echo "$OUTPUT" | grep -qE "Error\.InProgress|br-connection-busy|br-connection-refused|Error\.Failed"; then
            echo "Connection failed or busy. Resetting state..."
            beatskill
        fi
        echo "Waiting $RETRY_DELAY seconds before retry..."
        sleep "$RETRY_DELAY"
    done
    echo "Failed to connect after $MAX_RETRIES attempts."
    return 1
}

beatskill() {
bluetoothctl disconnect "F8:66:5A:4E:F9:75"
}

beats
