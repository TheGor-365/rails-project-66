#!/usr/bin/env bash
set +e

TMP_DIR=".tmp/hexlet_ci_layout"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR/code"

rsync -a \
  --exclude '.git' \
  --exclude '.tmp' \
  --exclude 'node_modules' \
  ./ "$TMP_DIR/code/"

cp .rubocop.hexlet.yml "$TMP_DIR/.rubocop.yml"

cd "$TMP_DIR" || exit 1
export BUNDLE_GEMFILE="$PWD/code/Gemfile"

bundle exec rubocop code --config ./.rubocop.yml --cache false
rc=$?
echo "rubocop_rc=$rc"
exit $rc
