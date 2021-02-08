use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;


##################
# SNV && InDel

my ($name,$type,$resdir,$len,$aff_cutoff,$rank_cutoff,$outdir);

GetOptions(
    "n:s"    =>   \$name,          # Need
    "t:s"    =>   \$type,          # Need [SNV | InDel]
    "d:s"    =>   \$resdir,        # Need
    "l:i"    =>   \$len,           # Need
    "aff:i"  =>   \$aff_cutoff,    # Default: 500
    "rank:f" =>   \$rank_cutoff,   # Default: 0.5
    "od:s"   =>   \$outdir,        # Need
    ) or die;


# check args
if (not defined $name || not defined $resdir || not defined $len || not defined $outdir || not defined $type){
    die "please check args\n";
}

if ($type ne "SNV" and $type ne "InDel"){
    die "-t only accept SNV or InDel, please check your args\n";
}

# default value
if (not defined $aff_cutoff){
    $aff_cutoff = 500;
}

if (not defined $rank_cutoff){
    $rank_cutoff = 0.5;
}


# get files
my $raw_pred_res;
if ($type eq "SNV"){
    $raw_pred_res = "$resdir/$name/tmp/$name\.epitopes\.$len\.txt"; # for SNV
}else{
    $raw_pred_res = "$resdir/$name/tmp/$name\.epitopes\.$len\.Indels.txt"; # for InDel
}

my $exon_annot_file     = "$resdir/$name/avannotated/$name\.avannotated.exonic_variant_function";
my $reformat_fasta_file = "$resdir/$name/fastaFiles/$name\.reformat.fasta";

die "can not find $raw_pred_res\n"         if (!-e $raw_pred_res);
die "can not find $exon_annot_file\n"      if (!-e $exon_annot_file);
die "can not find $reformat_fasta_file\n"  if (!-e $reformat_fasta_file);

print "raw pred file is:       $raw_pred_res\n";
print "exon annot file is:     $exon_annot_file\n";
print "reformat fasta file is: $reformat_fasta_file\n";

# read NetMHCPan raw result
# just get SB and <= aff_cutoff peptides


################ 读取*.avannotated.exonic_variant_function
my %line2annot; # 记录每个line编号对应的基因注释信息
my %line2gene; # line对应的基因名(可能注释到2个及以上个基因名)

my ($gene,$nm,$ex,$c_av,$p_av);
my ($ref_n,$alt_n);

open EXON, "$exon_annot_file" or die;
while (<EXON>){
    chomp;
    my @arr = split /\t/, $_;
    my $annot_info = $arr[2];
    $annot_info =~ s/\,$//; # remove last ,
    my $gt = $arr[-2];
    my @gt = split /\:/, $gt;
    my $col = 0;
    my $AD_col = 0;
    for my $e (@gt){
        $col += 1;
        if ($e eq "AD"){
            $AD_col = $col;
            last;
        }
    }

    if ($AD_col == 0){
        $ref_n = 0;
        $alt_n = 0;
        print "Warning: can not find AD info in GT colum, the RefNum and AltNum will be set as 0,0 (used to calculate VAF for later filter)\n";
    }

    my $depth = (split /\:/, $arr[-1])[$col-1]; # 0/0:748,0:0.00:0:0:.:26702,0:349:399
    #print "$depth\n";
    my @ad = split /\,/, $depth;
    my $ref_n = int($ad[0]);
    my $alt_n = int($ad[1]);

    my @gene;
    if ($annot_info =~ /\,/){
        my @annot = split /\,/, $annot_info;
        for my $item (@annot){
            my @item = split /\:/, $item; # ERRFI1:NM_018948:exon4:c.G960A:p.P320P,
            $gene = $item[0];
            $nm = $item[1];
            $ex = $item[2];
            $c_av = $item[3];
            $p_av = $item[4];

            push @{$line2gene{$arr[0]}}, $gene;

            $line2annot{$arr[0]}{$gene}{$nm} = "$ex\t$c_av\t$p_av\t$ref_n\t$alt_n\t$arr[3]\t$arr[4]\t$arr[6]\t$arr[7]\t$arr[1]"; # line=>gene=>NM=>"exon4/c.G960A/p.P320P/refN/altN/chr/pos/ref/alt/varType"
            # varType is: nonsynonymous SNV ...

        }
    }else{
        my @item = split /\:/, $annot_info;
        $gene = $item[0];
        $nm = $item[1];
        $ex = $item[2];
        $c_av = $item[3];
        $p_av = $item[4];
        push @{$line2gene{$arr[0]}}, $gene;

        $line2annot{$arr[0]}{$gene}{$nm} = "$ex\t$c_av\t$p_av\t$ref_n\t$alt_n\t$arr[3]\t$arr[4]\t$arr[6]\t$arr[7]\t$arr[1]"; # line=>gene=>NM=>"exon4/c.G960A/p.P320P/refN/altN/chr/pos/ref/alt/varType"
        # varType is: nonsynonymous SNV ...
        
    }
}
close EXON;


################读取 /fastaFiles/210120113.reformat.fasta文件
# NetMHCPan输出结果NM号显示不全, 该文件保存完整NM号
# 记录WILDTYPE氨基酸, 如果NetMHCPan预测的短肽为SB, 则检查该段肽是否在WILDTYPE中, 如果在, 则过滤掉
my %nm2aa;
my %line2nm; # 一个line对应一个NM号

my $line_name;
open NM, "$reformat_fasta_file" or die;
while (<NM>){
    chomp;
    next if (/^$/);
    if (/^\>/){
        s/^\>//;
        my @arr = split /\;/, $_;
        
        my $type;
        if (/WILDTYPE/){
            $type = 'WT'; # wild type
        }else{
            $type = 'MT'; # mutant type
        }

        $line_name = "$arr[0]\t$arr[1]\t$type"; # line/NM/type

        $line2nm{$arr[0]} = $arr[1]; # line => NM
    }else{
        #print "$line_name\n";
        #print "$_\n";

        push @{$nm2aa{$line_name}}, $_;
    }
}
close NM;

#print(Dumper(\%nm2aa));





################################# output final result #################################

my $outfile = "$outdir/$name\.epi\.$len\.$type\.final.result.xls";

open O, ">$outfile" or die;
print O "\#Sample\tLine\tVariantType\tEpitopeLen\tGene\tChr\tPos\tRef\tAlt\tNM\tExon\tc.HGVS\tp.HGVS\tVariantFunctionAnnot\tRefDepth\tAltDepth\tVAF(%)\tHLA\tPeptide\tCore\tOf\tGp\tGl\tIp\tIl\tIcore\tIdentity\tScore\tAffinity(nM)\tRank(%)\n";

open IN, "$raw_pred_res" or die;
while (<IN>){
    chomp;
    next if /^\#/;
    next if /^$/;
    #next if /Distance/;
    s/^\s+//; # remove head \s
    s/\s+$//; # remove tail \s
    my @arr = split /\s+/, $_;
    if ($arr[0] =~ /^\d/){
        #print "$_\n";
        my $line = (split /\_/, $arr[10])[0]; # line138_NM_0150
        my $nm = $line2nm{$line};
        
        #print "$line\n";
        if ($arr[13] <= $rank_cutoff and $arr[12] <= $aff_cutoff){
            # a strong binder
            print "$_\n";

            # get annot info
            # first get gene name
            # a line may have multi gene names

            if (exists $line2annot{$line}){
                # this line have annot info
                my @genes = keys %{$line2annot{$line}};
                for my $gene (@genes){
                    # a gene may have multi NM
                        
                    # get annot info
                    if (exists $line2annot{$line}{$gene}{$nm}){
                        my $annot_info = $line2annot{$line}{$gene}{$nm}; # exon4/c.G960A/p.P320P/refN/altN/chr/pos/ref/alt/varType
                        my @annot_info = split /\t/, $annot_info;

                        # print
                        my $vaf;
                        my $ref_n = $annot_info[3];
                        my $alt_n = $annot_info[4];
                        my $all_n = $ref_n + $alt_n;

                        if ($all_n == 0){
                            $vaf = 0;
                        }else{
                            $vaf = sprintf "%.2f", $alt_n/$all_n * 100;
                        }

                        my $id = "$line\_$nm";

                        if ($type eq "SNV"){
                            # for SNV, do not check WT for existence
                            print O "$name\t$line\t$type\t$len\t$gene\t$annot_info[-5]\t$annot_info[-4]\t$annot_info[-3]\t$annot_info[-2]\t$nm\t$annot_info[0]\t$annot_info[1]\t$annot_info[2]\t$annot_info[-1]\t$annot_info[3]\t$annot_info[4]\t$vaf\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$arr[9]\t$id\t$arr[11]\t$arr[12]\t$arr[13]\n";
                        }else{
                            # for InDel, check WT for existence
                            # get WT AA seq

                            my $wt_name = "$line\t$nm\tWT";
                            my @wt_aa = @{$nm2aa{$wt_name}};
                            my $wt_aa_seq = "";
                            
                            for my $i (@wt_aa){
                                $wt_aa_seq = $wt_aa_seq.$i;
                            }

                            if ($wt_aa_seq =~ /$arr[2]/){
                                # mut aa seq in WT seq
                                next;
                            }else{
                                print O "$name\t$line\t$type\t$len\t$gene\t$annot_info[-5]\t$annot_info[-4]\t$annot_info[-3]\t$annot_info[-2]\t$nm\t$annot_info[0]\t$annot_info[1]\t$annot_info[2]\t$annot_info[-1]\t$annot_info[3]\t$annot_info[4]\t$vaf\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$arr[9]\t$id\t$arr[11]\t$arr[12]\t$arr[13]\n";
                            }
                        }
                    }
                }
            }
        }
    }
}

close IN;
close O;



