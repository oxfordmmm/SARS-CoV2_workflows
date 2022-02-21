#!/bin/bash


echo \
"SARS-CoV-2_reference_ox,mmm-artic-ill-s11511-1
SARS-CoV-2_reference_ox,mmm-artic-ill-s12220-1
SARS-CoV-2_reference_ox,mmm-artic-ill-s12368-1
SARS-CoV-2_reference_ox,mmm-artic-ill-s16621-1" \
    > /tmp/illumina_data_short.csv

echo \
"SARS-CoV-2_reference_ox,mmm-artic-ont-s11511-1
SARS-CoV-2_reference_ox,mmm-artic-ont-s12220-4
SARS-CoV-2_reference_ox,mmm-artic-ont-s12368-1
SARS-CoV-2_reference_ox,mmm-artic-ont-s16621-3" \
    > /tmp/ONT_data_short.csv

repo='/data/pipelines/SARS-CoV2_workflows'
comp_venv='/home/ubuntu/env'
# ont_viridian_test
test_name=gpas_ont_short
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

nextflow run \
        ${repo}/main.nf \
        -with-trace -with-report -with-timeline -with-dag dag.png \
        --seq_tech nanopore \
        -profile singularity \
        -process.executor slurm \
        --objstore /tmp/ONT_data_short.csv \
        --TESToutputMODE true \
        --outdir /work/output/${test_name}_test \
        > nextflow.txt

if ! [ -z ${comp_venv} ]
then
    source $comp_venv/bin/activate
fi

python3 ${repo}/tests/GPAS_tests_summary.py \
    -w /work/runs/${test_name}_test \
    -i /work/output/${test_name}_test/ \
    -t /work/output/${test_name}_test/${test_name}_summary.tsv  \
    -e ${repo}/tests/${test_name}_expected.tsv \
    -c /work/output/${test_name}_test/${test_name}_comparison.tsv

test_name=gpas_illumina_short
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

nextflow run ${repo}/main.nf \
        -with-trace -with-report -with-timeline -with-dag dag.png \
        --seq_tech illumina \
        -profile singularity \
        -process.executor slurm \
        --objstore /tmp/illumina_data_short.csv \
        --TESToutputMODE true \
        --outdir /work/output/${test_name}_test \
        > nextflow.txt

python3 ${repo}/tests/GPAS_tests_summary.py \
    -w /work/runs/${test_name}_test \
    -i /work/output/${test_name}_test/ \
    -t /work/output/${test_name}_test/${test_name}_summary.tsv  \
    -e ${repo}/tests/${test_name}_expected.tsv \
    -c /work/output/${test_name}_test/${test_name}_comparison.tsv

