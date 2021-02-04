perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/extract_hla_reads_from_nbam.pl /data3/Projects/panel889/210122_A00679_0483_BHV2VYDSXY/02_aln/210120113N.rmdup.bam 210120113 /data1/database/b37/human_g1k_v37.fasta /home/fulongfei/miniconda3/bin/samtools /home/fulongfei/miniconda3/bin/bedtools /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
/home/fulongfei/miniconda3/envs/py27/bin/python2 /data1/workdir/fulongfei/git_repo/NeoPred/tools/OptiType-1.3.2/OptiTypePipeline.py -i /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/210120113.hla.chr6region.1.fastq /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/210120113.hla.chr6region.2.fastq --dna -v -o /home/fulongfei/workdir/git_repo/NeoPred/test/210120113 -c /data1/workdir/fulongfei/git_repo/NeoPred/tools/OptiType-1.3.2/config.ini.example
cp /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/*/*_result.tsv /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/hla.raw.result.tsv
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/reformat_HLA_typing_result.pl /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/hla.raw.result.tsv 210120113 /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
cd /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/vcf
ln -s /data3/Projects/panel889/210122_A00679_0483_BHV2VYDSXY/03_var/210120113.snvIndel.somatic.vcf 210120113.vcf
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/filter_tumor_vcf.pl -vcf /data3/Projects/panel889/210122_A00679_0483_BHV2VYDSXY/03_var/210120113.snvIndel.somatic.vcf -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/vcf_clean -t Tissue
/home/fulongfei/miniconda3/bin/python3 /data1/workdir/fulongfei/git_repo/NeoPred/tools/NeoPredPipe/NeoPredPipe.py -I /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/vcf_clean -H /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/210120113.hla.xls -o /home/fulongfei/workdir/git_repo/NeoPred/test/210120113 -n 210120113 -c 0 -E 8 9 10
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n 210120113 -t SNV -l 8 -d /home/fulongfei/workdir/git_repo/NeoPred/test -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n 210120113 -t InDel -l 8 -d /home/fulongfei/workdir/git_repo/NeoPred/test -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n 210120113 -t SNV -l 9 -d /home/fulongfei/workdir/git_repo/NeoPred/test -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n 210120113 -t InDel -l 9 -d /home/fulongfei/workdir/git_repo/NeoPred/test -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n 210120113 -t SNV -l 10 -d /home/fulongfei/workdir/git_repo/NeoPred/test -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/parse_NetMHCPan_raw_result.SNV.InDel.pl -n 210120113 -t InDel -l 10 -d /home/fulongfei/workdir/git_repo/NeoPred/test -od /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/summary_result.pl /home/fulongfei/workdir/git_repo/NeoPred/test/210120113 210120113 /home/fulongfei/workdir/git_repo/NeoPred/test/210120113
perl /data1/workdir/fulongfei/git_repo/NeoPred/bin/cal_TNB.pl /home/fulongfei/workdir/git_repo/NeoPred/test/210120113/210120113.Neo.Pred.Result.Final.xls 210120113 /home/wangce/workdir/database/humandb/panel/889genes_20191225.bed /home/fulongfei/workdir/git_repo/NeoPred/test/210120113

