---
layout: post
title: "Kubernetes persistent volumes on top of AWS EFS"
categories: [kubernetes, aws, efs]
---

When deploying an application in a containers based environment, one of the usual
challenges to tackle is how/where to store application state if your application happens to
require it, which is usually the case.

Today I was tackling one of the recurrent issues while building a web application: an user should
be able to upload a file (an image in this case) and retrieve it later. This obviously means
storing the file in the server side.

Files inside a container are ephemeral, there's no guarantee how long a container will be alive,
and therefore local state inside the container is not an option (it's usually not an option if
you want to scale horizontally).

In this scenario, the state is represented by a binary file. While there're multiples solutions
for this use case, using a shared disk that can be mounted by a set of nodes is what I'm more used to.

But working with kubernetes, _"mounting a shared disk in a set of nodes"_ is not that straight forward.

In this post I'll go through the relevant kubernetes resources for tackling this problem, and specifically
how to implement it on top of [AWS](https://aws.amazon.com/) using an [EFS](https://aws.amazon.com/efs/)
storage resource.

## The basic. A kubernetes Volume

A [**Volume**](https://kubernetes.io/docs/concepts/storage/volumes/) is a kubernetes storage resource **attached
to a Pod**, and it lives as long as the Pod it's attached to does.

Those are the usual scenarios where I've been using a Volume so far:

- mount [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) data
using a [configMap](https://kubernetes.io/docs/concepts/storage/volumes/#configmap) Volume type. This is handy
for creating files in the container with the ConfigMap information.
- share state between containers that are part of the same Pod using an
[emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) Volume type.
- mount an external block storage, like [Amazon EBS](https://aws.amazon.com/ebs/)
or [Google Persistent Disk](https://cloud.google.com/compute/docs/disks/), using
[awsElasticBlockStore](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore)
and [gcePersistentDisk](https://kubernetes.io/docs/concepts/storage/volumes/#gcepersistentdisk) respectively. This
is useful if you need to store data which availability is limited to one container at a time (no need to share
state between pods), so data will nb. Note that the external resources must be created before you can use them in kubernetes via the
cloud provider Web console or command line tool.

While the Volume is indeed convenient for the scenarios described above, there's a big limitation:
it can be mounted only in one Pod. Therefore, a Volume is not a good solution for my scenario, where I
need binary files to be available in several Pods (to scale horizontally the solution).

## The advanced. A kubernetes Persistent Volume

A [**Persistent Volume**](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) is a cluster
resource on its own and has its own lifecycle. It represents a storage resource available to any Pod created in the cluster.
Not being attached to a specific node/pod is one of the main differences with a **Volume**.

Similar to how [memory and CPU resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
can be configured in a Pod specification, a Pod storage requirements (Persistent Volume) can be defined using a [**PersistentVolumeClaim**](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
definition. There're two attributes that can be configured: *size* and *access mode* (read, write).

Mind the difference between these two concepts: a *Persistent Volume* is a cluster resource (like nodes, memory, CPU),
while and a *Persistent Volume Claim* is a set of requirements about the storage a Pod needs.

Last but not least concept is the [**StorageClass**](https://kubernetes.io/docs/concepts/storage/storage-classes/) kind,
which is used to describe a storage resource (similar to include metadata or define several profiles).
A pod storage requirements can be configured either by defining size and access mode via *PVC*, or by defining the
needs in more abstract terms, using a *StorageClass*.

A Persistent Volume can be [provisioned
dynamically](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#provisioning) by means of a StorageClass
definition (using the parameter *provisioner*).

## Steps to mount an EFS resource in a Pod

Back to my original problem, how can I mount a disk for sharing state (binary files) between Pods?

Running a kubernetes cluster in AWS, it seems like [EFS](https://aws.amazon.com/efs/) is the natural choice.

Those are the steps I went through:

#### 1. Create an EFS resource and make it available to kubernetes nodes using aws cli

An **EFS resource** can be created executing the following command:

> aws efs create-file-system --creation-token efs-for-testing

The response is a JSON payload including a field named *FileSystemId*, which represents the unique identifier
that should be used to manage the EFS volume. Let's assume the *FileSystemId* is *fs-testing*.

EFS creation is an asynchronous process, and before managing it you need to make sure its LifeCycleState is
*available*. The EFS state can be checked as follows:

> aws efs describe-file-systems --file-system-id fs-testing

Once the EFS is available,  next step is creating a **mount target** associated to it. A mount target acts as a
virtual firewall, defining a subnet and a security group that is granted permissions to mount the EFS volume.

For creating the mount target you need the *subnet-id* and *security-groups* associated to your kubernetes cluster nodes.
Usual scenario is that every node will share the same security group, while subnet id will differ based on the Availability
Zone where the node is located:

> aws ec2 describe-instances --filters &lt;your-filters-to-retrieve-k8s-nodes&gt;

Per each SubnetId and SecurityGroupId execute the following command:

> aws efs create-mount-target \
    --file-system-id fs-testing \
    --subnet-id {SubnetId} \
    --security-groups {SecurityGroupId}

#### 2. Deploy the EFS provisioner

A Kubernetes deployment includes, by default, several
[Persistent Volume types](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes), like
AWSElasticBlockStore, GCEPersistentDisk, AzuleFile and NFS for naming a few. Each of them defines a
[specific provisioner](https://github.com/kubernetes/kubernetes/tree/a8e8e891f29e83362636dfdbed3e8cf768ba1862/pkg/volume)
that can be used to create a PV.

Furthermore, the kubernetes incubator [**external-storage repository**](https://github.com/kubernetes-incubator/external-storage)
holds additional Persistent Volumes that are not part of a Kubernetes default deployment, and here I found the
answer to my specific need: the
[**EFS provisioner**](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs).

The EFS provisioner is a [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) that runs
a container with access to the AWS EFS resource. It acts as an EFS broker, allowing other pods to mount the EFS
resource as a PV.

These are the definitions I used for deploying the EFS provisioner, even though you can find a
very similar definitions in [kubernetes-incubator github
repository](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs/deploy):

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: efs-provisioner
data:
  file.system.id: '<<your-efs-id>>'
  aws.region: '<<your-region-id>>'
  provisioner.name: mycompany.com/aws-efs

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
            server: <<your-efs-id>>.efs.<<your-region-id>>.amazonaws.com
            path: /
```

> kubectl apply -f efs-provisioner.yaml

#### 3. Define the StorageClass kind

StorageClass is used as an intermediate step for connecting a *PersistentVolumeClaim* with a specific storage resource:

- *metadata.name* field is used to refer to the resource.
- *provisioner* is used to identify the provisioner (EFS provisioner in this case).

**Important**: An StorageClass definition cannot be updated.

```yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: aws-efs
provisioner: mycompany.com/aws-efs
```

> kubectl apply -f storage-class.yaml

#### 4. Define the PersistentVolumeClaim

The **PVC** definition connects access mode and size requirements with a specific StorageClass item.
In this case, as EFS has unlimited storage, the size requested won't have any real impact.

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

> kubectl apply -f pvc.yaml

As soon as you create the PVC, the EFS provisioner will get notified and will create a PV that matches the requirements.
These are the EFS provisioner logs showing the PV creation:

    I0928 11:03:45.897983       1 controller.go:987] provision "default/efs" class "aws-efs": started
    I0928 11:03:45.900711       1 event.go:221] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"default", Name:"efs", UID:"2b56b224-c30e-11e8-abf5-023d3cfc37fe", APIVersion:"v1", ResourceVersion:"52345195", FieldPath:""}): type: 'Normal' reason: 'Provisioning' External provisioner is provisioning volume for claim "default/efs"
    I0928 11:03:45.950090       1 controller.go:1087] provision "default/efs" class "aws-efs": volume "pvc-2b56b224-c30e-11e8-abf5-023d3cfc37fe" provisioned
    I0928 11:03:45.950116       1 controller.go:1101] provision "default/efs" class "aws-efs": trying to save persistentvvolume "pvc-2b56b224-c30e-11e8-abf5-023d3cfc37fe"
    I0928 11:03:45.956467       1 controller.go:1108] provision "default/efs" class "aws-efs": persistentvolume "pvc-2b56b224-c30e-11e8-abf5-023d3cfc37fe" saved
    I0928 11:03:45.956498       1 controller.go:1149] provision "default/efs" class "aws-efs": succeeded
    I0928 11:03:45.956643       1 event.go:221] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"default", Name:"efs", UID:"2b56b224-c30e-11e8-abf5-023d3cfc37fe", APIVersion:"v1", ResourceVersion:"52345195", FieldPath:""}): type: 'Normal' reason: 'ProvisioningSucceeded' Successfully provisioned volume pvc-2b56b224-c30e-11e8-abf5-023d3cfc37fe

And now you can retrieve both PV and PVC using *kubectl*:

    kubectl get pv
    NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM         STORAGECLASS   REASON    AGE
    persistentvolume/pvc-2b56b224-c30e-11e8-abf5-023d3cfc37fe   1Gi        RWX            Delete           Bound     default/efs       aws-efs              4m

    kubectl get pvc
    NAME                        STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    persistentvolumeclaim/efs   Bound     pvc-2b56b224-c30e-11e8-abf5-023d3cfc37fe   1Gi        RWX            aws-efs        4m

#### 5. Create a Deployment with 2 replicas and mount the Volume

Pods get access to the PV storage by defining the claim as a volume in the Pod definition.
Claims must exist in the same namespace as the pods using the claim (StorageClass and
PersistentVolume are global kinds in the cluster).

The snippet below is a basic Deployment example with 2 pods mouting a volume using a PVC.
Each Pod will generate a single file in the shared folder and check that the folder has additional files, which
would reflect that indeed the other Pod has created its file.

```yaml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: test-efs
spec:
  replicas: 2
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: test-efs
    spec:
      restartPolicy: Always
      containers:
      - name: test-pod
        image: gcr.io/google_containers/busybox:1.24
        command:
          - "sh"
        args:
          - '-c'
          - 'touch "${MEDIA_PATH}/${MY_POD_NAME}"; echo "File created, waiting a bit to ensure the other Pod had the time as well"; sleep 5; [[ $(ls -l "$MEDIA_PATH" | wc -l) -gt 1 ]] && (echo "Both pods generated the file!" && exit 0) || (echo "Unable to create both files in the shared folder" && exit 1)'
        env:
          - name: MY_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MEDIA_PATH
            value: "/var/media/uploads"
        volumeMounts:
          - name: efs-pvc
            mountPath: "/var/media/uploads"
      volumes:
        - name: efs-pvc
          persistentVolumeClaim:
            claimName: efs
```

Checking the Pods logs we can see that the scenario is successfully validated:

    kubetail --selector app=test-efs
    Will tail 3 logs...
    test-efs-546d6d7456-2fvgp
    test-efs-546d6d7456-2gqx6
    test-efs-546d6d7456-pwkxp
    [test-efs-546d6d7456-2fvgp] File created, waiting a bit to ensure the other Pod had the time as well
    [test-efs-546d6d7456-2gqx6] File created, waiting a bit to ensure the other Pod had the time as well
    [test-efs-546d6d7456-2fvgp] Both pods generated the file!
    [test-efs-546d6d7456-2gqx6] Both pods generated the file!
