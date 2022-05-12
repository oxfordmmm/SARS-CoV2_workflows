#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl=2

// import subworkflows
include {downstreamAnalysis} from './analysis.nf'

// import modules
include {getObjFilesONT} from '../modules/utils.nf'
include {getRefFiles} from '../modules/utils.nf'
include {checkSizeSubsampleONT} from '../modules/utils.nf'
include {viridianONTPrimers} from '../modules/viridian.nf'
include {viridianONTAuto} from '../modules/viridian.nf'
include {download_primers} from '../modules/analysis.nf'
include {uploadToBucket} from '../modules/utils.nf'


workflow Nanopore_viridian {
    take:
      ch_objFiles
    main:
      // get fastq files from objstore
      println("kff - Nanopore_viridian. Pre getObjFilesONT")
      getObjFilesONT(ch_objFiles)
      println("kff - Nanopore_viridian. Post getObjFilesONT")

      if (params.limitMaxSampleSize) {
        // Subsample if needed
	println("kff - Nanopore_viridian. Pre checkSizeSubsampleONT limited")
        checkSizeSubsampleONT(getObjFilesONT.out.fqs)
	println("kff - Nanopore_viridian. Post checkSizeSubsampleONT limited")

        // Run standard pipeline
	println("kff - Nanopore_viridian. Pre sequenceAnalysisViridian limited")
        sequenceAnalysisViridian(checkSizeSubsampleONT.out.checked_fqs)
	println("kff - Nanopore_viridian. Post sequenceAnalysisViridian limited")
      }
      else {
        // Run standard pipeline
	println("kff - Nanopore_viridian. Pre sequenceAnalysisViridian")
        sequenceAnalysisViridian(getObjFilesONT.out.fqs)
	println("kff - Nanopore_viridian. Post sequenceAnalysisViridian")
      }
      

}

workflow sequenceAnalysisViridian {
    take:
      ch_filePairs

    main:
      getRefFiles()

      if (params.primers != 'auto') {

        download_primers(params.primers)

        viridianONTPrimers(ch_filePairs.combine(download_primers.out).combine(getRefFiles.out.fasta))

        viridian=viridianONTPrimers

      }
      else if (params.primers == 'auto') {

        viridianONTAuto(ch_filePairs.combine(getRefFiles.out.fasta))

        viridian=viridianONTAuto

      }
      
      downstreamAnalysis(viridian.out.consensus, viridian.out.vcfs, getRefFiles.out.fasta, getRefFiles.out.bed)

      if (params.uploadBucket != false) {
        uploadToBucket(viridian.out.consensus.combine(viridian.out.bam, by:0)
                                .combine(viridian.out.vcfs, by:0)
				.combine(downstreamAnalysis.out.json, by:0))
      }
}
