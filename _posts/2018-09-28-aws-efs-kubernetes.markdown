---
layout: post
title: "Kubernetes persistent volumes on top of AWS EFS"
categories: [kubernetes, aws, efs]
---

When deploying an application in an environment based on a containers solution, one of the usual
challenges to tackle is how/where to store application state, if your application happens to
require it, which is usually the case.

Today I was tackling one of the recurrent issues when building a web application: an user should
be able to upload a file (an image in this case) and visualize it later.

Files inside a container are ephemeral, there's no guarantee how long a container will be alive,
and therefore local state is not an option (it's usually not an option if you can to scale
horizontally).

In this scenario, the state is represented by a binary file. While there're multiples solutions
for this scenario, using a shared disk that can be mounted by a set of nodes is what I'm more used to.

But working with kubernetes, "mounting a shared disk in a set of nodes" is not that straight forward.

In this post I'll go through the relevant kubernetes resources for tackling this problem, and specifically
how to implement it on top of [AWS](https://aws.amazon.com/).

## The basic. A kubernetes Volume

A [**Volume**](https://kubernetes.io/docs/concepts/storage/volumes/) is a kubernetes storage resource **attached
to a Pod**, and it lives as long as the Pod it's attached to does.

Those are the usual scenarios where I've been using a Volume so far:

- mount [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) data
using a [configMap](https://kubernetes.io/docs/concepts/storage/volumes/#configmap) Volume type. This is handy
for creating a configuration file in the container.
- share state between containers that are part of the same Pod using an
[emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) Volume type.
- mount an external block storage (like [Amazon EBS](https://aws.amazon.com/ebs/)
or [Google Persistent Disk](https://cloud.google.com/compute/docs/disks/)) using
[awsElasticBlockStore](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore)
or [gcePersistentDisk](https://kubernetes.io/docs/concepts/storage/volumes/#gcepersistentdisk) respectively. This
is useful if you need to store data that which availability is limited to one container at a time (no need to share
state between pods). Note that the external resources must be created via the cloud provider Web console or
command line tool before you can use them in kubernetes.

While the Volume is indeed convenient for the scenarios described above, there's a big limitation:
it can be mounted only in one Pod. Therefore, a Volume is not a good solution for my scenario, where I
need binary files to be available in several Pods (to scale horizontally the solution).

## The advanced. A kubernetes Persistent Volume

A [**Persistent Volume**](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) is a cluster
resource on its own, it's not attached to any node/pod, and has its own lifecycle. It represents
a storage resource available to Pods created in the cluster.

Similar to how [memory and CPU resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
can be configured in a Pod specification, a Pod's storage (Persistent Volume) requirements can be defined by
means of a [**PersistentVolumeClaim**](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
resource. There're two attributes that can be configured: size and access mode (read, write).

Mind the difference between these two concepts: a *Persistent Volume* is a cluster resource (like nodes, memory, CPU),
while and a *Persistent Volume Claim* is a set of requirements about the storage a Pod needs.

Last but not least concept is the [**StorageClass**](https://kubernetes.io/docs/concepts/storage/storage-classes/),
which is used to describe a storage resource (similar to include metadata or define several profiles).
A pod storage requirements can be configured either by defining size and access mode via *PVC*, or by defining the
needs in more abstract terms, using a *StorageClass*.

While a Volume of type external block storage must be created before it can be used, a Persistent Volume can be
[provisioned dynamically](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#provisioning) by means
of a StorageClass definition (using the parameter *provisioner*).

## Configure a Pod to Use EFS for Storage

Back to my original problem, how can I configure a shared disk for sharing state (binary files) between Pods?

Running a kubernetes cluster in AWS, it seems like [EFS](https://aws.amazon.com/efs/) is the natural choice.

Those are the steps I went through:

#### 1. Create an EFS resource using aws cli
(https://banzaicloud.com/blog/aws_provision_efs/)
> aws efs create-file-system --creation-token $(uuid)

Mount targets and security groups such that any node (in any zone in the cluster's region) can mount
the EFS file system by its File system DNS name:

- create the mount targets

> aws efs create-mount-target \
    --file-system-id {FileSystemId} \
    --subnet-id {SubnetId} \
    --security-groups {SecurityGroupId}

- create an inbound rule for NFS on the security group
> aws ec2 authorize-security-group-ingress --protocol tcp --port 2049 \
    --group-id {SecurityGroupId} \
    --source-group {SecurityGroupId} \
    --group-owner {OwnerId}

#### 2. Deploy the EFS provisioner

Kubernetes provides several
[Persistent Volume types](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes):
AWSElasticBlockStore, GCEPersistentDisk, AzuleFile and NFS for naming a few, together with their provisioner,
that are shipped alongside Kubernetes. Each of them is a
[specific plugin](https://github.com/kubernetes/kubernetes/tree/a8e8e891f29e83362636dfdbed3e8cf768ba1862/pkg/volume)
included in a default Kubernetes deployment.
However, the kubernetes incubator [**external-storage**](https://github.com/kubernetes-incubator/external-storage)
repository holds additional Persistent Volumes that are not part of a Kubernetes default deployment, and here I found the
answer to my need :dancer: : the [**EFS provisioner**](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs).

The EFS provisioner is a deployment that runs a container with access to the AWS EFS resource. It acts as an EFS broker,
allowing other pods to mount the EFS resource as a PV.

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: efs-provisioner
data:
  file.system.id: '<<your-ecs-id>>'
  aws.region: '<<your-region-id>>'
  provisioner.name: example.com/aws-efs

---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: efs-provisioner
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: efs-provisioner
    spec:
      containers:
        - name: efs-provisioner
          image: quay.io/external_storage/efs-provisioner:latest
          env:
            - name: FILE_SYSTEM_ID
              valueFrom:
                configMapKeyRef:
                  name: efs-provisioner
                  key: file.system.id
            - name: AWS_REGION
              valueFrom:
                configMapKeyRef:
                  name: efs-provisioner
                  key: aws.region
            - name: PROVISIONER_NAME
              valueFrom:
                configMapKeyRef:
                  name: efs-provisioner
                  key: provisioner.name
          volumeMounts:
            - name: pv-volume
              mountPath: /persistentvolumes
      volumes:
        - name: pv-volume
          nfs:
            server: <<your-ecs-id>>.efs.<<your-region-id>>.amazonaws.com
            path: /
```

> kubectl apply -f efs-provisioner.yaml

#### 3. Define the StorageClass
StorageClass is used as an intermediate step for connecting a PersistentVolumeClaim with a specific storage resource.
* as usual, *metadata.name* field will be used to refer to the resource.
* *provisioner* is used to indentify the provisioner (EFS provisioner in this case).

**Important**: An StorageClass definition cannot be updated.

```yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: aws-efs
provisioner: example.com/aws-efs
```

> kubectl apply -f storage-class.yaml

#### 4. Define the PersistentVolumeClaim

The **PVC** definition connects access mode and size requirements with a specific StorageClass item.
In this case, as EFS has unlimited storage, the size requested won't have any affectation.

```yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: efs
spec:
  storageClassName: aws-efs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

#### 5. Create a Deployment with 2 replicas and claim the Volume
Pods access storage by using the claim as a volume. Claims must exist in the same namespace as the pod using the claim.
The cluster finds the claim in the pod's namespace and uses it to get the PersistentVolume backing the claim.
The volume is then mounted to the host and into the pod.
