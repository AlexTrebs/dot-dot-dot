#!/bin/bash
# Toggle screen recording with wf-recorder

RECORDINGS_DIR="$HOME/Videos/Recordings"
mkdir -p "$RECORDINGS_DIR"

if pgrep -x "wf-recorder" > /dev/null; then
    # Stop recording
    pkill -INT -x wf-recorder
    notify-send "Recording Stopped" "Video saved to $RECORDINGS_DIR"
else
    # Start recording with region selection
    FILENAME="$RECORDINGS_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

    # Use slurp for region selection, or record full screen if slurp fails
    if command -v slurp &> /dev/null; then
        GEOMETRY=$(slurp 2>/dev/null)
        if [ -n "$GEOMETRY" ]; then
            wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
        else
            # User cancelled selection, record full screen
            wf-recorder -f "$FILENAME" &
        fi
    else
        wf-recorder -f "$FILENAME" &
    fi

    notify-send "Recording Started" "Press shortcut again to stop"
fi
