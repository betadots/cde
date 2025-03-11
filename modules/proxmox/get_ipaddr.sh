#!/bin/bash

IP=$(ipconfig getifaddr en0)
echo "{\"v4\":\"${IP}\"}"
