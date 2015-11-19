BUCKET=tweets.knut.me
OUTDIR=/tmp/gen_$(BUCKET)/
EXPIRY=86400

default: publish

unpack: tweets.zip
		unzip tweets.zip
		rm tweets.zip

compress_%: %
		gzip -c $< > $<.gz

aws_prepare: compress_tweets.csv
		python scripts/aws-s3-gzip-compression.py ./ $(OUTDIR)

publish: aws_prepare
		s3cmd sync $(OUTDIR) s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.js' \
				--no-guess-mime-type \
				--add-header='Content-Encoding:gzip' \
				--mime-type="application/javascript; charset=utf-8" \
				--add-header="Cache-Control: max-age=$(EXPIRY)" && \
		s3cmd sync $(OUTDIR) s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.css' \
				--no-guess-mime-type \
				--add-header='Content-Encoding:gzip' \
				--mime-type="text/css; charset=utf-8" \
				--add-header="Cache-Control: max-age=$(EXPIRY)" && \
		s3cmd sync $(OUTDIR) s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.html' \
				--no-guess-mime-type \
				--add-header='Content-Encoding:gzip' \
				--mime-type="text/html; charset=utf-8" && \
		s3cmd sync $(OUTDIR) s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.png' --include '*.jpg' --include '*.gif' \
				--add-header="Cache-Control: max-age=$(EXPIRY)" && \
		s3cmd sync $(OUTDIR) s3://$(BUCKET)/ \
				--exclude 'SHA512SUM' --exclude 'Makefile' \
				--exclude 'README.*' --exclude 'tweets.csv' \
				--exclude 'scripts' \
				-P --delete-removed

clean:
		rm -rf $(OUTDIR)
