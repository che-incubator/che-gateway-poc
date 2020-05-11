#!/bin/sh

. "$( dirname "${0}" )/../env.sh"

genConfig
reconfigRouter
kickoffHaproxy
