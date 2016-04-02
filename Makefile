BUCKET=tweets.knut.me
AWS_DEFAULT_REGION=us-east-1
OUTDIR=/tmp/gen_$(BUCKET)/
EXPIRY=86400

export AWS_DEFAULT_REGION

default: publish

unpack: tweets.zip
		unzip tweets.zip
		rm tweets.zip

compress_%: %
		gzip -c $< > $<.gz

aws_prepare: compress_tweets.csv
		python scripts/aws-s3-gzip-compression.py ./ $(OUTDIR)

publish: aws_prepare
		aws s3 sync $(OUTDIR) s3://$(BUCKET)/ \
				--acl public-read --exclude '*' --include '*.js' \
				--no-guess-mime-type \
				--content-encoding gzip \
				--content-type 'application/javascript; charset=utf-8' \
				--cache-control "max-age=$(EXPIRY)"
		aws s3 sync $(OUTDIR) s3://$(BUCKET)/ \
				--acl public-read --exclude '*' --include '*.css' \
				--no-guess-mime-type \
				--content-encoding gzip \
				--content-type "text/css; charset=utf-8" \
				--cache-control "max-age=$(EXPIRY)"
		aws s3 sync $(OUTDIR) s3://$(BUCKET)/ \
				--acl public-read --exclude '*' --include '*.html' \
				--no-guess-mime-type \
				--content-encoding gzip \
				--content-type "text/html; charset=utf-8"
		aws s3 sync $(OUTDIR) s3://$(BUCKET)/ \
				--acl public-read --exclude '*' --include '*.png' --include '*.jpg' --include '*.gif' \
				--cache-control "max-age=$(EXPIRY)"
		aws s3 sync $(OUTDIR) s3://$(BUCKET)/ \
				--exclude 'SHA512SUM' --exclude 'Makefile' \
				--exclude 'README.*' --exclude 'tweets.csv' \
				--exclude 'scripts' \
				--acl public-read

clean:
		rm -rf $(OUTDIR)
