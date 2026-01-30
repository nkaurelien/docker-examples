# Pushing to this Registry


After you pull or build an image:


```console

docker tag <someimage> 192.168.0.201:25000/<someimage>:<tag>
docker push 192.168.0.201:25000/<someimage>:<tag>

```

# Insecure Registries

If this registry is insecure and doesn't hide behind SSL certificates then you will need to configure your Docker client to allow pushing to this insecure registry.
Linux

Edit or you may even need to create the following file on your Linux server:


```console
sudo nano /etc/docker/daemon.json

```

And save the following content:

```text
{
  "insecure-registries": [
    "192.168.0.201:25000"
  ]
}

```
You will need to restart your Docker service before these changes will take effect.