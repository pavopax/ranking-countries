run in this order (note extension):

    scrape-usn-data.py
	make-wb-data.R
	make-weforum-data.R
	make-wingia-data.py
	make-database.R

these are helper files:

	functions.R
	header.R

other programs ./ and in subdirectories are exploratory, for now


## details

In these scripts, I experimented with multiple ways to make my Postgres
database. Sometimes I append to it from .R files, other times from .py files

This involved a lot of data processing: making consistent country names,
consistent data tables, etc.
