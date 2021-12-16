#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl=2

// import subworflows
include {downstreamAnalysis} from './analysis.nf'

// import modules
include {getObjFilesONT} from '../modules/utils.nf'
include {getRefFiles} from '../modules/utils.nf'
include {viridianONTPrimers} from '../modules/viridian.nf'
include {viridianONTAuto} from '../modules/viridian.nf'
include {download_primers} from '../modules/analysis.nf'
include {uploadToBucket} from '../modules/utils.nf'


workflow Nanopore_viridian {
    take:
      ch_objFiles
    main:
      // get fastq files from objstore
      getObjFilesONT(ch_objFiles)

      // Run standard pipeline
      sequenceAnalysisViridian(getObjFilesONT.out.fqs)

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
