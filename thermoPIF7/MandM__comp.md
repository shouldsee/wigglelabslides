
---
title: hi
# mustache: ./vars.yaml
# bibliography: ./citation.bib
---

Data availability
RNASeq Series: GSE124003

## Computational analysis:

1. <u>RNA-Seq: General mapping</u>
	* Raw reads were mapped either with the hisat2+stringtie pipeline. We used {{GENOME}} from Phytozome (!CITE!PHYTOZOME) as reference genome throughout the study. 

	**Hisat2+Stringtie** pipeline: Adapters were trimmed off from raw reads with Trimmomatic (!CITE! TRIMMOMATIC) with argument \"{{ARG_TRIMMO_PE}}\". Raw reads were mapped to the transcriptome using HISAT2 (!CITE! HISAT2) with argument:\"{{ARG_HISAT2}}\" . Duplicate reads were removed with Picard (!CITE! PICARD) using default setting. Transcripts were quantified according to this alignment with StringTie (!CITE! STRINGTIE) in TPM values (Transcripts per Million mapped transcripts) with argument \"{{ARG_STRINGTIE}}\". 

	The TPM values were transformed into log abundances through 
		
		$$A_{gc}=\log_2(\text{TPM}_{gc}+1) = A[c]$$
		
		($g$ indexes genes while $c$ indexes conditions). 

		Any gene with a maximum log abundance smaller than {{CUTOFF_MAX}} was discarded from downstream analysis to avoid introducing noisy variation. Detailed TPM table can be found in the supplementary. Out of {{GENENO_ALL}} reference genes, {{GENENO_TPM}} were kept.


<!-- 
1.  Raw reads are aligned to TAIR10, with adapters removed. Transcripts were assembled and quantified with Stringtie. The raw coverage was normalised within each RNA-Seq library into TPM values (transcript-per-million).
2.  Prefiltering was performed to remove lowly-expressed transcripts.#
 -->
 
3.  Temperature perturbation was quantified as log2[ TPMplus1_27C_Col-0  /  TPMplus1_22C_Col-0  ]  for each of the 7 time-points.
4.  Genotype perturbation was quantified as log2[ TPMplus1_27C_pif7-1 /  TPMplus1_27C_Col-0 ]
5.  Genes were clustered according to the temperature perturbation matrix using XX model.
6.  Marker-based target calling: perturbation profiles of a group of 3 marker gene were selected and averaged to generate a signature for each of the perturbation matrix. Within each perturbation matrix, a similarity score is calculated for each gene as the dot product of its profile and the signature profile. The best xx% of the genes are then claimed as transcriptionally perturbed.

ChIP-Seq:
1. Mapped with bowtie2. Doubly mapped reads were discarded.
1. PIF7 binding sites were called from 186CS12 using `callpeak macs2` with a fold-change cut off of 3.25. A gene is classified as a bound target if there is a peak summit within +/-  3000 of its start codon.
1. RPKM values (reads per kilo base-pair per million reads) were estimated from the raw alignments using a bin size of 10bp.
1. RPKM profile was extracted for each peak around the reported summit position. Per-position average and standard deviation was calculated across the peaks.
1. Overlapping ChIP-Seq: two peaks are considered overlapping if their summits were closer than a CUTOFF of 600bp.

Motif analysis:
Functional peaks were defined to be near (+/- 3000bp of start codon) a transcriptionally perturbed gene   according to the genotype perturbation matrix. Sequences were extracted around the peak summit for a window of 100bp. Non-novo enrichment was performed using AME against database “ArabidopsisPBM_20140210.meme” with argument “ame --kmer 2 --control --shuffle-- --hit-lo-fraction 0.25 --evalue-report-threshold 10.0”. De-novo inference of motif was performed using MEME with argument “meme -mod anr -dna -nmotifs 3”.
