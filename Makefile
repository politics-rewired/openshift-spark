LOCAL_IMAGE ?= openshift-spark
SPARK_IMAGE=gcr.io/assemble-services/openshift-spark
DOCKERFILE_CONTEXT=openshift-spark-build
BUILDER ?= podman

# If you're pushing to an integrated registry
# in Openshift, SPARK_IMAGE will look something like this

# SPARK_IMAGE=172.30.242.71:5000/myproject/openshift-spark

OPENSHIFT_SPARK_TEST_IMAGE ?= spark-testimage
export OPENSHIFT_SPARK_TEST_IMAGE

.PHONY: build clean push create destroy test-e2e clean-target clean-context zero-tarballs

build: $(DOCKERFILE_CONTEXT)
	$(BUILDER) build -t $(LOCAL_IMAGE) $(DOCKERFILE_CONTEXT)

build-py37: $(DOCKERFILE_CONTEXT)-py37
	$(BUILDER) build -t $(LOCAL_IMAGE)-py37 $(DOCKERFILE_CONTEXT)-py37

clean: clean-context
	-$(BUILDER) rmi $(LOCAL_IMAGE)
	-$(BUILDER) rmi $(LOCAL_IMAGE)-py37

push: build
	$(BUILDER) tag $(LOCAL_IMAGE) $(SPARK_IMAGE)
	$(BUILDER) push $(SPARK_IMAGE)
	$(BUILDER) tag $(LOCAL_IMAGE)-py37 $(SPARK_IMAGE)-py37
	$(BUILDER) push $(SPARK_IMAGE)-py37

create: push template.yaml
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > template.active
	oc create -f template.active
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE)-py37 > template-py37.active
	oc create -f template-py37.active

destroy: template.active
	oc delete -f template.active
	rm template.active
	oc delete -f template-py37.active
	rm template-py37.active

clean-context:
	-rm -rf $(DOCKERFILE_CONTEXT)/*
	-rm -rf $(DOCKERFILE_CONTEXT)-py37/*

clean-target:
	-rm -rf target
	-rm -rf target-py37

context: $(DOCKERFILE_CONTEXT) $(DOCKERFILE_CONTEXT)-py37

$(DOCKERFILE_CONTEXT): $(DOCKERFILE_CONTEXT)/Dockerfile \
	                   $(DOCKERFILE_CONTEXT)/modules

$(DOCKERFILE_CONTEXT)-py37: $(DOCKERFILE_CONTEXT)-py37/Dockerfile \
	                   $(DOCKERFILE_CONTEXT)-py37/modules

$(DOCKERFILE_CONTEXT)/Dockerfile $(DOCKERFILE_CONTEXT)/modules:
	cekit --descriptor image.yaml build --dry-run $(BUILDER)
	cp -R target/image/* $(DOCKERFILE_CONTEXT)

$(DOCKERFILE_CONTEXT)-py37/Dockerfile $(DOCKERFILE_CONTEXT)-py37/modules:
	cekit --descriptor image.yaml --overrides overrides/python37.yaml build --dry-run $(BUILDER)
	cp -R target-py37/image/* $(DOCKERFILE_CONTEXT)-py37

zero-tarballs:
	find ./$(DOCKERFILE_CONTEXT) -name "*.tgz" -type f -exec truncate -s 0 {} \;
	find ./$(DOCKERFILE_CONTEXT) -name "*.tar.gz" -type f -exec truncate -s 0 {} \;

test-e2e:
	LOCAL_IMAGE=$(OPENSHIFT_SPARK_TEST_IMAGE) make build
	test/run.sh completed/
