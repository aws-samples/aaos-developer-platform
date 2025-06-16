#!/bin/bash
## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0

for dir in base; do
  pushd $dir
  dpkg-buildpackage -uc -us
  popd
done

for dir in frontend; do
  pushd $dir
  dpkg-buildpackage -uc -us
  popd
done
