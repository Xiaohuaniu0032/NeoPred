use strict;
use warnings;

my ($neo_res,$name,$bed,$outdir) = @ARGV;

# check file exists
die "can not find $neo_res\n" if (!-e $neo_res);


# cal bed length
my $cap_len = 0;
open BED, "$bed" or die;
while (<BED>){
	chomp;
	my @arr = split /\t/;
	my $base_n = $arr[2] - $arr[1];
	$cap_len += $base_n;
}
close IN;

print "BED cap len (in bp) is: $cap_len\n";
my $cap_len_M = sprintf "%.2f", $cap_len/1000000;
print "BED cap len (in Mbp) is: $cap_len_M\n";

# cal how much line
my @line;
open IN, "$neo_res" or die;
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	push @line, $arr[1];
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

my $tnb = sprintf "%.2f", $neo_n/$cap_len_M;
print "$name TNB (tumor neoantigens burden) is: $tnb\/M\n";
print O "$name\t$tnb\/M\n";
close O;

