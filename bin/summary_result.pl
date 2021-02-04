use strict;
use warnings;

# 合并所有SNV & InDel结果
# sort by line number
# fisrt SNV, then InDel


my ($resdir,$name,$outdir) = @ARGV;

my $outfile = "$outdir/$name\.Neo.Pred.Result.Final.xls";
open my $res_fh, ">$outfile" or die;
print $res_fh "Sample\tLine\tVariantType\tEpitopeLen\tGene\tChr\tPos\tRef\tAlt\tNM\tExon\tc.HGVS\tp.HGVS\tVariantFunctionAnnot\tRefDepth\tAltDepth\tVAF(%)\tHLA\tPeptide\tCore\tOf\tGp\tGl\tIp\tIl\tIcore\tIdentity\tScore\tAffinity(nM)\tRank(%)\n";

print "[INFO]: Final Pred Neo Result Will Write into: $outfile\n";

my $len_8_snv  = "$resdir/$name\.epi.8.SNV.final.result.xls";
my $len_9_snv  = "$resdir/$name\.epi.9.SNV.final.result.xls";
my $len_10_snv = "$resdir/$name\.epi.10.SNV.final.result.xls";

my $len_8_indel  = "$resdir/$name\.epi.8.InDel.final.result.xls";
my $len_9_indel  = "$resdir/$name\.epi.9.InDel.final.result.xls";
my $len_10_indel = "$resdir/$name\.epi.10.InDel.final.result.xls";


&WriteRes($len_8_snv,$res_fh);
&WriteRes($len_9_snv,$res_fh);
&WriteRes($len_10_snv,$res_fh);

&WriteRes($len_8_indel,$res_fh);
&WriteRes($len_9_indel,$res_fh);
&WriteRes($len_10_indel,$res_fh);

close $res_fh;


sub WriteRes{
    my ($infile,$ofh) = @_;

    # check input file
    die "can not find $infile\n" if (!-e $infile);

    open IN, "$infile" or die;
    <IN>;
    while (<IN>){
        chomp;
        print $ofh "$_\n";
    }
    close IN;
}
