#!/bin/bash
# Run this after exiting opencode to switch to the new version
mv ~/.opencode/bin/opencode ~/.opencode/bin/opencode-old
mv ~/.opencode/bin/opencode-new ~/.opencode/bin/opencode
echo "Switched to gignit/opencode with enhanced markdown renderer!"
echo "Run: opencode"
