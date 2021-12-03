process getObjFiles {
    /**
    * fetches fastq files from object store using OCI bulk download (https://docs.oracle.com/en-us/iaas/tools/oci-cli/2.24.4/oci_cli_docs/cmdref/os/object/bulk-download.html)
    * @input
    * @output
    */

    tag { prefix }

    input:
        tuple val(bucket), val(filePrefix), val(prefix)

    output:
        tuple val(prefix), path("${prefix}*1.fastq.gz"), path("${prefix}*2.fastq.gz"), emit: fqs

    script:
        """
	oci os object bulk-download \
		-bn $bucket \
		--download-dir ./ \
		--overwrite \
		--auth instance_principal \
		--prefix $filePrefix 
	"""
}

process getObjFilesONT {
    /**
    * fetches fastq files from object store using OCI bulk download (https://docs.oracle.com/en-us/iaas/tools/oci-cli/2.24.4/oci_cli_docs/cmdref/os/object/bulk-download.html)
    * @input
    * @output
    */

    tag { prefix }

    input:
        tuple val(bucket), val(filePrefix), val(prefix)

    output:
        tuple val(prefix), path("*.fastq.gz"), emit: fqs

    script:
        """
	oci os object bulk-download \
		-bn $bucket \
		--download-dir ./ \
		--overwrite \
		--auth instance_principal \
		--prefix $filePrefix 
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
