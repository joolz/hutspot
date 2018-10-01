#!/bin/bash

has_bom() {
	head -c3 "$1" | LC_ALL=C grep -qP '\xef\xbb\xbf';
}

has_bom $1 && echo yes
