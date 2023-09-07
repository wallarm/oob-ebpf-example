include .env

RANDOM := $(shell echo $$RANDOM)
KUBE_VERSION ?= 1.26.3
KUBE_NODES   ?= 3
APP_HOST     ?= ebpf-v2-demo.com
TF_ARGS := \
	-var wallarm_api_token=${WALLARM_API_TOKEN} \
	-var wallarm_api_host=${WALLARM_API_HOST} \
	-var kubernetes_version=$(KUBE_VERSION) \
	-var node_count=$(KUBE_NODES) \
	-var app_host=$(APP_HOST)
TF_DIR  := -chdir=$(CURDIR)/terraform
CLUSTER = $(shell terraform ${TF_DIR} output -raw cluster_name)
LB_IP   = $(shell kubectl get svc -l "app.kubernetes.io/component=controller" -n ingress-nginx -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

all: init apply get-config

init:
	cd ${CURDIR}/terraform && terraform init

apply:
	@terraform ${TF_DIR} apply ${TF_ARGS} --auto-approve

get-config:
	az aks get-credentials --admin --name ${CLUSTER} -g ${CLUSTER}

attack-https:
	curl -k -H "Host: ${APP_HOST}" https://${LB_IP}/anything/etc/passwd/$(RANDOM)/attack-ssl --http1.1

attacks-https:
	wrk -H "Host: ${APP_HOST}" -d 30 -c 1 -t 1 https://${LB_IP}/anything/etc/passwd/$(RANDOM)/attacks-ssl

destroy:
	terraform ${TF_DIR}  destroy ${TF_ARGS} --auto-approve
