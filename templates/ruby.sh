#!/bin/bash

set -o errexit
set -o pipefail
set -x

sudo -i -u "${username}" /bin/bash -l rvm install --binary "${ruby_version}"
