#!/bin/bash

if [ ! -e "genes.png" ]; then
	Rscript scripts/analysis.R
fi
