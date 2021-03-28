#!/usr/bin/python3

# https://github.com/dmpayton/python-fretboard
# http://www.looknohands.com/chordhouse/guitar/index_rb.html

import fretboard

chords_folkert = {
	'Cmaj7': 'x597xx',
	'C7': 'x587xx',
	'Cm7': 'x586xx'
}

chords_claudio = {
	'G': 'x00230',
	'C': '002300',
	'G#': 'x1-34-',
	'C#': '113411',
	'Gm': 'x00130',
	'Cm': '0013xx',
	'G7': 'x00210',
	'C7': '002100',
	'Gm7': 'x00110',
	'Cm7': '0011xx',
	'Gmaj7': 'x00220',
	'Cmaj7': '002200',
	'Gm maj7': 'x00120',
	'Cm maj7': '0012xx',
	'G6': 'x00200',
	'C6': '0020xx',
	'G13': 'x0320x',
	'C13': '0320xx',
	'Gsus4': 'x00330',
	'Csus4': '0033xx',
	'Cdim': 'x54322',
	'Cdim (better)': 'x5465x',
	'C half dim': 'x5466x',
	'C aug': 'x56785'
}

chords_looknohands = {
	'D<br />        1,3,5': 			'224522',
	'D5<br />       1,5': 				'2200xx',
	'D-5<br />      1,3,b5':	 		'214xxx',
	'D6<br />       1,3,5,6': 			'24455x',
	'D6/9<br />     1,3,(5),6,9': 			'24222x',
	'D7<br />       1,3,5,b7':	 		'224322',
	'Dadd9<br />    1,3,5,9': 			'222522',
	'Dmaj7<br />    1,3,5,7': 			'224422',
	'Dmaj7+5<br />  1,3,#5,7':	 		'2344xx',
	'Dmaj9<br />    1,3,(5),7,9': 			'222422',
	'Dmaj11<br />   1,(3),5,7,(9),11':	 	'2254xx',
	'Dmaj13<br />   1,3,(5),7,(9),(11),13': 	'2444xx',
	'D2<br />       1,2,3,5': 			'22252x',
	'Dm<br />       1,b3,5': 			'223xxx',
	'Dm6<br />      1,b3,5,6': 			'2232xx',
	'Dm6/9<br />    1,b3,(5),6,9':	 		'24320x',
	'Dmmaj7<br />   1,b3,5,7': 			'2234xx',
	'Dmmaj9<br />   1,b3,(5),7,9': 			'22340x',
	'Dmadd9<br />   1,b3,(5),9': 			'22300x',
	'Dm7<br />      1,b3,5,b7': 			'2233xx',
	'Dm9<br />      1,b3,(5),b7,9': 		'22330x',
	'Dm11<br />     1,b3,(5),b7,(9),11':		'22333x',
	'Dm13<br />     1,b3,(5),b7,(9),(11),13':	'2433xx',
	'Dm-5<br />     1,b3,b5': 			'213xxx',
	'Ddim<br />     1,b3,b5': 			'213xxx',
	'Ddim7<br />    1,b3,b5,bb7': 			'2132xx',
	'Dm7-5<br />    1,b3,b5,b7': 			'2133xx',
	'D7-9<br />     1,3,(5),b7,b9': 		'25132x',
	'D7+9<br />     1,3,(5),b7,#9': 		'2x332x',
	'D7-5<br />     1,3,b5,b7': 			'2143xx',
	'D7+5<br />     1,3,#5,b7': 			'2343xx',
	'D7/6<br />     1,3,(5),6,b7': 			'2443xx',
	'D9<br />       1,3,(5),b7,9': 			'2523xx',
	'D9-5<br />     1,(3),b5,b7,9': 		'2123xx',
	'D9+5<br />     1,(3),#5,b7,9': 		'2323xx',
	'D9/6<br />     1,(3),(5),6,b7,9': 		'2423xx',
	'D9+11<br />    1,3,(5),b7,9,#11': 		'21232x',
	'D11<br />      1,(3),5,b7,(9),11': 		'2253xx',
	'D11-9<br />    1,(3),(5),b7,b9,11': 		'252x3x',
	'D13<br />      1,(3),5,b7,(9),(11),13': 	'24x3x2',
	'D13-9<br />    1,(3),(5),b7,b9,(11),13': 	'2413xx',
	'D13-9-5<br />  (1),(3),b5,b7,b9,(11),13':	'x11344',
	'D13-9+11<br /> (1),(3),(5),b7,b9,#11,13': 	'x11344',
	'D13+11<br />   1,(3),(5),b7,(9),#11,13': 	'21x244',
	'D7/13<br />    1,3,(5),b7,13': 		'2443xx',
	'Daug<br />     1,3,#5': 			'234xxx',
	'Dsus2<br />    1,2,5': 			'222xxx',
	'Dsus4<br />    1,4,5': 			'225xxx',
	'D7sus4<br />   1,4,5,b7': 			'2253xx',
	'D-9<br />      1,3,(5),b7,b9': 		'251x2x',
	'D-9+5<br />    1,(3),#5,b7,b9': 		'2313xx',
	'D-9+11<br />   1,(3),(5),b7,b9,#11': 		'2113xx',
	'D-9-5<br />    1,(3),b5,b7,b9': 		'2113xx',
	'D+5<br />      1,3,#5': 			'234xxx',
	'D+9<br />      1,3,(5),b7,#9': 		'2x332x',
	'D+11<br />     1,(3),(5),b7,9,#11': 		'2123xx'
}

def generate(chords, title, subtitle):
	row = 0
	width = 4
	block = "<h1>" + title + "</h1>\n"
	block += "<h3>" + subtitle + "</h3>\n"
	block += '<table width=\"100%\">\n'
	for chord in chords.keys():
		if row == 0:
			block += "<tr>\n"
		row = row + 1
		block += "<td style=\"text-align:center\">\n"
		block += '<h1>' + chord + '</h1>'
		fretboardChord = fretboard.Chord(positions = chords[chord] )
		svg = fretboardChord.render().getvalue()
		prefix = '<?xml version="1.0" encoding="utf-8" ?>'
		if svg.startswith(prefix):
			svg = svg[len(prefix):]
		block += svg + '\n'
		block += "</td>\n"
		if row == width:
			block += "</tr>\n"
			row = 0
	block += '</table>\n'
	block += '<hr />\n'
	return block

html = '<!DOCTYPE html>\n'
html += '<html>\n'
html += '<head>\n'
html += '<title>Barre chords in NST</title>\n'
html += '</head>\n'
html += '<body>\n'

html += generate(chords_folkert, "2021 March 27", "Presented by Folkert")
html += generate(chords_claudio, "IAAD 2021, February 9", "Presented by Claudio")
html += generate(chords_looknohands, "Look No Hands", "From <a href=\"http://www.looknohands.com/chordhouse/guitar/index_rb.html\">this site</a>")

html += "<p>Made using <a href=\"https://github.com/dmpayton/python-fretboard/blob/master/fretboard/chord.py\">this</a>, thank you!</p>"

html += '</body>\n'
html += '</html>'

text_file = open("chords.html", "w")
n = text_file.write(html)
text_file.close()
