#!/bin/bash
#jekyll
rsync -avz --delete -e ssh _site/ mapgog@gatillos.com:gatillos.com/yay

