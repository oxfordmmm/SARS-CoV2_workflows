process pango {
    tag { sampleName }
    label 'pango'

    publishDir "${params.outdir}/analysis/pango/${params.prefix}", mode: 'copy'

    input:
    tuple(val(sampleName),  path(fasta))

    output:
    tuple(val(sampleName), path("${sampleName}_lineage_report.csv"))

    script:
    """
    pangolin ${fasta}
    mv lineage_report.csv ${sampleName}_lineage_report.csv
    """
}

process  download_primers {
    input:
        val(primers) 

    output:
        path('primers.txt')

    script:
        """
        wget https://raw.githubusercontent.com/iqbal-lab-org/viridian_workflow/master/data/covid-artic-v3.json -O primers.txt
        """
}


process download_nextclade_files {
    label 'nextclade'

    publishDir "${params.outdir}/analysis/nextclade/${params.prefix}", mode: 'copy'
    output:
    file('nextclade_files')

    script:
    """
    home=PWD
    nextclade_ver=`(nextclade -V)`
    nextclade dataset get --name 'sars-cov-2' --output-dir nextclade_files
    echo \$nextclade_ver > nextclade_files/version.txt

    """

}


process nextclade {
    tag { sampleName }
    label 'nextclade'

    publishDir "${params.outdir}/analysis/nextclade/${params.prefix}", mode: 'copy'

    input:
    tuple(val(sampleName),  path(fasta), path(reffasta), path(nextclade_files)) 

    output:
    tuple val(sampleName), path("${sampleName}.tsv"), emit: tsv
    tuple val(sampleName), path("${sampleName}.json"), emit: json

    script:
    """
    nextclade run \
	--input-dataset=nextclade_files \
    --output-all= ./ \
	--output-basename=${sampleName} \
    ${fasta}
    nextclade_ver=`(nextclade -V)`
    """
}

process getVariantDefinitions {
    label 'aln2type'

    publishDir "${params.outdir}/analysis/aln2type/${params.prefix}", mode: 'copy'

    output:
    path "variant_definitions", emit: defs
//    path("aln2type_variant_git_version.txt"), emit: vers

    script:
    """
    git clone https://github.com/phe-genomics/variant_definitions
    cd variant_definitions
    git log -1 --pretty=format:"%h" > aln2type_variant_git_commit.txt
    git describe --tags > aln2type_variant_version.txt
    git config --global --add safe.directory /aln2type
    git -C /aln2type log -1 --pretty=format:"%h" > aln2type_commit.txt
    """
}

process getWorkflowCommit {
    label 'sars_cov2_workflows'

    output:
    path "workflowcommit.txt", emit: commit

    script:
    """
    git config --global --add safe.directory $projectDir
    git -C $projectDir log -1 --pretty=format:"%h" > workflowcommit.txt
    """
}


process aln2type {
    tag { sampleName }
    label 'aln2type'

    publishDir "${params.outdir}/analysis/aln2type/${params.prefix}", mode: 'copy'

    input:
    tuple(val(sampleName),  path(fasta),path(variant_definitions), path(reffasta), path("*"))

    output:
    tuple(val(sampleName), path("${sampleName}.csv")) optional true

    script:
    """
    cat $reffasta  ${fasta} > unaligned.fasta
    mafft --auto unaligned.fasta > aln.fasta
    aln2type sample_json_out \
	sample_csv_out \
	--output_unclassified \
	${sampleName}.csv \
	MN908947.3 \
	aln.fasta \
	variant_definitions/variant_yaml/*.yml

    """
}


process makeReport {
    tag { sampleName }
    label 'sars_cov2_workflows'

    publishDir "${params.outdir}/analysis/report/${params.prefix}", mode: 'copy'

    input:
    tuple(val(sampleName), path('pango.csv'), path('aln2type.csv'), path('nextclade.tsv'), path('nextclade.json'),
	path('workflow_commit.txt'), val(manifest_ver), path(nextclade_files),
	path(variant_definitions), path('consensus.fasta'),path('ref.fasta'))

    output:
    tuple val(sampleName),path("${sampleName}_report.tsv"), emit: tsv
    tuple val(sampleName),path("${sampleName}_report.json"), emit: json

    script:
    """
    makeReport.py ${sampleName} ${manifest_ver}
    """
}

process FN4_upload {
    tag { sampleName }
    label 'fn4'

    input:
    tuple(val(sampleName),  file('consensus.fasta'), path(variant_definitions), path(reffasta), path("*"))

    script:
    """
    mafft --auto \
        --thread 1 \
        --addfull 'consensus.fasta' \
        --keeplength $reffasta \
        > ${sampleName}_wuhan.fa

    FN4ormater.py -i ${sampleName}_wuhan.fa -r MN908947.3 -s ${sampleName} -o ${sampleName}.fasta

    oci os object put \
	-bn ${params.bucketNameFN4} \
	--force \
    --auth instance_principal \
	--file ${sampleName}.fasta \
	--metadata "{\\"sampleID\\":\\"$sampleName\\"}"

    """
}


process getGFF3 {
    label 'bcftools'

    output:
    path "MN908947.3.gff3"

    script:
    """
    esearch -db nucleotide -query "MN908947.3" | efetch -format gb > MN908947.3.gb

    cat MN908947.3.gb | gbk2gff3.py > MN908947.3.gff3
    """
}

process bcftools_csq {
    tag { sampleName }
    label 'bcftools'

    publishDir "${params.outdir}/analysis/bcftools/${params.prefix}", mode: 'copy'

    input:
    tuple(val(sampleName), path('vcf'), path('reffasta'), path('GFF3'))

    output:
    tuple(val(sampleName), path("${sampleName}.vcf")) optional true

    script:
    """
    bcftools csq \
	-f reffasta \
	-g GFF3 \
	vcf \
	-Ot -o ${sampleName}.vcf \
	--force
    """
}
