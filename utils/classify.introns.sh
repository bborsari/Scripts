
if [[ $# < 1 ]]; then
	echo "USAGE: $0 <gtf>"
	exit 1
fi

gtf=$1

cat $1 | awk '
BEGIN{OFS=FS="\t"; sep=";"}
$3=="intron" {
	split("", d)
	split($9, a, "; ");
	for(i=1;i<=length(a);i++) {
		split(a[i], b, " ");
		gsub(/"/, "", b[2])
		d[b[1]] = b[2]
	}
	gn_id = d["gene_id"]
	tx_id = d["transcript_id"]
	chr[gn_id] = $1
	strand[gn_id] = $7	
	intron = $1(sep)$4(sep)$5(sep)$7(sep)tx_id
	intron_gn = $1(sep)$4(sep)$5(sep)$7(sep)gn_id
#	nb_introns[tx_id] ++


	# Find first and last introns for a transcript
	# ------------------------------------------
	if (min1[tx_id] == "" || min1[tx_id] > $4) {
		min1[tx_id] = $4
		min2[tx_id] = $5
	}

	if (max2[tx_id] == "" || max2[tx_id] < $5) {
		max2[tx_id] = $5
		max1[tx_id] = $4
	}

	if (min1[tx_id] == $4) {
		min2[tx_id] = min(min2[tx_id], $5)
	}

	if (max2[tx_id] == $5) {
		max1[tx_id] = max(max1[tx_id], $4)
	}

	ex1[tx_id] = chr[gn_id](sep)min1[tx_id](sep)min2[tx_id](sep)strand[gn_id](sep)tx_id
	ex2[tx_id] = chr[gn_id](sep)max1[tx_id](sep)max2[tx_id](sep)strand[gn_id](sep)tx_id

	# Find constitutive introns
	# -----------------------

	if (txs[gn_id] == "") {
		txs[gn_id] = tx_id
	}

	if (txs[gn_id] !~ tx_id) {
		txs[gn_id] = txs[gn_id]","tx_id
	}

	intronsG[gn_id] = (intronsG[gn_id] == "" ? intron : intronsG[gn_id]","intron)
	intronsT[tx_id] = (intronsT[tx_id] == "" ? intron : intronsT[tx_id]","intron)

	intronCounts[intron_gn] ++
}

END {
	for (gn in chr) {

		# Nmber of transcripts for a given gene
		nb_tx = split(txs[gn], t, ",")

#		# Define first and last introns
#		if (strand[gn] == "+") {
#			firstG = ex1g[gn]
#			lastG = ex2g[gn]
#		}
#		if (strand[gn] == "-") {
#			firstG = ex2g[gn]
#			lastG = ex1g[gn]
#		}
#		print gn, first, last
		
		# Iterate over all introns of a gene
		
		for (j=1;j<=nb_tx;j++) {
		
			tx = t[j]
			split(intronsT[tx], e, ",")
	
			# Define first and last introns
			if (strand[gn] == "+") {
				first = ex1[t[j]]
				last = ex2[t[j]]
			}
			if (strand[gn] == "-") {
				first = ex2[t[j]]
				last = ex1[t[j]]
			}

			for(i=1;i<=length(e);i++) {
				pos = "internal"
				if (e[i] == first) {
					pos = "first"
				}
				if (e[i] == last) {
					pos = "last"
				}
				if (length(e) == 1) {
					pos = "unique"
				}
				split(e[i], c, (sep))
				intron_gn = c[1](sep)c[2](sep)c[3](sep)c[4](sep)gn
				const = (intronCounts[intron_gn] == nb_tx ? "constitutive" : "alternative")
				
#				print gn, t[j], e[i], pos, constitutive
				print c[1], c[2], c[3], c[4], pos, const, tx, gn, length(e)
			}
		}
	}
}

function min(x,y){return (x<=y) ? x : y;}
function max(x,y){return (x>=y) ? x : y;}
'  

