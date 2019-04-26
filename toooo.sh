#!/bin/bash

libreoffice --headless --convert-to odt *.doc
libreoffice --headless --convert-to odt *.docx
libreoffice --headless --convert-to ods *.xls
libreoffice --headless --convert-to ods *.xlsx
libreoffice --headless --convert-to odp *.ppt
libreoffice --headless --convert-to odp *.pptx

doneMessage
