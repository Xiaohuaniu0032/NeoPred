## NeoPred
predict tumor neoantigens using NeoPredPipe software

## Usage
`perl NeoPred.pl -n <sample name> -vcf <tumor vcf> -nbam <normal bam> -od <output dir> -py2 <python2> -py3 <python3> -samtools <samtools> -bedtools <bedtools> -ref <ref fasta>`
### parameter specification
`-n`: sample name [Need]

`-vcf`: tumor vcf file [Need]

`-nbam`: normal bam file [Need]

`-od`: output dir [Need]

`-py2`: python2 [Default]

`-py3`: python3 [Default]

`-samtools`: samtools [Default]

`bedtools`: bedtools [Default]

`-ref`: ref fasta [Default]

## Method
1. HLA typing: `OptiType` (v1.3.2)
2. neoantigenes prediction: `NeoPredPipe`

the main steps in `NeoPredPipe` includes:

1. variant annotation (use Annovar)
2. neoantigen prediction (use netMHCpan)
3. peptide matching (use PeptideMatch, optional)
4. predict the recognition potential of predicted neoantigens (see `https://doi.org/10.1038/nature24473`, Nature, 2017)

## Test
1. `cd /path/NeoPred/test`
2. `sh test.sh`

you will see below files:

```
drwxrwxr-x 2 fulongfei fulongfei 4096 12月 22 13:59 avannotated
drwxrwxr-x 2 fulongfei fulongfei 4096 12月 22 13:59 avready
drwxrwxr-x 2 fulongfei fulongfei 4096 12月 22 16:57 fastaFiles
-rw-rw-r-- 1 fulongfei fulongfei  510 12月 22 16:57 logforannovarNeoPredPipe.txt
-rw-rw-r-- 1 fulongfei fulongfei  269 12月 22 14:00 TestRun.neoantigens.Indels.summarytable.txt
-rw-rw-r-- 1 fulongfei fulongfei    0 12月 22 16:57 TestRun.neoantigens.Indels.txt
-rw-rw-r-- 1 fulongfei fulongfei  223 12月 22 16:57 TestRun.neoantigens.summarytable.txt
-rw-rw-r-- 1 fulongfei fulongfei    0 12月 22 16:57 TestRun.neoantigens.txt
-rw-rw-r-- 1 fulongfei fulongfei  159 12月 22 16:57 test.sh
drwxrwxr-x 2 fulongfei fulongfei 4096 12月 22 14:00 tmp
```

the main result files are: `TestRun.neoantigens.txt` and `TestRun.neoantigens.Indels.txt`

you can see `https://github.com/MathOnco/NeoPredPipe` *Output Format* part for details.

## Software Needed
1. see `https://github.com/FRED-2/OptiType` for `OptiType` requirements
2. see `https://github.com/MathOnco/NeoPredPipe` for `NeoPredPipe` requirements

besides above, you also need:

1. python2
2. python3
3. samtools
4. bedtools

## Reference
1. `NeoPredPipe`: high-throughput neoantigen prediction and recognition potential pipeline, BMC Bioinformatics, 2019
2. `https://github.com/MathOnco/NeoPredPipe`


