# LycaeidesGenome
General scripts and notes for our Lycaeides genome assemblies

## Comparitive alignment of *L. melissa* genome version

We have a chromosome-scale assmebly for *L. melissa* from Dovetail (Chicago + HiC) (`mod_melissa_blue_21Nov2017_GLtS4.fasta`) [Chaturvedi et al. 2020](https://www.nature.com/articles/s41467-020-15641-x), and a newer version of this same genoe with PacBio HiFi gap filling (`Lmel_dovetailPacBio_genome.fasta`) [Zhang et al. 2022](https://www.biorxiv.org/content/10.1101/2022.01.14.476419v1). I have copies of both in `/uufs/chpc.utah.edu/common/home/gompert-group3/data/LmelGenome`. The PacBio genome is notably longer. I want to know why, so I am aligning the two genomes to each other.

First, I am using a repeat library made from [Sam's paper](https://www.nature.com/articles/s41467-020-15641-x) for soft repeat masking of each genome with `RepeatMasker` (version 4.0.7).

```{bash}
#!/bin/bash
#SBATCH -n 24 
#SBATCH -N 1
#SBATCH -t 96:00:00
#SBATCH -p gompert-np
#SBATCH -A gompert-np
#SBATCH -J repmask

module load repeatmasker
# version open-4.0.7

cd /uufs/chpc.utah.edu/common/home/gompert-group3/data/LmelGenome

RepeatMasker -s -e ncbi -xsmall -pa 48 -lib consensi.fa.classified mod_melissa_blue_21Nov2017_GLtS4.fasta

RepeatMasker -s -e ncbi -xsmall -pa 48 -lib consensi.fa.classified Lmel_dovetailPacBio_genome.fasta 
```

Next, I used cactus (version 1.0.0) to align the (repeat masked) Hi-C and PacBio gap-filled genomes and extracted the synteny segments.

```{bash}
#!/bin/sh 
#SBATCH --time=240:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --account=gompert-np
#SBATCH --partition=gompert-np
#SBATCH --job-name=cactus-master
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=zach.gompert@usu.edu

cd /scratch/general/lustre/cactusNp

module load cactus

cactus jobStore /uufs/chpc.utah.edu/common/home/gompert-group3/data/LmelGenome/cactusLmel.txt cactusLmel.hal --maxCores 80   
```

```{bash}
#!/bin/sh 
#SBATCH --time=300:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --account=gompert-np
#SBATCH --partition=gompert-np
#SBATCH --job-name=cactus-syn
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=zach.gompert@usu.edu
cd /uufs/chpc.utah.edu/common/home/gompert-group3/data/LmelGenome

~/source/hal/bin/halSynteny --queryGenome l_mel_hic --targetGenome l_mel_pb cactusLmel.hal out_synteny_Lmel.psl
```

[SynPlotsLmel.R](SynPlotsLmel.R) summaries and plots the results. From the alignment, it appears that the extra size of the PacBio version of the genome is not due to any specific chromosome or the ends of chromosome, but little additions of bases throughout, likely because Ns (gaps) were too small in the HiC Dovetail assembly.
