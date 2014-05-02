#!/bin/sh
#
#	$Id: makemanappendix.sh,v 1.5 2012/01/02 16:54:01 pooka Exp $
#

rm -f lastpage
echo 2 > lastpage
for x in data/*.1 data/*.3 data/*.4 data/*.7 ; do
    name=$(sed -n '/^\.Nm/{s/ ,$//;s/_/\\\\_/;s/^\.Nm //p;q;}' < ${x})
    labelname=$(sed -n '/^\.Nm/{s/ ,$//;s/_//;s/^\.Nm //p;q;}' < ${x})
    rawname=$(sed -n '/^\.Nm/{s/ ,$//;s/^\.Nm //p;q;}' < ${x})
    descr=$(sed -n '/^\.Nd/{s/^\.Nd //p;q;}' < ${x})
    chapter=$(sed -n '/^\.Dt/{s/.*\([1-9]\)$/\1/p;q;}' < ${x})
    groff -Tascii -mandoc $x | col -x \
    | sed 's/++oo/\\textbf{o}/g;s/\(.\)\1/\\textbf{\1}/g' \
    | sed 's/_\(.\)/\\emph{\1}/g' \
    | awk -v name="${name}" -v descr="${descr}" -v chapter="${chapter}" \
	-v labelname="${labelname}" -v rawname="${rawname}" '
NR == 1 {
	header = $0
}

NR >= 3 {
	input[NR-3] = $0
}

END {
	footer = $0

	getline prevpage < "lastpage"
	close(lastpage)
	print "\\phantomsection"
	print "\\manpage{\\textbf{" name "(" chapter ")}: " descr "}{A-" prevpage "}{}"
	print "\\label{manpage:" labelname "." chapter "}"
	print "\\begin{alltt}"
	print "{\\footnotesize"
	printf "%s\n\n", header
	for (i = 0; i < NR-4; i++) {
		if (i > 0 && i % (31) == 0) {
			printf "\n%s", footer
			print "\\newpage"
			printf "%s\n\n", header
		}
		print input[i]
	}

	while (i % 31) {
		print ""
		i=i+1
	}
	printf "\n%s", footer
	print "}"
	print "\\end{alltt}"
	print prevpage+i/31 > "lastpage"
}' ; done
rm -f lastpage
