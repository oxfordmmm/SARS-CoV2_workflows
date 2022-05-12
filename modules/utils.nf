process getObjFiles {
    /**
    * fetches fastq files from object store using OCI bulk download (https://docs.oracle.com/en-us/iaas/tools/oci-cli/2.24.4/oci_cli_docs/cmdref/os/object/bulk-download.html)
    * @input
    * @output
    */

    tag { prefix }
    label 'oci_pipe'

    input:
        tuple val(bucket), val(filePrefix), val(prefix)

    output:
        tuple val(prefix), path("${prefix}*1.fastq.gz"), path("${prefix}*2.fastq.gz"), emit: fqs

    script:
        """
	echo "kff - Running getObjFiles from mudules|units"
	oci os object bulk-download \
		-bn $bucket \
		--download-dir ./ \
		--overwrite \
		--auth instance_principal \
		--prefix $filePrefix 
    
    if [ \$(find * -type d | wc -l) -gt 0 ]
    then 
        mv */*.fastq.gz .
    fi
	"""
}

process checkSizeSubsample {
    /**
    * subsamples down to a max read number if above that
    * @input
    * @output
    */

    tag { prefix }
    label 'oci_pipe'

    input:
        tuple val(prefix), path("${prefix}_1.fastq.gz"), path("${prefix}_2.fastq.gz")

    output:
        tuple val(prefix), path("${prefix}_1.fastq.gz"), path("${prefix}_2.fastq.gz"), emit: checked_fqs

    script:
        maxReadsIll=params.maxReadsIll
        """
	echo "kff - Running checkSizeSubsample from mudules|units"
        lines=\$(zcat ${prefix}_1.fastq.gz | wc -l);reads=\$((\$lines / 4))
        if (( \$reads > $maxReadsIll ))
        then
            echo "${prefix} has \$reads reads which is more than maximum of $maxReadsIll. Subsampling down to this value."
            gunzip -c ${prefix}_1.fastq.gz | seqtk sample -s 100 - $maxReadsIll | gzip > ${prefix}_1_sub.fastq.gz
            mv ${prefix}_1_sub.fastq.gz ${prefix}_1.fastq.gz

            gunzip -c ${prefix}_2.fastq.gz | seqtk sample -s 100 - $maxReadsIll | gzip > ${prefix}_2_sub.fastq.gz
            mv ${prefix}_2_sub.fastq.gz ${prefix}_2.fastq.gz
        else
            echo "${prefix} has \$reads reads, no subsampling is needed"
        fi
        """
}

process getObjFilesONT {
    /**
    * fetches fastq files from object store using OCI bulk download (https://docs.oracle.com/en-us/iaas/tools/oci-cli/2.24.4/oci_cli_docs/cmdref/os/object/bulk-download.html)
    * @input
    * @output
    */

    tag { prefix }
    label 'oci_pipe'

    input:
        tuple val(bucket), val(filePrefix), val(prefix)

    output:
        tuple val(prefix), path("*.fastq.gz"), emit: fqs

    script:
        """
	echo "kff - Running getObjFilesONT from modules|utils"
	oci os object bulk-download \
		-bn $bucket \
		--download-dir ./ \
		--overwrite \
		--auth instance_principal \
		--prefix $filePrefix
    
    if [ \$(find * -type d | wc -l) -gt 0 ]
    then 
        mv */*.fastq.gz .
    fi
	"""
}

process checkSizeSubsampleONT {
    /**
    * subsamples down to a max read number if above that
    * @input
    * @output
    */

    tag { prefix }
    label 'oci_pipe'

    input:
        tuple val(prefix), path("*.fastq.gz")

    output:
        val(prefix), path("${prefix}.fastq.gz"), emit: checked_fqs

    script:
        maxReadsONT=params.maxReadsONT
        """
	echo "kff- Running checkSizeSubsampleOnt from modules|utils"
        lines=\$(zcat ${prefix}.fastq.gz | wc -l);reads=\$((\$lines / 4))
        if (( \$reads > $maxReadsONT ))
        then
            echo "${prefix} has \$reads reads which is more than maximum of $maxReadsONT. Subsampling down to this value."
            gunzip -c ${prefix}.fastq.gz | seqtk sample -s 100 - $maxReadsONT | gzip > ${prefix}_sub.fastq.gz
            mv ${prefix}_sub.fastq.gz ${prefix}.fastq.gz
        else
            echo "${prefix} has \$reads reads, no subsampling is needed"
        fi
        """
}

process getRefFiles {
    /**
    * fetches reference file from 
    */

    output:
    path("ref.fasta"), emit: fasta
    path("ref.bed"), emit: bed

    script:
    refURL=params.refURL
    bedURL=params.bedURL
    """
    wget $refURL -O ref.fasta
    wget $bedURL -O ref.bed
    """
}

process uploadToBucket {
    tag {prefix}
    label 'oci_pipe'

    input:
    tuple(val(prefix), path("${prefix}.fasta"), path("${prefix}.bam"),path("${prefix}.vcf"),path("${prefix}.json"))

    script:
    bucketName=params.uploadBucket
    """
    mkdir ${prefix}
    cp ${prefix}.fasta ${prefix}/
    cp ${prefix}.bam ${prefix}/
    cp ${prefix}.vcf ${prefix}/
    cp ${prefix}.json ${prefix}/
    gzip ${prefix}/${prefix}.fasta

    oci os object bulk-upload \
    --overwrite \
    --src-dir ./${prefix}/ \
    -bn $bucketName \
    --auth instance_principal \
    --prefix ${prefix}/ 

    """ 
}

process getObjCsv {
    /**
    * fetches CSV file (sp3data.csv) from object store using OCI bulk download (https://docs.oracle.com/en-us/iaas/tools/oci-cli/2.24.4/oci_cli_docs/cmdref/os/object/bulk-download.html)
    * @input
    * @output
    */

    //tag { prefix }

    label 'oci_pipe'

    input:
        tuple val(bucket), val(path)

    output:
        path("*.csv")

    script:
    """
    echo "kff - Running getObjCsv from mudules|units"
    
    oci os object get \
        -bn $bucket \
        --auth instance_principal \
        --file sp3data.csv \
        --name $path
    """
}
