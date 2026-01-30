# docker-with-s3fs-volume
1. Install s3fs and NFS Server:

Ensure s3fs and the NFS server are installed on your host machine.

```console

```

https://github.com/s3fs-fuse/s3fs-fuse

```console

```

2. Mount MinIO Bucket Using s3fs:

Add the following line to the password.txt file:
```text
minioadmin:minioadmin
```

```console
chmod 600 /path/to/password.txt
```
```console
sudo mkdir -p /mnt/minio-nginx

sudo s3fs nginx-data /mnt/minio-nginx -o passwd_file=password.txt,use_path_request_style,url=http://localhost:9000,uid=1000,gid=1000,allow_other,nonempty,mp_umask=002,logfile=/var/log/s3l

sudo s3fs nginx-data /mnt/minio-nginx -o passwd_file=password.txt,use_path_request_style,url=http://localhost:9000,uid=1000,gid=1000,allow_other,nonempty,mp_umask=002,logfile=/var/log/s3l

```

Assume that nginx-data bucket exists on minio

If you want unmount , do this

```console
 umount /mnt/minio-nginx
```

3. (optional) Create external docker volume for

```console
docker volume create minio_nginx_volume --opt type=none --opt device=/mnt/minio-nginx --opt o=bind
```

3. (optional) Share the Mounted Directory via NFS:

Install the NFS server if it's not already installed:
```console
sudo apt-get install nfs-kernel-server

sudo nano /etc/exports

```

Add the following line to share the /mnt/minio directory:
```text
/mnt/minio *(rw,sync,no_subtree_check)
```

Restart the NFS server to apply the changes:

```console
sudo systemctl restart nfs-kernel-server
```

3. Access the NFS Share

On the client machine, install the NFS client if it's not already installed:

```console
sudo apt-get install nfs-common
```

Mount the NFS share:
```console
sudo mount <server_ip>:/mnt/minio /path/to/mount/point
```