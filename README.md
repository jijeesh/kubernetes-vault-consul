# Running Vault and Consul on Kubernetes

## Want to use this project?

### Prerequisites

Install:

1. [Go](https://golang.org/doc/install)
1. CloudFlare's [SSL ToolKit](https://github.com/cloudflare/cfssl) (`cfssl` and `cfssljson`)
1. [Consul](https://www.consul.io/docs/install/index.html)
1. [Vault](https://www.vaultproject.io/docs/install/)
1. [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

### Minikube

Start the cluster:

```sh
$ minikube start --vm-driver=virtualbox
$ minikube dashboard
```
Once installed, create a workspace, configure the GOPATH and add the workspace's bin folder to your system path:
```
$ mkdir $HOME/go
$ export GOPATH=$HOME/go
$ export PATH=$PATH:$GOPATH/bin
```
Next, install the SSL ToolKit:

```
$ go get -u github.com/cloudflare/cfssl/cmd/cfssl
$ go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```

### TLS Certificates

Create a Certificate Authority:

```sh
$ cfssl gencert -initca certs/config/ca-csr.json | cfssljson -bare certs/ca
```

Create the private keys and TLS certificates:

```sh
$ cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/config/ca-config.json \
    -profile=default \
    certs/config/consul-csr.json | cfssljson -bare certs/consul
```
Do the same for Vault:
```
$ cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/config/ca-config.json \
    -profile=default \
    certs/config/vault-csr.json | cfssljson -bare certs/vault
```
You should now see the following PEM files within the "certs" directory:

```
ca-key.pem
ca.pem
consul-key.pem
consul.pem
vault-key.pem
vault.pem
```

### Vault and Consul

Spin up Vault and Consul on Kubernetes:

```sh
$ sh create.sh
```
Forward the port to the local machine for consul:
```
$ kubectl -n vault port-forward consul-1 8500:8500
```
### Environment Variables

In a new terminal window, navigate to the project directory and set the following environment variables:

```sh
$ export VAULT_ADDR=https://127.0.0.1:8200
$ export VAULT_CACERT="certs/ca.pem"
```

### Verify

```sh
$ kubectl get pods
$ vault status
```


## Want to learn how to build this?

Check out the [post](https://testdriven.io/running-vault-and-consul-on-kubernetes).
