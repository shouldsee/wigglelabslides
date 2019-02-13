
---
title: hi
mustache: ./vars.yaml
bibliography: ./citation.bib
include-in-header:
	- \usepackage{times}
---

## Computational analysis:

1. <u>RNA-Seq: Mapping and quantification</u>
	
	Raw reads were mapped either with the Tophat pipeline or hisat2+stringtie pipeline due to logistic reasons, and is recorded in the supplementary TPM table. We used {{GENOME}} from Phytozome (!CITE!PHYTOZOME) as reference genome throughout the study. 

	**Hisat2+Stringtie** pipeline: Adapters were trimmed off from raw reads with Trimmomatic (!CITE! TRIMMOMATIC) with argument \"{{ARG_TRIMMO_PE}}\". Raw reads were mapped to the transcriptome using HISAT2 (!CITE! HISAT2) with argument:\"{{ARG_HISAT2}}\" . Duplicate reads were removed with Picard (!CITE! PICARD) using default setting. Transcripts were quantified according to this alignment with StringTie (!CITE! STRINGTIE) in TPM values (Transcripts per Million mapped transcripts) with argument \"{{ARG_STRINGTIE}}\". 

	**Tophat+Cufflinks** pipeline: Adapters were trimmed off from raw reads with Trimmomatic (!CITE! TRIMMOMATIC) with argument \"{{ARG_TRIMMO_PE_TOPHAT}}\". Raw reads were mapped to the transcriptome using TOPHAT (!CITE! TOPHAT) with argument:\"{{ARG_TOPHAT}}\". Duplicate reads were removed with Picard (!CITE! PICARD) using default setting. Transcripts were quantified according to this alignment with cufflinks (!CITE! CUFFLINKS) in TPM values (Transcripts per Million mapped transcripts) with argument \"{{ARG_CUFFLINKS}}\".

	The TPM values were transformed into log abundances through 
		
		$$A_{gc}=\log_2(\text{TPM}_{gc}+1) = A[c]$$
		
		($g$ indexes genes while $c$ indexes conditions). 

		Any gene with a maximum log abundance smaller than {{CUTOFF_MAX}} was discarded from downstream analysis to avoid introducing noisy variation. Detailed TPM table can be found in the supplementary. Out of {{GENENO_ALL}} reference genes, {{GENENO_TPM}} were kept.

1. <u>RNA-Seq: Clustering and target calling</u>

	* To investigate transcriptomic response towards a particular treatment, time-course perturbation matrices were constructed as the difference of log abundances between paired conditions. For example, 
	
		$$
		\begin{align*}D&[\text{LD/SD,WT,Wk2,ZT0}] \\
		&= A[\text{LD,WT,Wk2,ZT0}] - A[\text{SD,WT,Wk2,ZT0}] \\
		&= \log_2( \frac{ \text{TPM}[\text{LD,WT,Wk2,ZT0}] + 1 }
		{ \text{TPM}[\text{SD,WT,Wk2,ZT0}] + 1 })
		\end{align*}
		$$

	* Clustering: The selected perturbation matrices were concatenated into a data matrix, against which a von Mises-Fisher mixture of increasing concentration is fitted (similar to !CITE!clusterVMF). Optimal concentration is manually selected to be {{OPTIMAL_CONC}} according to the diagnostic plot and clusters with an average uncertainty higher than {{CUTOFF_ENT}} were considered non-significant. Out of {{GENENO_TPM}} genes included, {{GENENO_CLUSTERED}} were assigned a significant cluster.

		The following perturbation matrices were selected:

		- [LD/SD, WT, Wk2]
		- [LD/SD, WT, Wk3]
		- [SD, elf3-1/WT,Wk2]
		- [SD, elf3-1/WT,Wk3]
		- [LD, phyC-4/WT,Wk2]
		- [LD, ppd1-1/WT,Wk3]

	* Selection of genes responsive to _elf3-1_ and _phyC-4_: A continous timecourse function was interpolated linearly from each of the perturbation matrices [SD, elf3-1/WT,Wk2] and [LD, phyC-4/WT,Wk2], which is then integrated over 24hr to give a temporal average, $T[\text{SD, elf3-1/WT,Wk2}]$ and $T[\text{LD, phyC-4/WT,Wk2}]$. Genes that satisfy $T[\text{SD, elf3-1/WT,Wk2}] - T[\text{LD, phyC-4/WT,Wk2}] >$ {{CUTOFF_interpAUC}} were considered transcriptionally perturbed.

1. <u>ChIP-Seq: Mapping and quantification</u>
	
	* Adapters were trimmed off from raw reads with Trimmomatic (!CITE!TRIMMOMATIC) (!CITE!trimmomatic) with argument \"{{ARG_TRIMMO_PE}}\". Raw reads were mapped to the genome {{GENOME}} with Bowtie2 (!CITE!BOWTIE2) under argument:\"{{ARG_BOWTIE2}}\". Any read that mapped to more than one genomic location was discarded. Duplicate reads were removed with Picard using default setting (!CITE!PICARD).

	* Genomic binding profile was quantified in RPKM (Reads Per Kilobase per Million mapped reads) using a bin-size of {{BIN_CHIP}}bp. For each bin, $\text{RPKM}_{\text{bin}}=\frac{\# \text{Reads covering bin}} { \text{bin-size} } \cdot \frac{10^6}{ \#\text{Mapped reads}}$

	* For each treated ChIP-Seq library, peaks were called against a control using MACS2 (!CITE!MACS2) with argument \"{{ARG_MACS2}}\". Peaks from all ChIP-Seqs were fitlered for {{MACS2_FILTER}}.

1. <u>ChIP-Seq: Defining regions differentially bound by ELF3</u>

	* Peaks from all ELF3 ChIP-Seqs were filtered and merged into contiguous regions.

	* Abundances were computed for {{WINDOW_SIZE}}bp windows within each merged region, and log-transformed with 
		$$A_{wc} = A_{w}[c] =\log_2 \left( 1 + { \sum_{i \in w}  \text{RPKM}_i[c] }\right)$$

		($w$ denotes the window, $i$ denotes the {{BIN_CHIP}}bp bin, $c$ indexes condition)

	* Differential occupancy was quantified for each window by taking its dot-product with a signature vector to get $s_w = \sum_{c} \phi_c A_{wc}$, where the signature vector $\phi_{c}$ is computed from a set of marker windows $W$ so that

		$$
		\begin{align*}
		\left\{ 
		\begin{aligned} 
		\phi_c 
		= \text{meanNorm}_c \left( \frac{ \sum_{w\in W} A_{wc} }{ \sum_{w \in W} 1 } \right)\\
		 \text{meanNorm}_c(x_c) 
		= x_c - \frac{ \sum_c x_c  }{ \sum_c 1 }
		\end{aligned}
		\right.
		\end{align*}
		$$

		Cross-condition variance is also defined for each window $t_w = \text{Std}_c [A_{wc}]$. Any window with $s_g$ > {{CUTOFF_CHIP}} and $t_g$ > {{CUTOFF_CHIPSD}} is called differentially bound. 

	* Any peak with a differentially bound window is considered a differentially-bound peak. Any gene with a differential bound window within +/- {{CUTOFF_PEAK2GENE}} of its start codon is considered a differentially bound gene. Pile-up of ELF3 occupancy: was performed on the set of peaks that contains at least 1 differentially bound window.

	* Binding profiles near marker genes were visualised with _fluff_ (!CITE!FLUFF), and visualised with Integrated Genomic Browser during investigation (!CITE!IGV).


1. <u>Availability</u>

	* Code is available from this Github repo: https://github.com/shouldsee/BrachyPhoto.

	* RNA-Seq data are available from: {{GEO_RNA}}

	* ChIP-Seq data are available from: {{GEO_CHIP}}

	* GNU-parallel (!CITE!GNUPARA) was used in paralleling the computational analysis. 
