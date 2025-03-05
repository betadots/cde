#!/bin/bash

IP=$(ipconfig getifaddr en0)
echo -n "{\"v4\":\"${IP}\"}"
