#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl=2

// import subworkflows
include {Illumina_viridian} from './workflows/illumina.nf'
include {Nanopore_viridian} from './workflows/nanopore.nf'

// Channels
if (params.objstore) {
    Channel.fromPath( "${params.objstore}" )
           .splitCsv()
           .map { row -> tuple(row[0], row[1], row[1]) }
           .set{ ch_objFiles }
}
else if (params.catsup && params.catsup != false) {
    Channel.fromPath( "${params.catsup}/sp3data.csv" )
           .splitCsv(header: true)
           .map { row -> tuple("${params.bucket}", "${row.submission_uuid4}/${row.sample_uuid4}", "${row.sample_uuid4}") }
           .view()
           .unique()
           .set{ ch_objFiles }
}
else if (params.ena_csv && params.ena_csv != false) {
    Channel.fromPath( "${params.ena_csv}" )
           .splitCsv(header: true)
           .map { row -> tuple("${row.bucket}", "${row.sample_prefix}", "${row.sample_accession}") }
           .view()
           .unique()
           .set{ ch_objFiles }
}



// main workflow
workflow {
    main:
        if (params.seq_tech == 'illumina') {
		Illumina_viridian(ch_objFiles)
        }
        else if (params.seq_tech == 'nanopore') {
		Nanopore_viridian(ch_objFiles)
        } else {
       println("Please select a workflow with --seq_tech illumina or nanopore")
       }
}
