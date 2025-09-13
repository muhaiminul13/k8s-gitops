# k8s-gitops

A GitOps setup for managing Kubernetes clusters, applications, and secrets using **FluxCD**.

---

## Table of Contents

- [About](#about)  
- [Repository Structure](#repository-structure)  
- [Prerequisites](#prerequisites)  
- [Getting Started](#getting-started)  
- [FluxCD Setup](#fluxcd-setup)  
- [Managing Secrets](#managing-secrets)  
- [Encryption Keys](#encryption-keys)  
- [Environments / Clusters](#environments--clusters)  
- [Contributing](#contributing)  
- [License](#license)  

---

## About

This repository is used to manage Kubernetes cluster configurations, applications, and secrets using a **GitOps workflow** powered by **FluxCD**.  

With GitOps:
- All changes are declarative (stored in Git).  
- FluxCD continuously reconciles the cluster state with the Git repository.  
- No manual `kubectl apply` for applications — Flux ensures consistency automatically.  

---

## Repository Structure
├── clusters/
│ └── local/ # Definitions for the “local” cluster environment
├── apps/ # Application manifests (nginx, wordpress, mysql, etc.)
├── age.key # Private key for Age encryption
├── age.pub # Public key for Age encryption
├── mysql-secret.sops.yaml # Encrypted secret (for MySQL) using SOPS / Age
└── README.md # This file


- `clusters/local/` — manifests, configuration files for the “local” cluster  
- `apps/` — applications like NGINX, WordPress, MySQL, ingress-nginx, monitoring, etc.  
- `age.key` / `age.pub` — Age keypair for encryption/decryption  
- `mysql-secret.sops.yaml` — example of an encrypted secret

---

## Prerequisites

To use this setup, you’ll need:

- Kubernetes cluster (k3s, kind, minikube, or cloud provider)  
- `kubectl` to interact with the cluster  
- `flux` CLI (for installation & reconciliation)  
- `sops` (to manage encrypted secrets)  
- `age` for encryption key management  
- Git  

---

## Getting Started

1. Clone this repository:

    ```bash
    git clone git@github.com:muhaiminul13/k8s-gitops.git
    cd k8s-gitops
    ```

2. Import / configure your Age keys:

    ```bash
    mkdir -p ~/.config/sops/age
    cp age.key ~/.config/sops/age/keys.txt
    ```

3. Decrypt secrets to view or modify:

    ```bash
    sops --decrypt mysql-secret.sops.yaml > mysql-secret.yaml
    ```

4. Make changes, then commit & push. Flux will sync them to the cluster.

---

## FluxCD Setup

1. **Bootstrap FluxCD** in your cluster with your GitHub repo:

    ```bash
    flux bootstrap github \
      --owner=muhaiminul13 \
      --repository=k8s-gitops \
      --branch=main \
      --path=clusters/local \
      --personal
    ```

   This installs Flux controllers and points them at the `clusters/local/` path.

2. **Reconcile resources manually** (optional, if you want to force sync):

    ```bash
    flux reconcile kustomization apps -n flux-system
    flux reconcile kustomization monitoring -n flux-system
    ```

3. **Check Flux status**:

    ```bash
    flux get kustomizations -A
    flux get sources git -A
    ```

4. Flux will now continuously monitor and apply changes from this repository.

---

## Managing Secrets

- All secrets are encrypted with **SOPS + Age**.  
- Never commit plaintext secrets.  
- To update a secret:  
  ```bash
  sops mysql-secret.sops.yaml


(this opens an editor to edit decrypted values, then re-encrypts automatically).

Encryption Keys

age.pub — public key (safe to share, used to encrypt)

age.key — private key (must remain secret, required to decrypt)

Keep your private key backed up securely. If it is lost, encrypted secrets cannot be recovered.

Environments / Clusters

Currently included:

clusters/local/ → local development cluster

You can add more environments:

clusters/staging/
clusters/production/


Each environment can have its own apps, secrets, and Flux configurations.

Contributing

If you’d like to contribute:

Fork this repo

Create a feature branch (git checkout -b feature/my-change)

Make changes (ensuring secrets are encrypted)

Commit & push

Open a PR
Here’s a high-level look at what lives in this repo:

