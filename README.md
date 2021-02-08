## NeoPred
predict tumor neoantigens using NeoPredPipe software

## Usage
`perl NeoPred.pl -n <sample name> -vcf <tumor vcf> -tcol <tumor col in VCF> -stype <sample type> -nbam <normal bam> -bed <bed> -rank <rank> -aff <affinity> -od <output dir> -col <tumor col in vcf> -py2 <python2> -py3 <python3> -samtools <samtools> -bedtools <bedtools> -ref <ref fasta>`
### parameter specification
`-n`: sample name [Need]

`-vcf`: tumor vcf file [Need]

`-tcol`: tumor col in vcf file [Default: 10]

`-tmb`: tmb file (for general user, you do not need specify this arg)

`-stype`: sample type [Default: Tissue] [Tissue | Plasma]

`-nbam`: normal bam file [Need]

`-len`: capture CDS len (used to calculate TNB)

`-rank`: NetMHCPan rank [Default:0.5]

`-aff`: affinity with MHC [Default: 500]

`-od`: output dir [Need]

`-py2`: python2 [Default]

`-py3`: python3 [Default]

`-samtools`: samtools [Default]

`bedtools`: bedtools [Default]

`-ref`: ref fasta [Default]

`-u`: use which version script to calculate TNB (for general user, you do not need to specify this arg)

>Note: `-u` controls which script should be used to calculate the TNB (for gereral user, you do not need to specify `-u` and `-tmb`, these two args are only useful for our inner company)

## Method
1. HLA typing: `OptiType` (v1.3.2)
2. neoantigenes prediction: `NeoPredPipe`

the main steps in `NeoPredPipe` includes:

1. filter VCF file
2. variant annotation (use Annovar)
3. neoantigen prediction (use netMHCpan)
4. select strong binder mut AA

## Test
> Note:
before do the test, you need to change two config files:

1) /path//tools/OptiType-1.3.2/config.ini.example (you need to change `razers3` binary path and `solver`. if you use `glpk` as your solver, you need to install `glpk`)

2) /path/tools/NeoPredPipe/usr_paths.ini (you need to change `annovar`, `netMHCpan` and `blast`.)


1. `cd /path/NeoPred/test`
2. `sh run.sh`
3. `cd 210120113`
4. `nohup sh neo.210120113.sh &`

you will see below files:

```
drwxrwxr-x 2 fulongfei fulongfei    4096 1月  27 13:56 2021_01_27_13_54_36
-rw-rw-r-- 1 fulongfei fulongfei     414 2月   4 14:14 210120113.epi.10.InDel.final.result.xls
-rw-rw-r-- 1 fulongfei fulongfei    1224 2月   4 14:14 210120113.epi.10.SNV.final.result.xls
-rw-rw-r-- 1 fulongfei fulongfei     198 2月   4 14:13 210120113.epi.8.InDel.final.result.xls
-rw-rw-r-- 1 fulongfei fulongfei     198 2月   4 14:13 210120113.epi.8.SNV.final.result.xls
-rw-rw-r-- 1 fulongfei fulongfei     198 2月   4 14:14 210120113.epi.9.InDel.final.result.xls
-rw-rw-r-- 1 fulongfei fulongfei    1008 2月   4 14:14 210120113.epi.9.SNV.final.result.xls
-rw-rw-r-- 1 fulongfei fulongfei  949955 1月  27 13:54 210120113_hla.bam
-rw-rw-r-- 1 fulongfei fulongfei 2885157 1月  27 13:54 210120113.hla.chr6region.1.fastq
-rw-rw-r-- 1 fulongfei fulongfei 2886263 1月  27 13:54 210120113.hla.chr6region.2.fastq
-rw-rw-r-- 1 fulongfei fulongfei 8229814 1月  27 13:54 210120113_hla.sam
-rw-rw-r-- 1 fulongfei fulongfei 1395670 1月  27 13:54 210120113_hla.sortByName.bam
-rw-rw-r-- 1 fulongfei fulongfei     138 1月  27 13:56 210120113.hla.xls
-rw-rw-r-- 1 fulongfei fulongfei     212 2月   4 11:34 210120113.neoantigens.Indels.summarytable.txt
-rw-rw-r-- 1 fulongfei fulongfei     873 2月   4 11:34 210120113.neoantigens.Indels.txt
-rw-rw-r-- 1 fulongfei fulongfei     221 2月   4 11:34 210120113.neoantigens.summarytable.txt
-rw-rw-r-- 1 fulongfei fulongfei   10800 2月   4 11:34 210120113.neoantigens.txt
-rw-rw-r-- 1 fulongfei fulongfei    2250 2月   4 15:14 210120113.Neo.Pred.Result.Final.xls
-rw-rw-r-- 1 fulongfei fulongfei      28 2月   4 15:15 210120113.TNB.txt
drwxrwxr-x 2 fulongfei fulongfei    4096 2月   4 11:33 avannotated
drwxrwxr-x 2 fulongfei fulongfei    4096 2月   4 11:33 avready
drwxrwxr-x 2 fulongfei fulongfei    4096 2月   4 13:14 fastaFiles
-rw-rw-r-- 1 fulongfei fulongfei     110 1月  27 13:56 hla.raw.result.tsv
-rw-rw-r-- 1 fulongfei fulongfei    1129 2月   4 11:33 logforannovarNeoPredPipe.txt
-rw-rw-r-- 1 fulongfei fulongfei    3786 2月   4 15:13 neo.210120113.sh
drwxrwxr-x 2 fulongfei fulongfei    4096 2月   4 11:34 tmp
drwxrwxr-x 2 fulongfei fulongfei    4096 1月  27 13:56 vcf
drwxrwxr-x 2 fulongfei fulongfei    4096 2月   2 17:09 vcf_clean
```

the final result file is: `*.Neo.Pred.Result.Final.xls` and `*.TNB.txt`.

`*.Neo.Pred.Result.Final.xls` is the final result (mut aa with strong affinity with MHC Class I) 

`*.TNB.txt` is the tumor neo-antigens burden (TNB)

## Output Format

1) `*.Neo.Pred.Result.Final.xls`

```
Sample  Line    VariantType     EpitopeLen      Gene    Chr     Pos     Ref     Alt     NM      Exon    c.HGVS  p.HGVS  VariantFunctionAnnot    RefDepth        AltDepth        VAF(%)  HLA     Peptide Core    Of      Gp      Gl      Ip      Il      Icore   Identity        Score   Affinity(nM)    Rank(%)
210120113       line174 SNV     9       FGF23   12      4488559 C       T       NM_020638       exon1   c.G190A p.A64T  nonsynonymous SNV       4065    9       0.22    HLA-B*54:01     TPHQTIYSA       TPHQTIYSA       0       0       0       0       0       TPHQTIYSA       line174_NM_020638       0.6947450       27.2    0.0408
210120113       line165 SNV     9       CFTR    7       117250645       C       T       NM_000492       exon19  c.C3061T        p.P1021S        nonsynonymous SNV       3473    8       0.23    HLA-C*03:04     YIFVATVSV       YIFVATVSV       0       0       0       0       0       YIFVATVSV       line165_NM_000492       0.6177520       62.5    0.2555
```

- **Sample**: sample name
- **Line**:   which line in VCF file
- **VariantType**: `SNV` or `InDel`
- **EpitopeLen**: length of epitope used by NetMHCPan
- **Gene**: gene name
- **Chr**: chrom
- **Pos**: ref pos
- **Ref**: ref base
- **Alt**: alt base
- **NM**: transcript NM_
- **Exon**: annot exon number
- **c.HGVS**: c.HGVS
- **p.HGVS**: p.HGVS
- **VariantFunctionAnnot**: `nonsynonymous SNV`, `frameshift deletion` et, al.
- **RefDepth**: ref depth
- **AltDepth**: alt depth
- **VAF(%)**: variant allele frequency
- **HLA**: HLA
- **Peptide**: Amino acid sequence of the potential ligand
- **Core**: The minimal 9 amino acid binding core directly in contact with the MHC
- **Of**: The starting position of the Core within the Peptide (if > 0, the method predicts a N-terminal protrusion)
- **Gp**: Position of the deletion, if any.
- **Gl**: Length of the deletion.
- **Ip**: Position of the insertions, if any.
- **Il**: Length of the insertion.
- **Icore**: Interaction core. This is the sequence of the binding core including eventual insertions of deletions.
- **Identity**: Protein identifier, i.e. the name of the Fasta entry.
- **Score**: The raw prediction score
- **Affinity(nM)**: Predicted binding affinity in nanoMolar units.
- **Rank(%)**: Rank of the predicted affinity compared to a set of random natural peptides. This measure is not affected by inherent bias of certain molecules towards higher or lower mean predicted affinities. Strong binders are defined as having %rank<0.5, and weak binders with %rank<2. We advise to select candidate binders based on %Rank rather than nM Affinity

> Note: from `Core` to `Rank` columns, these information you can get from NetMHC website: `http://www.cbs.dtu.dk/services/NetMHC/output.php`

2) `*.TNB.txt`

```
Sample  TNB
210120113       3.50/M
```
- **Sample (first col)**: sample name
- **TNB (second col)**: tumor neo-antigens burden

## How to filter VCF file

1) `FILTER` Column in VCF file is `PASS`

2) total depth >= 50X (for tissue) and >= 100X (for plasma)

3) alt reads num >= 3 (for tissue) and >= 5 (for plasma)

>Note: 

>1) we do not filter VAF at this stage, you can filter predict Neo result by VCF from final result file.

>2) `tcol`: the tumor col in VCF file

in this example, the TUMOR column in VCF is 10 (1-9 col is must column in VCF file)

```
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  TUMOR   NORMAL
```


## How to select peptide with strong affinity with MHC Class-I

at present, we use two values to filter the raw NetMHCPan result:

1) Rank <= 0.5 (default)

2) Affinity(nM) <= 500 (suggested by PVACtoos)

>Note: if a variant in VCF has >= 2 SB results, only one SB result with smallest affinity will be selected for this variant

## How to calculate TNB

1) calculate how many uniq variant in VCF (line is uniq): `neo_n`

2) TNB = `neo_n` / `cap_len_M`

>Note: `cap_len_M` is calculate by `len/1000000`, `len` is the exon region base number (bp)


>Note: if a variant in VCF file has >= 2 strong binder (SB) results (for example, this variant is a SB for `EpitopeLen` == 8 and a SB for `EpitopeLen` == 9), this variant is just treat as one unique neoantigens (we will choose the smallest affinity epitope for this variant)

## Software Needed
1. see `https://github.com/FRED-2/OptiType` for `OptiType` requirements
2. see `https://github.com/MathOnco/NeoPredPipe` for `NeoPredPipe` requirements

besides above, you also need:

1. python2
2. python3
3. samtools
4. bedtools

## Reference
1. NeoPredPipe: high-throughput neoantigen prediction and recognition potential pipeline, BMC Bioinformatics, 2019
2. https://github.com/MathOnco/NeoPredPipe


