#!/bin/sh
rm -rf 2012 2013 2014 2015
rm -f tag/*
rake tags
cp index.html.template index.html
cp atom.xml.template atom.xml
jekyll --no-safe
cp index.html.template index.html.template.back
cp atom.xml.template atom.xml.back
cp -r _site/* .
mv index.html.template.back index.html.template
mv atom.xml.back atom.xml.template
git add --all 2012 2013 2014 2015 tag atom.xml index.html
