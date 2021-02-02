use strict;
use warnings;
use File::Basename;

# get SB neo from final result file
# sort by Rank (from small to large, SB default: < 0.5)
#

# infile is: *.neoantigens.txt / *.neoantigens.Indels.txt

my ($infile,$type,$rank,$od) = @ARGV;

my $name = (split /\./, basename($infile))[0];
my $outfile = "$od/$name\.neo\.$type.strong.binder.SB.xls";


my %sb;
my $sb_n = 0;
open IN, "$infile" or die;
while (<IN>){
	chomp;
	my @arr = split /\t/;
#	if ($arr[-1] eq "SB"){
	if ($arr[-3] <= $rank){ # default Rank: <0.5
		# this peptide is likely a strong binder
		$sb{$_} = $arr[-3];
		$sb_n += 1;
	}
}
close IN;

print "[INFO]: find $sb_n SB neo peptide for $name\n";

open O, ">$outfile" or die;
print O "Sample\tR1\tLine\tChr\tRefPos\tRef\tAlt\tGeneName:RefSeqID\tPos\tHLA\tPeptide\tCore\tOf\tGp\tGl\tIp\tIl\tIcore\tIdentity\tScore\tAff(nM)\tRank(%)\tCandidate\tBindLevel\n";

foreach my $line (sort {$sb{$a} <=> $sb{$b}} keys %sb){
	# sort by Rank
	print O "$line\n";
}
close O;


