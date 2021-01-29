#! /bin/bash

# create new ci-buildnum image

gcloud config set project digital-ucdavis-edu
gcloud builds submit .