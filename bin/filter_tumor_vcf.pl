use strict;
use warnings;
use File::Basename;

my ($vcf,$od) = @ARGV;

# filter rules:
# 1) FILTER: PASS
# 2) Depth:
# 3) tumor VAF: >= 1% for tissue; >= 0.1% for plasma
#
my $name = (split /\./, basename($vcf))[0];
print "auto detected sample name from VCF file is: $name\n";

my $new_vcf = "$od/$name\.vcf";

open O, ">$new_vcf" or die;

open IN, "$vcf" or die;
while (<IN>){
	chomp;
	if (/^#/){
		print O "$_\n";
	}else{
		my @val = split /\t/;
		if ($val[6] eq "PASS"){
			print O "$_\n";
		}
	}
}
close IN;
close O;



