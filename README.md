# Luzifer / compressed-twitter-archive

This repository contains the required scripts to publish your twitter archive into a S3 bucket with gzip compression for faster loading.

## Usage

1. Request your archive at your [Twitter settings page](https://twitter.com/settings/account)
1. Adjust your bucket in the `Makefile`
1. Copy the archive into this directory
1. Unpack the archive
1. Publish it

```
$ cp ~/Downloads/tweets.zip .
$ make unpack
$ make publish
```
