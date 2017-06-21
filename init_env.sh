#!/bin/bash

#---------------------------------------------------------------------------------------------------
# docker

export mongo_name='mongo'
function run_mongo() {
    docker run -d \
        --name ${mongo_name} \
        -p 27017:27017 \
        ${mongo_name}
}

export app_name='notes'
export database_url='mongodb://192.168.0.6/noddy_facts_dev'
function run_notes() {
    docker run -d \
        --name ${app_name} \
        -p 3000:3000 \
        templecloud/noddy-reagent-mongo \
        -Ddatabase-url=${database_url} -jar /app.jar
}

#---------------------------------------------------------------------------------------------------
# glcoud

export gpid='trjl-158912'
export k8s_name='k8s-cluster'
export k8s_zone='europe-west1-b'
export k8s_machine_type='f1-micro'

function gcloud_login() {
    gcloud auth login
    gcloud components update
	gcloud config set project ${gpid}
}

function gcloud_cluster_login() {
    gcloud container clusters \
        get-credentials ${k8s_name}\
        --project ${gpid} \
        --zone ${k8s_zone}
}

function gcloud_cluster_create() {
	gcloud container \
  		--project ${gpid} \
  	clusters create ${k8s_name} \
  		--zone ${k8s_zone} \
  		--machine-type ${k8s_machine_type} \
  		--num-nodes "3" \
  		--network "default"
}

function gcloud_cluster_destroy() {
	gcloud container \
  		--project ${gpid} \
  	clusters delete ${k8s_name} \
  		--zone ${k8s_zone}
}

function gcloud_forwarding_rules() {
	gcloud compute forwarding-rules list
}

export k8s_disk01_name='mongo-disk'
export k8s_disk01_size=200GB

function gcloud_disk_create() {
	gcloud compute disks create \
		--project ${gpid} \
		--zone ${k8s_zone} \
		--size 200GB \
		${k8s_disk01_name}
}

function gcloud_disk_destroy() {
	gcloud compute disks delete \
		--zone ${k8s_zone} \
		${k8s_disk01_name}
}


#---------------------------------------------------------------------------------------------------
# kubectl

function k8s_deploy() {
	kubectl create -f mongo-controller.yml
	kubectl create -f mongo-service.yml
	kubectl create -f notes-app-controller.yml
	kubectl create -f notes-app-service.yml
    gcloud_forwarding_rules
}

function k8s_clean() {
	kubectl delete svc,rc,po --all
}


#---------------------------------------------------------------------------------------------------
# top-level

function k8s_up() {
    gcloud_cluster_create
    gcloud_disk_create
}

function k8s_down() {
    gcloud_cluster_destroy
    gcloud_disk_destroy
}

