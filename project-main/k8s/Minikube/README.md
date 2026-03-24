# Minikube Deployment Strategy

Ce dossier contient des manifests et la procédure de test pour une place de développement local avec Minikube.

## 1) Pourquoi Minikube

- Environnement Kubernetes local et isolé.
- Pas besoin de GCP / coût cloud pour développement.
- Idéal pour tests livenessProbe, Jobs, PVCs, Service, Scaling.

## 2) Préparation

1. `minikube start`
2. `kubectl config use-context minikube`
3. `minikube addons enable metrics-server` (optionnel pour HPA)
4. choisir exposition:
   - `NodePort` pour accès local (via `minikube service ... --url`)
   - ou `LoadBalancer` + `minikube tunnel`

## 3) Construction des images locales

```powershell
minikube image build -t vote:local ./vote
minikube image build -t result:local ./result
minikube image build -t worker:local ./worker
minikube image build -t seed-data:local ./seed-data
```

## 4) Appliquer les manifests

- `kubectl apply -f redis-configmap-dev.yaml`
- `kubectl apply -f redis-service-dev.yaml`
- `kubectl apply -f redis-deployment-dev.yaml`
- `kubectl apply -f postgres-configmap-dev.yaml`
- `kubectl apply -f postgres-pvc-dev.yaml`
- `kubectl apply -f postgres-service-dev.yaml`
- `kubectl apply -f postgres-deployment-dev.yaml`
- `kubectl apply -f worker-deployment-dev.yaml`
- `kubectl apply -f vote-deployment-dev.yaml`
- `kubectl apply -f vote-service-dev.yaml`
- `kubectl apply -f result-deployment-dev.yaml`
- `kubectl apply -f result-service-dev.yaml`
- `kubectl apply -f seed-job-dev.yaml`

## 5) Vérification

- `kubectl get all,pvc`
- `kubectl logs deployment/vote`, `deployment/result`, `pod/<seed-pod>`
- `minikube service vote --url`, `minikube service result --url`

---

## 6) Remarques d’images

- `imagePullPolicy: Never` pour images `*-local`.
- Les images Redis/Postgres peuvent rester `redis:alpine`, `postgres:15-alpine`.

## 7) Fichiers optionnels désactivés

- `seed-cronjob-dev.disabled`
- `nginx-deployment-dev.disabled`
- `nginx-service-dev.disabled`

Ils sont désactivés volontairement pour éviter des conflits avec le rendu Kubernetes demandé au README (version obligatoire uniquement).
