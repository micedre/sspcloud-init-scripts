#!/bin/sh

# This init script install various useful VScode extensions
# NB : only extensions from the Open VSX Registry (https://open-vsx.org/) can be installed on code-server
# Expected parameters : None

# CONFORT EXTENSIONS -----------------

# Colorizes the indentation in front of text
code-server --install-extension oderwat.indent-rainbow
# Extensive markdown integration
code-server --install-extension yzhang.markdown-all-in-one
# Integrates Excalidraw (software for sketching diagrams)
code-server --install-extension pomdtr.excalidraw-editor

# ADD CUSTOM EXTENSIONS FROM ARGS ----

# Check if no arguments are provided
if [ "$#" -ge 1 ]; then
  # Loop over all the provided arguments (extensions)
  for extension in "$@"
  do
      echo "Installing extension: $extension"
      
      # Install the extension using code-server
      code-server --install-extension "$extension"
      
      # Check if the installation was successful
      if [ $? -eq 0 ]; then
          echo "Successfully installed $extension"
      else
          echo "Failed to install $extension"
      fi
  done
fi

# COPILOT ----------------------------

# Install Copilot (Microsoft's AI-assisted code writing tool)
copilotVersion="1.234.0"
copilotChatVersion="0.20.0" # This version is not compatible with VSCode server 1.92.2

wget --retry-on-http-error=429 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot/${copilotVersion}/vspackage -O copilot.vsix.gz
wget --retry-on-http-error=429 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot-chat/${copilotChatVersion}/vspackage -O copilot-chat.vsix.gz

gzip -d copilot.vsix.gz 
gzip -d copilot-chat.vsix.gz 

code-server --install-extension copilot.vsix
code-server --install-extension copilot-chat.vsix
rm copilot.vsix copilot-chat.vsix
