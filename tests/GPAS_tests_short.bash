#!/bin/bash
set -xe
sudo mkdir -p /work/tmp
sudo chown ubuntu:ubuntu /work/tmp

echo \
"SARS-CoV-2_reference_ox,mmm-artic-ill-s11511-1
SARS-CoV-2_reference_ox,mmm-artic-ill-s12220-1
SARS-CoV-2_reference_ox,mmm-artic-ill-s12368-1
SARS-CoV-2_reference_ox,mmm-artic-ill-s16621-1" \
    > /work/tmp/illumina_data_short.csv

echo \
"SARS-CoV-2_reference_ox,mmm-artic-ont-s11511-1
SARS-CoV-2_reference_ox,mmm-artic-ont-s12220-4
SARS-CoV-2_reference_ox,mmm-artic-ont-s12368-1
SARS-CoV-2_reference_ox,mmm-artic-ont-s16621-3" \
    > /work/tmp/ONT_data_short.csv

repo='SARS-CoV2_workflows'
comp_venv='/home/ubuntu/env'

pushd /data/pipelines/${repo}
git_version=$(git describe --tags)
popd

# ont_viridian_test
test_name=gpas_ont_short
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

nextflow pull oxfordmmm/${repo} -r ${git_version}

nextflow kuberun \
        oxfordmmm/${repo} \
        -r ${git_version} -latest \
        --seq_tech nanopore \
        -profile oke \
        --objstore /work/tmp/ONT_data_short.csv \
        --TESToutputMODE true \
        --run_uuid ${test_name}_test \
        --outdir /work/output/${test_name}_test \
        --uploadBucket test-output \
        > ${test_name}_nextflow.txt

if ! [ -z ${comp_venv} ]
then
    source $comp_venv/bin/activate
fi

sudo chown ubuntu:ubuntu /work/output/${test_name}_test

python3 /data/pipelines/${repo}/tests/GPAS_tests_summary.py \
    -w /work/runs/${test_name}_test \
    -i /work/output/${test_name}_test/ \
    -t /work/output/${test_name}_test/${test_name}_summary.tsv  \
    -e /data/pipelines/${repo}/tests/${test_name}_expected.tsv \
    -c /work/output/${test_name}_test/${test_name}_comparison.tsv

test_name=gpas_illumina_short
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

nextflow kuberun oxfordmmm/${repo} \
        -r ${git_version} -latest \
        --seq_tech illumina \
        -profile oke \
        --objstore /work/tmp/illumina_data_short.csv \
        --TESToutputMODE true \
        --run_uuid ${test_name}_test \
        --outdir /work/output/${test_name}_test \
        --uploadBucket test-output \
        > ${test_name}_nextflow.txt

sudo chown ubuntu:ubuntu /work/output/${test_name}_test

python3 /data/pipelines/${repo}/tests/GPAS_tests_summary.py \
    -w /work/runs/${test_name}_test \
    -i /work/output/${test_name}_test/ \
    -t /work/output/${test_name}_test/${test_name}_summary.tsv  \
    -e /data/pipelines/${repo}/tests/${test_name}_expected.tsv \
    -c /work/output/${test_name}_test/${test_name}_comparison.tsv

