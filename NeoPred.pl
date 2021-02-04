use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use FindBin qw/$Bin/;

my ($name,$tvcf,$sampleType,$nbam,$bed,$rank,$outdir,$col,$py2_bin,$py3_bin,$samtools,$bedtools,$ref);

GetOptions(
    "n:s" => \$name,                  # sample name             [Need]
    "vcf:s" => \$tvcf,                # tumor vcf file          [Need]
    "stype:s" => \$sampleType,        # sample type             [Default: Tissue] or Plasma
    "nbam:s" => \$nbam,               # normal bam file         [Need]
    "bed:s"  => \$bed,                # BED file                [Need]
    "rank:f" => \$rank,               # SB binder cutoff        [Default: < 0.5]
    "od:s" => \$outdir,               # output dir              [Need]
    "col:i" => \$col,                 # tumor col after FORMAT  [Default: 0] # FORMAT  TUMOR   NORMAL
    "py2:s" => \$py2_bin,             # python2                 [Default: /home/fulongfei/miniconda3/envs/py27/bin/python2]
    "py3:s" => \$py3_bin,             # python3                 [Default: /home/fulongfei/miniconda3/bin/python3]
    "samtools:s" => \$samtools,       # samtools bin            [Default: /home/fulongfei/miniconda3/bin/samtools]
    "bedtools:s" => \$bedtools,       # bedtools bin            [Default: /home/fulongfei/miniconda3/bin/bedtools]
    "ref:s" => \$ref,                 # ref fasta               [Default: /data1/database/b37/human_g1k_v37.fasta]
    ) or die;


# use NeoPredPipe software to do tumor neoantigenes prediction

# input file includes:
    # 1. tumor vcf
    # 2. normal bam (for HLA typing)

# tools used:
    # 1. NeoPredPipe (main software)
    # 2. OptiType (for HLA typing)
    # 3. Annovar (for annot VCF file)


# check args
if (not defined $name || not defined $tvcf || not defined $nbam || not defined $outdir || not defined $bed){
    die "please check you args spec\n";
}


# default values
if (not defined $py2_bin){
    $py2_bin = "/home/fulongfei/miniconda3/envs/py27/bin/python2";
}

if (not defined $py3_bin){
    $py3_bin = "/home/fulongfei/miniconda3/bin/python3";
}

if (not defined $samtools){
    $samtools = "/home/fulongfei/miniconda3/bin/samtools";
}

if (not defined $bedtools){
    $bedtools = "/home/fulongfei/miniconda3/bin/bedtools";
}

if (not defined $ref){
    $ref = "/data1/database/b37/human_g1k_v37.fasta";
}

if (not defined $col){
    $col = 0;

    # Note: 
    # if FORMAT  TUMOR   NORMAL => col = 0
    # if FORMAT  NORMAL  TUMOR  => col = 1
}

if (not defined $rank){
	$rank = 0.5; # default SB binder cutoff
}

if (not defined $sampleType){
	$sampleType = "Tissue";
}

# check sample type value
if ($sampleType ne "Tissue" and $sampleType ne "Plasma"){
	die "-stype can only be: Tissue or Plasma\n";
}

# make result dir
if (!-d "$outdir/$name"){
    `mkdir $outdir/$name`;
}


my $runsh = "$outdir/$name/neo\.$name\.sh";
open SH, ">$runsh" or die;

# get HLA region's fq1 & fq2
print SH "perl $Bin/bin/extract_hla_reads_from_nbam.pl $nbam $name $ref $samtools $bedtools $outdir/$name\n";

# do HLA typing
my $fq1 = "$outdir/$name/$name\.hla.chr6region.1.fastq";
my $fq2 = "$outdir/$name/$name\.hla.chr6region.2.fastq";
print SH "$py2_bin $Bin/tools/OptiType-1.3.2/OptiTypePipeline.py -i $fq1 $fq2 --dna -v -o $outdir/$name -c $Bin/tools/OptiType-1.3.2/config.ini.example\n";

# re-format HLA result
print SH "cp $outdir/$name/*/*_result.tsv $outdir/$name/hla.raw.result.tsv\n";
print SH "perl $Bin/bin/reformat_HLA_typing_result.pl $outdir/$name/hla.raw.result.tsv $name $outdir/$name\n";

# do neo antigene prediction
# make a dir to contain origin VCF (soft link)
if (!-d "$outdir/$name/vcf"){
    `mkdir $outdir/$name/vcf`;
}

print SH "cd $outdir/$name/vcf\n";
print SH "ln -s $tvcf $name\.vcf\n"; # obey NeoPredPipe's VCF naming

my $hla_result = "$outdir/$name/$name\.hla.xls"; # re-formatted hla


# filter VCF
if (!-d "$outdir/$name/vcf_clean"){
	`mkdir $outdir/$name/vcf_clean`;
}

my $cmd = "perl $Bin/bin/filter_tumor_vcf.pl -vcf $tvcf -od $outdir/$name/vcf_clean -t $sampleType";
print SH "$cmd\n";


# main method
print SH "$py3_bin $Bin/tools/NeoPredPipe/NeoPredPipe.py -I $outdir/$name/vcf_clean -H $hla_result -o $outdir/$name -n $name -c $col -E 8 9 10\n";



# get SB peptide
# outfile is: *.epi.[8|9|10].[SNV|InDel].final.result.xls
my @len = qw/8 9 10/;
my @type = qw/SNV InDel/;

for my $len (@len){
	for my $t (@type){
		$cmd = "perl $Bin/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n $name -t $t -l $len -d $outdir -od $outdir/$name";
		print SH "$cmd\n";
	}
}

# summary SNV & InDel result into final result file
# outfile is: *.Neo.Pred.Result.Final.xls
$cmd = "perl $Bin/bin/summary_result.pl $outdir/$name $name $outdir/$name";
print SH "$cmd\n";


# calculate tumor neo burden (TNB)
# outfile is: *.TNB.txt
my $neo_res = "$outdir/$name/$name\.Neo.Pred.Result.Final.xls";
$cmd = "perl $Bin/bin/cal_TNB.pl $neo_res $name $bed $outdir/$name\n";
print SH "$cmd\n";


close SH;









