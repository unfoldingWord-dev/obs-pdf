# Created: 2019-05-27 RJH

# NOTE: The following environment variables are expected to be set for testing:
#	AWS_ACCESS_KEY_ID
#	AWS_SECRET_ACCESS_KEY
checkEnvVariables:
	@ if [ -z "${AWS_ACCESS_KEY_ID}" ]; then \
		echo "Need to set AWS_ACCESS_KEY_ID"; \
		exit 1; \
	fi
	@ if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then \
		echo "Need to set AWS_SECRET_ACCESS_KEY"; \
		exit 1; \
	fi
	@ if [ -z "${REDIS_URL}" ]; then \
		echo "Need to set REDIS_URL"; \
		exit 1; \
	fi

baseImage:
	docker build --tag unfoldingword/obs-base:latest resources/docker-obs-base/

pushBaseImage:
	docker push unfoldingword/obs-base:latest

mainImageDebug:
	# Builds from local files
	docker build --file resources/docker-app/Dockerfile-debug --tag unfoldingword/obs-pdf:debug .

mainImageDev:
	# Builds from GitHub develop branch
	docker build --file resources/docker-app/Dockerfile-developBranch --tag unfoldingword/obs-pdf:develop resources/docker-app/

mainImage:
	# Builds from GitHub master branch
	docker build --file resources/docker-app/Dockerfile-masterBranch --tag unfoldingword/obs-pdf:master resources/docker-app/

pushMainDevImage:
	docker push unfoldingword/obs-pdf:develop

pushMainImage:
	docker push unfoldingword/obs-pdf:master

run: checkEnvVariables
	docker run --env AWS_ACCESS_KEY_ID --env AWS_SECRET_ACCESS_KEY --env REDIS_URL --name obs-pdf --publish 8123:80 --detach --interactive --tty --cpus=1.0 --restart unless-stopped unfoldingword/obs-pdf:master

runDev: checkEnvVariables
	docker run --env AWS_ACCESS_KEY_ID --env AWS_SECRET_ACCESS_KEY --env REDIS_URL --env QUEUE_PREFIX="dev-" --name obs-pdf --rm --publish 8123:80 --detach --interactive --tty --cpus=1.0 --restart unless-stopped unfoldingword/obs-pdf:develop
	# Then browse to http://localhost:8123/test
	#	or http://localhost:8123/?lang_code=en
	#	then http://localhost:8123/output/en/obs-en-v5.pdf

runDevDebug: checkEnvVariables
	# After this, inside the container, run these commands to start the application:
	#	cd /
	#	./start_WebApp.sh
	# or
	#	./start_RqApp.sh
	#
	# conTeXt logs will be in /app/obs-pdf/output/ (context.err and context.out)
	docker run --env AWS_ACCESS_KEY_ID --env AWS_SECRET_ACCESS_KEY --env REDIS_URL --env QUEUE_PREFIX="dev-" --env DEBUG_MODE=On --name obs-pdf --rm --publish 8123:80 --interactive --tty --cpus=0.5 unfoldingword/obs-pdf:develop bash

runDebug: checkEnvVariables
	# After this, inside the container, run these commands to start the application:
	#	cd /
	#	./start_WebApp.sh
	# or
	#	./start_RqApp.sh
	#
	# conTeXt logs will be in /app/obs-pdf/output/ (context.err and context.out)
	# Also look in /tmp/obs-to-pdf/en-xxxx/make_pdf/en.log and en.tex
	docker run --env AWS_ACCESS_KEY_ID --env AWS_SECRET_ACCESS_KEY --env REDIS_URL --env QUEUE_PREFIX="dev-" --env DEBUG_MODE=On --name obs-pdf --rm --publish 8123:80 --interactive --tty unfoldingword/obs-pdf:debug bash

connectDebug:
	# This will open another terminal view of the obs-pdf container (one of the two above)
	#	that doesn't have all of the nginx logs scrolling past
	#
	# tail -f /tmp/last_output_msgs.txt
	#	is convenient to watch (once that file exists)
	# conTeXt logs will be in /app/obs-pdf/output/ (context.out and maybe context.err)
	# Also look in /tmp/obs-to-pdf/en-xxxx/make_pdf/en.log and en.tex
	docker exec -it `docker inspect --format="{{.Id}}" obs-pdf` bash
