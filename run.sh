#!/bin/bash
# Example use:
# 30 */1 * 5-6 * cd ~/dvk-volitve-ep2024/ && ./run.sh >> run.log
# 5/10 * 9-10 6 * cd ~/dvk-volitve-ep2024/ && ./run.sh >> run.log
echo "--------------------------"
date
git checkout .
git pull
./update.sh
export GIT_COMMITTER_NAME="github-actions[bot]"
export GIT_COMMITTER_EMAIL="41898282+github-actions[bot]@users.noreply.github.com"
export GIT_AUTHOR_NAME="github-actions[bot]"
export GIT_AUTHOR_EMAIL="41898282+github-actions[bot]@users.noreply.github.com"
git pull
git commit ./volitve/ -m "DVK Volitve EP2024 update 🤖"
git push
