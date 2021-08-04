# Deploying Jenkins on K8s using Configuration As Code

# Jenkins operator

Jenkins-Operator deployment on Kubernetes.

The following installation steps are based on the official operator documentation: [https://jenkinsci.github.io/kubernetes-operator/](https://jenkinsci.github.io/kubernetes-operator/)

## 1. Requirements

To run Jenkins Operator, you will need:

- access to a **Kubernetes** cluster version **1.11+**
- **kubectl** version **1.11+**


## 2. Configure Custom Resource Definition

A custom resource is an extension of the Kubernetes API that is not necessarily available in a default Kubernetes installation. It represents a customization of a particular Kubernetes installation. However, many core Kubernetes functions are now built using custom resources, making Kubernetes more modular. In our case it'll allow us to create the kind `Jenkins` which is how the Operator recognizes Jenkins instances.

Create a namespace for the jenkins project:

    kubectl create -f namespace.yaml

Install Jenkins Custom Resource Definition:

    kubectl -n jenkins apply -f jenkins_crd.yaml


## 3. Deploy Jenkins Operator Using YAML’s

Apply Service Account and RBAC roles (Jenkins Operator):

    kubectl -n jenkins apply -f operator.yaml

Watch Jenkins Operator instance being created:

    kubectl -n jenkins get pods -w


## 4. Add some initial jenkins configurations (ConfigMap)

Since we are interested in utilizing Github for authentication and to connect our projects to the Jenkins instances we must configure jenkins adding a ConfigMap to modify the way the operator will interact with the jenkins instances we launch. In this case we must provide the operator with certain information. This information consists of modifying the authentication method (to use the Github plugin) and establish certain permissions to users:

    kubectl -n jenkins apply -f operator-github-configmap.yaml


## 5. Add kubernetes Secrets

Usernames and their passwords, as also slack chat access:

    kubectl -n jenkins apply -f github-conf-secrets.yaml

**It is important to note that section 4. and 5. will be further explained in the sections *Github-oauth plugin* and *Github plugin*.**

## 6. Create PVC

Run the following command to create a new volume to store backup data:

    kubectl -n jenkins create -f pvc.yaml

## 7. Deploy Jenkins Instance

Once Jenkins Operator is up and running let’s deploy the Jenkins instance:

    kubectl -n jenkins create -f jenkins_vanilla.yaml


# Github-oauth plugin

In order to enable authentication via the oauth plugin one must first have an organization created. Github allows users to create organizations in a user's settings page. Once created, an app must be registered under the organization's name. This app will be the "entrypoint" from which we will authenticate users. The Github App gives users the possiblity to use oauth tokens as a way to authenticate the identity of a user. The admin must create a token and save the ID and the Secret in order for users to gain access once the setup has been done. It is also necessary for the admin to specify the Homepage URL as well as the authorization callback URL (which must end in /securityRealm/finishLogin).

Since the setup must take into consideration security, the token Secret is passed to the instance via a K8s Secret. The Secret is managed by the operator and doesn't need to be written into a deployment's YAML file. Instead, a configmap can be used for the operator and have it manage the Secret as an environment variable to be passed to the pods it manages. This configuration can be seen in the `operator-github-configmap.yaml` where environment variables are passed to the jenkins instance in the github configuration section.

# Github plugin

This plugin will utilize the organization that was previously created. The plugin will utilize the webhook functions that Github provides under organizations. The admin must register an endpoint where the Jenkins instance will be listening for the webhook. This is done under the organization's repository that contains the code for the jenkins instance. The Setup steps are:

1. Go to the organization's repository with the code for the project.
2. Go to Settings and then navigate to Webhooks.
3. Once in webhooks the admin must specify the PayloadURl (which must end in /github-webhook/).
4. The admin can now specify what events can trigger the webhook, like for example push events.

## Create a personal access token for Jenkins

The following [article](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) on the GitHub page shows step by step how to obtain a personal access token in order for a user to connect the GitHub plugin in Jenkins with the GitHub platform where our project is stored.

It is important to take into account that the project needs the user to define the scopes of this token's usage.
Jenkins’ scope requirements depends on the task/s you wish like to perform:

- admin:repo_hook - For managing hooks at GitHub Repositories level including for Multibranch Pipeline
- admin:org_hook - For managing hooks at GitHub Organizations level for GitHub Organization Folders
- repo - to see private repos. Please note that this is a parent scope, allowing full control of private repositories that includes:
- repo:status - to manipulate commit statuses
- repo:﻿repo_deployment - to manipulate deployment statuses
- repo:﻿﻿public_repo - to access to public repositories
- read:org and user:email - recommended minimum for GitHub OAuth Plugin scopes.

Once this token has been created it is important to


## Creating an organization project in Jenkins

 In order to implement the previous steps one must create a GitHub organization project in Jenkins. Inside this Organization Project the user must go to the Porjects section and fill out the fields like  in the following Screenshot. It is important that the API endpoint is set to <https://api.github.com> unless GitHub enterprise is being used. The Credentials will be automatically loaded by the configuration used with the Operator (see `operator-github.configmap.yaml`), and the owner must be set to the Organization's name. It is important to note that only username with password credentials are supported.

<p align="center">
    <img src=https://github.com/jenkinsOperator/dummy-pipeline/blob/main/imgs/manage_jenkins.png>
</p>

This setup is enough to create a working Jenkins master instance that is capable of automatically listening to a GitHub repository and can authenticate users in an organization.
