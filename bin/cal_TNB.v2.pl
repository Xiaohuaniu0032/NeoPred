use strict;
use warnings;


############ Note ##################
# this script is only used in Letu Beijing
# for other users, please use general cal_TNB.pl script
#
# 2021/2/5
####################################

my ($neo_res,$tmb_res,$name,$cds_len,$outdir) = @ARGV;

# check file exists
die "can not find $neo_res\n" if (!-e $neo_res);
die "can not find $tmb_res\n" if (!-e $tmb_res);

print "BED cap len (in bp) is: $cds_len\n";
my $cds_len_M = sprintf "%.2f", $cds_len/1000000;
print "BED cap len (in Mbp) is: $cds_len_M\n";


# read tmb file
my %var_tmb;
open TMB, "$tmb_res" or die;
while (<TMB>){
	chomp;
	next if /^\#/;
	my @arr = split /\t/;
	my $var = "$arr[1]\t$arr[2]\t$arr[4]\t$arr[5]"; # chr/pos/ref/alt
	$var_tmb{$var} = 1;
}
close TMB;

	
# cal how much line
my @line;
open IN, "$neo_res" or die; # filter out variants that do not exist in tmb file
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $var = "$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]";
	if (exists $var_tmb{$var}){
		push @line, $arr[1];
	}else{
		print "$var do not exists in $tmb_res file, please pay attentation\n";
	}
}
close IN;

my $neo_n = 0;
my %line;
for my $i (@line){
	if (!exists $line{$i}){
		$line{$i} = 1;
		$neo_n += 1;
	}
}
print "$name has $neo_n Uniq neo antigens\n";

my $outfile = "$outdir/$name\.TNB.txt";
open O, ">$outfile" or die;
print O "Sample\tTNB\n";

my $tnb = sprintf "%.2f", $neo_n/$cds_len_M;
print "$name TNB (tumor neoantigens burden) is: $tnb\/M\n";
print O "$name\t$tnb\/M\n";
close O;

