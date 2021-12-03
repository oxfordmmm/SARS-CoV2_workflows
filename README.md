# SARS-CoV2_workflows


## Illumina Viridian workflow
These are the commands used for running the workflow on a GPAS stack in OCI. Data should be stored in an object store and described in the csv file. This is passed to `--objstore`.
```bash
nextflow run /data/pipelines/SARS-CoV2_workflows/main.nf \
	-with-trace \
	-with-report \
	-with-timeline \
	-with-dag dag.png \
	--seq_tech illumina \
	-profile singularity \
	-process.executor slurm \
	--objstore /tmp/illumina_data.csv \
	--run_uuid 387691ae-1f78-444d-a317-23443472b188 \
	--head_node_ip 10.0.1.2 \
	--TESToutputMODE true \
	--outdir /work/output/illumina_viridian_test
```
