use strict;
use warnings;
use File::Basename;
use Getopt::Long;


my ($vcf,$tcol,$sample_type,$od);

GetOptions(
	"vcf:s" => \$vcf,             # Need
	"col:i" => \$tcol,            # Default: 10 (After FORMAT Column in VCF)
	"t:s"   => \$sample_type,     # Default: Tissue
	"od:s"  => \$od,              # Need
	) or die;


# check args
if (not defined $vcf || not defined $od){
	die "you need specify -vcf and -od args, please check your args\n";
}

# default value
if (not defined $tcol){
	$tcol = 10;
}

if (not defined $sample_type){
	$sample_type = "Tissue";
}

# check sample type
if ($sample_type ne "Tissue" and $sample_type ne "Plasma"){
	die "-t can only be: Tissue or Plasma\n";
}


# sample type specific value
my ($tdepth_cutoff,$tvaf_cutoff,$alt_n_cutoff);

if ($sample_type eq "Tissue"){
	$tdepth_cutoff = 50;   # depth must >= 50X
	$tvaf_cutoff   = 5;    # VAF must >= 5%
	$alt_n_cutoff  = 3;    # alt read num >= 3
}else{
	# for plasma
	$tdepth_cutoff = 100;  # >= 100X
	$tvaf_cutoff   = 1;    # VAF must >= 1%
	$alt_n_cutoff  = 5;    # alt read num >= 5
}


print "sample type is: $sample_type\n";
print "############# Default cutoff value is: #############\n\tTotalDepth\:$tdepth_cutoff\n\tVAF\:$tvaf_cutoff\n\tAltNum\:$alt_n_cutoff\n";
print "#######################################\n";


# filter rules:
# 1) FILTER: PASS
# 2) total depth filter
# 3) VAF filter
# 4) alt num filter

my $name = (split /\./, basename($vcf))[0];
print "auto detected sample name from VCF file is: $name\n";
;
my $new_vcf = "$od/$name\.vcf";

open O, ">$new_vcf" or die;

open IN, "$vcf" or die;
while (<IN>){
	chomp;
	if (/^##/){
		print O "$_\n";
	}elsif (/^#CHROM/){
		# header line
		print O "\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tTUMOR\n";
	}else{
		my @val = split /\t/;
		my @must_vcf_col = @val[0,1,2,3,4,5,6,7,8];
		my $tval = $val[$tcol - 1];
		push @must_vcf_col, $tval;
		my $val = join "\t", @must_vcf_col;

		next if ($val[6] ne "PASS");
		
		my $depth_info = (split /\:/, $val[-1])[1];
		my @depth = split /\,/, $depth_info;
		my $ref_n = int($depth[0]);
		my $alt_n = int($depth[1]);
		
		my $total_depth = $ref_n + $alt_n;

		my $vaf;
		if ($total_depth == 0){
			$vaf = 0;
		}else{
			$vaf = sprintf "%.2f", $alt_n/$total_depth * 100; # in % format
		}

		next if ($total_depth < $tdepth_cutoff);
		#next if ($vaf < $tvaf_cutoff);
		next if ($alt_n < $alt_n_cutoff);

		print O "$val\n";

	}
}
close IN;
close O;



