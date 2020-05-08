#!/bin/bash

# see http://www.unicode.org/emoji/charts/full-emoji-list.html

# see http://www.columbia.edu/~fdc/utf8/
RUNE="ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ ᛋᚳᛖᚪᛚ᛫ᚦᛖᚪᚻ᛫ᛗᚪᚾᚾᚪ᛫ᚷᛖᚻᚹᛦᛚᚳ᛫ᛗᛁᚳᛚᚢᚾ᛫ᚻᛦᛏ᛫ᛞᚫᛚᚪᚾ ᚷᛁᚠ᛫ᚻᛖ᛫ᚹᛁᛚᛖ᛫ᚠᚩᚱ᛫ᛞᚱᛁᚻᛏᚾᛖ᛫ᛞᚩᛗᛖᛋ᛫ᚻᛚᛇᛏᚪᚾ᛬"

BRUT="An preost wes on leoden, Laȝamon was ihoten He wes Leovenaðes sone -- liðe him be Drihten. He wonede at Ernleȝe at æðelen are chirechen, Uppen Sevarne staþe, sel þar him þuhte, Onfest Radestone, þer he bock radde."

POLYTONIC="Τὴ γλῶσσα μοῦ ἔδωσαν ἑλληνικὴ τὸ σπίτι φτωχικὸ στὶς ἀμμουδιὲς τοῦ Ὁμήρου. Μονάχη ἔγνοια ἡ γλῶσσα μου στὶς ἀμμουδιὲς τοῦ Ὁμήρου."

GEORGIAN="ვეპხის ტყაოსანი შოთა რუსთაველი ღმერთსი შემვედრე, ნუთუ კვლა დამხსნას სოფლისა შრომასა, ცეცხლს, წყალსა და მიწასა, ჰაერთა თანა მრომასა; მომცნეს ფრთენი და აღვფრინდე, მივჰხვდე მას ჩემსა ნდომასა, დღისით და ღამით ვჰხედვიდე მზისა ელვათა კრთომაასა."

JAPANESE="私はガラスを食べられます。それは私を傷つけません。"

I=100
MAX=1500

for ((i=$I; i<= $MAX; ++i)) do
	SMILEYS="$SMILEYS `echo -en "\U0001f${I}"`"
	((I++))
done

echo "-----------------------------------------------"
echo "Store and retrieve this"
echo "-----------------------------------------------"
echo "${SMILEYS} ${RUNE} ${BRUT} ${POLYTONIC} ${GEORGIAN} ${JAPANESE}"
