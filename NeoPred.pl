use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use FindBin qw/$Bin/;

my ($name,$tvcf,$nbam,$outdir,$col,$py2_bin,$py3_bin,$samtools,$bedtools,$ref);

GetOptions(
    "n:s" => \$name,                  # sample name         [Need]
    "vcf:s" => \$tvcf,                # tumor vcf file      [Need] 
    "nbam:s" => \$nbam,               # normal bam file     [Need]
    "od:s" => \$outdir,               # output dir          [Need]
    "col:i" => \$col,                 # not normal col in VCF after the FORMAT field      [Need]
    "py2:s" => \$py2_bin,             # python2             [Default: /home/fulongfei/miniconda3/envs/py27/bin/python2]
    "py3:s" => \$py3_bin,             # python3             [Default: /home/fulongfei/miniconda3/bin/python3]
    "samtools:s" => \$samtools,       # samtools bin        [Default: /home/fulongfei/miniconda3/bin/samtools]
    "bedtools:s" => \$bedtools,       # bedtools bin        [Default: /home/fulongfei/miniconda3/bin/bedtools]
    "ref:s" => \$ref,                 # ref fasta           [Default: /data1/database/b37/human_g1k_v37.fasta]
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
if (not defined $name || not defined $tvcf || not defined $nbam || not defined $outdir){
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
`cp $outdir/$name/*/*_result.tsv $outdir/$name/hla.raw.result.tsv`;
print SH "perl $Bin/bin/reformat_HLA_typing_result.pl $$outdir/$name/hla.raw.result.tsv $name $outdir/$name\n";

# do neo antigene prediction
# make a dir to contain origin VCF (soft link)
if (!-d "$outdir/$name/vcf"){
    `mkdir $outdir/$name/vcf`;
}

`cd $outdir/$name/vcf`;
`ln -s $vcf $name\.vcf`; # obey NeoPredPipe's VCF naming

my $hla_result = "$outdir/$name\.hla.xls"; # re-formatted hla
print SH "$py3_bin $Bin/tools/NeoPredPipe/NeoPredPipe.py -I $outdir/$name/vcf -H $hla_result -o $outdir/$name -n $name -c $col -E 8 9 10\n";

close SH;



sub tumor_vcf_format_col{
    # Columns of regions within vcf that are not normal within a multiregion vcf file after the format field.
    # Example: 0 is normal in test samples, tumor are the other columns.

    my ($vcf) = @_;
    open IN, "$vcf" or die;
    while (<IN>){
        chomp;
        if /
    }








