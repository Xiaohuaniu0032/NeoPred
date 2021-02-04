name='210120113'
vcf='/data3/Projects/panel889/210122_A00679_0483_BHV2VYDSXY/03_var/210120113.snvIndel.somatic.vcf'
nbam='/data3/Projects/panel889/210122_A00679_0483_BHV2VYDSXY/02_aln/210120113N.rmdup.bam'
od=$PWD
bed='/home/wangce/workdir/database/humandb/panel/889genes_20191225.bed'

perl ../NeoPred.pl -n $name -vcf $vcf -nbam $nbam -od $od -bed $bed
