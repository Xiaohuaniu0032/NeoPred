use strict;
use warnings;

my ($bam,$name,$ref_fa,$samtools,$bedtools,$outdir) = @ARGV;

# input: 1) normal bam; 2) name; 3) outdir; 4) ref fasta (used to check chrom naming <chr1 or 1>)
# output: fq1 & fq2 (for PE data)

sub chr_naming{
	my ($ref) = @_;
	open IN, "$ref" or die;
	my $h = <IN>;
	close IN;
	
	my $chr_name;
	if ($h =~ /^>chr/){
		$chr_name = "with_chr";
	}else{
		$chr_name = "no_chr";
	}
	
	return($chr_name);
}

my $chr_naming = &chr_naming($ref_fa);

# get SAM header
# get HLA-A/B/C reads (in SAM file)
# SAM->BAM
# sort by name
# bamtofastq using bedtools' bamtofastq

my $hla_sam = "$outdir/$name\_hla.sam";

my $cmd = "samtools view -H $bam >$hla_sam";
system($cmd);

my ($region1,$region2,$region3);
if ($chr_naming eq "with_chr"){
	$region1 = "chr6:29909037-29913661";
	$region2 = "chr6:31321649-31324964";
	$region3 = "chr6:31236526-31239869";
	
	# Note: we ignore chr6 contig (chr6_*_hap*)
	# chr6_apd_hap1/chr6_cox_hap2/chr6_dbb_hap3/chr6_mann_hap4/chr6_mcf_hap5/chr6_qbl_hap6/chr6_ssto_hap7
}else{
	$region1 = "6:29909037-29913661";
	$region2 = "6:31321649-31324964";
	$region3 = "6:31236526-31239869";
}

my $time = localtime();
print "[INFO]: Start extract HLA reads from normal bam at: $time\n";

$cmd = "$samtools view $bam $region1 >>$hla_sam";
system($cmd);

$cmd = "$samtools view $bam $region2 >>$hla_sam";
system($cmd);

$cmd = "$samtools view $bam $region3 >>$hla_sam";
system($cmd);

# sam to bam
my $hla_bam = "$outdir/$name\_hla.bam";
$cmd = "$samtools view -b -o $hla_bam $hla_sam";
system($cmd);

# sort by name
my $hla_bam_sort_by_name = "$outdir/$name\_hla.sortByName.bam";
$cmd = "$samtools sort -n $hla_bam -o $hla_bam_sort_by_name";
system($cmd);

# bam->fq
my $fq1 = "$outdir/$name\.hla.chr6region.1.fastq";
my $fq2 = "$outdir/$name\.hla.chr6region.2.fastq";

$cmd = "$bedtools bamtofastq -i $hla_bam_sort_by_name -fq $fq1 -fq2 $fq2";
system($cmd);

$time = localtime();
print "[INFO]: End extract HLA reads from normal bam at: $time\n";
