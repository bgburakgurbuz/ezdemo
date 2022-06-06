#!/usr/bin/env bash
# =============================================================================
# Copyright 2022 Hewlett Packard Enterprise
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# =============================================================================

set -euo pipefail

echo "[all:vars]" > vars.ini
cat my.tfvars | tr -d "[:blank:]" >> vars.ini
grep -v "^\[" dc.ini >> vars.ini

ansible -i vars.ini localhost -m template -a "src=hosts-common.ini dest=hosts.ini"

sed -i.bak '/^mapr_count = /d' my.tfvars
echo "mapr_count = $(ansible-inventory -i hosts.ini --list | jq 'try (.mapr[] | length) catch 0')" >> my.tfvars
rm my.tfvars.bak

exit 0
