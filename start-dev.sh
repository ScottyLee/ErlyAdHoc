#!/bin/sh
# NOTE: mustache templates need \ because they are not awesome.
exec erl -pa ebin edit deps/*/ebin -boot start_sasl \
    -sname erly_ad_hoc_dev \
    -s erly_ad_hoc \
    -s reloader
