## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0

ARG AWS_ACCOUNT_ID
ARG AWS_REGION
ARG AWS_REPO
FROM $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPO:latest


ARG TARGET_BRANCH
ARG BUCKET_NAME




WORKDIR /home/ubuntu

RUN mkdir stage
WORKDIR stage

RUN aws s3 cp s3://$BUCKET_NAME/$TARGET_BRANCH/aosp_cf_arm64_auto-img-eng.root.zip .

RUN aws s3 cp s3://$BUCKET_NAME/$TARGET_BRANCH/cvd-host_package.tar.gz .

RUN tar -xvf cvd-host_package.tar.gz
RUN unzip aosp_cf_arm64_auto-img-eng.root.zip
RUN rm aosp_cf_arm64_auto-img-eng.root.zip

RUN aws s3 cp s3://$BUCKET_NAME/$TARGET_BRANCH/u-boot.bin ./bootloader

RUN cp /usr/bin/mkenvimage ./bin/mkenvimage
RUN chown -R ubuntu:ubuntu /home/ubuntu/stage

