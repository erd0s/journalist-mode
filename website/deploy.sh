#!/bin/bash
aws s3 cp --recursive ./public/ s3://journalistmode.com/ --acl public-read
aws cloudfront create-invalidation --distribution-id ${DISTRO_ID}  --paths "/*"