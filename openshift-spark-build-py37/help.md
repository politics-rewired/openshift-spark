# radanalyticsio/openshift-spark

## Description

## Environment variables

### Informational

These environment variables are defined in the image.

**JBOSS_IMAGE_NAME**

> "radanalyticsio/openshift-spark"

**JBOSS_IMAGE_VERSION**

> "2.4-latest"

**PATH**

> "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin"

**SCL_ENABLE_CMD**

> "scl enable rh-python37"

**SPARK_HOME**

> "/opt/spark"

**SPARK_INSTALL**

> "/opt/spark-distro"

**STI_SCRIPTS_PATH**

> "/usr/libexec/s2i"

### Configuration

The image can be configured by defining these environment variables
when starting a container:

## Labels

**io.cekit.version**

> 2.2.7

**io.openshift.s2i.scripts-url**

> image:///usr/libexec/s2i

**maintainer**

> Chad Roberts <croberts@redhat.com>

**name**

> radanalyticsio/openshift-spark

**org.concrt.version**

> 2.2.7

**sparkversion**

> 2.4.5

**version**

> 2.4-latest
