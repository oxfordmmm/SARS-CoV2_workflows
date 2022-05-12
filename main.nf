#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl=2

// import subworkflows
include {Illumina_viridian} from './workflows/illumina.nf'
include {Nanopore_viridian} from './workflows/nanopore.nf'
include {getObjCsv} from './modules/utils.nf'
include {getCsvBucketPath} from './modules/java/util.nf'



// main workflow
workflow {

    // Channels
    if (params.objstore) {
        if ( java.nio.file.Paths.get(params.objstore).exists() ) {
            Channel.fromPath( "${params.objstore}" )
                .splitCsv()
                .map { row -> tuple(row[0], row[1], row[1]) }
                .set{ ch_objFiles }
        } else {
            ch_objCSV = getCsvBucketPath("${params.objstore}")

            getObjCsv( tuple( ch_objCSV[0], ch_objCSV[1] ))
                .splitCsv()
                .map { row -> tuple(row[0], row[1], row[1]) }
                .set{ ch_objFiles }
        }
    }
    else if (params.catsup && params.catsup != false) {
        if ( java.nio.file.Paths.get("${params.catsup}/sp3data.csv").exists() ) {
            Channel.fromPath( "${params.catsup}/sp3data.csv" )
                .splitCsv(header: true)
                .map { row -> tuple("${params.bucket}", "${row.submission_uuid4}/${row.sample_uuid4}", "${row.sample_uuid4}") }
                .unique()
                .set{ ch_objFiles }
        } else {
            ch_objCSV = getCsvBucketPath("${params.catsup}/sp3data.csv")

            getObjCsv( tuple( ch_objCSV[0], ch_objCSV[1] ))
                .splitCsv(header: true)
                .map { row -> tuple("${params.bucket}", "${row.submission_uuid4}/${row.sample_uuid4}", "${row.sample_uuid4}") }
                .unique()
                .set{ ch_objFiles }
        }
    }
    else if (params.ena_csv && params.ena_csv != false) {
        if ( java.nio.file.Paths.get(params.ena_csv).exists() ) {
            Channel.fromPath( "${params.ena_csv}" )
                .splitCsv(header: true)
                .map { row -> tuple("${row.bucket}", "${row.sample_prefix}", "${row.sample_accession}") }
                .unique()
                .set{ ch_objFiles }
        } else {
            ch_objCSV = getCsvBucketPath(params.ena_csv)

            getObjCsv( tuple( ch_objCSV[0], ch_objCSV[1] ))
                .splitCsv(header: true)
                .map { row -> tuple("${row.bucket}", "${row.sample_prefix}", "${row.sample_accession}") }
                .unique()
                .set{ ch_objFiles }
        }
    }

    main:
        if (params.seq_tech == 'illumina') {
		    Illumina_viridian(ch_objFiles)
        }
        else if (params.seq_tech == 'nanopore') {
		    println("Running Nanopore")
		    Nanopore_viridian(ch_objFiles)
        } else {
            println("Please select a workflow with --seq_tech illumina or nanopore")
        }
}
