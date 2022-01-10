#!/usr/bin/env bash

set -euo pipefail

if ! echo "aws azure kvm vmware" | grep -w -q ${1}; then
   echo Usage: "${0} aws|azure|kvm|vmware"
   exit 1
fi

source ./system_settings.sh
### These settings coming from system, not the user

pushd "${1}" > /dev/null
   TF_IN_AUTOMATION=1 terraform apply \
      -no-color \
      -parallelism 10 \
      -auto-approve=true \
      -var-file=<(cat ./*.tfvars) \
      -var="is_runtime=${IS_RUNTIME}"
   # Save output
   TF_IN_AUTOMATION=1 terraform output -json > ../generated/output.json
popd > /dev/null

echo "Wait for nodes to be ready..."
sleep 120

echo "Stage 2 complete"

exit 0
