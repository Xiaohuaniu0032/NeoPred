use strict;
use warnings;

# translate OptiType HLA result into NeoPredPipe's input format

my ($hla_input,$name,$outdir) = @ARGV;


# if HLA-A/B/C is homo, then A/B/C_2 is NA
my $outfile = "$outdir/$name\.hla.xls";
open O, ">$outfile" or die;
print O "Patient\tHLA-A_1\tHLA-A_2\tHLA-B_1\tHLA-B_2\tHLA-C_1\tHLA-C_2\n";

open IN, "$hla_input" or die;
<IN>;
my $line = <IN>;
close IN;
chomp $line;
my @val = split /\t/, $line;

my $a1 = &get_hla_res($val[1],'a');
my $a2 = &get_hla_res($val[2],'a');

my $b1 = &get_hla_res($val[3],'b');
my $b2 = &get_hla_res($val[4],'b');

my $c1 = &get_hla_res($val[5],'c');
my $c2 = &get_hla_res($val[6],'c');

print O "$name";

if ($a1 eq $a2){
	print O "\t$a1\tNA";
}else{
	print O "\t$a1\t$a2";
}

if ($b1 eq $b2){
	print O "\t$b1\tNA";
}else{
	print O "\t$b1\t$b2";
}

if ($c1 eq $c2){
	print O "\t$c1\tNA";
}else{
	print O "\t$c1\t$c2";
}

print O "\n";
close O;



sub get_hla_res{
	my ($hla,$flag) = @_;
	my $hla_int = (split /\*/, $hla)[1];
	my @hla_int = split /\:/, $hla_int;
	my $res = "hla_".$flag."_".$hla_int[0]."_".$hla_int[1];
	return($res);
}
	



