# Deploying Jenkins on K8s using Configuration As Code

# Jenkins operator

# Github oauth plugin

In order to enable authentication via the oauth plugin one must first have an organization created. Github allows users to create organizations in a user's settings page. Once created, an app must be registered under the organization's name. This app will be the "entrypoint" from which we will authenticate users. The Github App gives users the possiblity to use oauth tokens as a way to authenticate the identity of a user. The admin must create a token and save the ID and the Secret in order for users to gain access once the setup has been done. It is also necessary for the admin to specify the Homepage URL as well as the authorization callback URL (which must end in /securityRealm/finishLogin).

Since the setup must take into consideration security, the token Secret is passed to the instance via a K8s Secret. The Secret is managed by the operator and doesn't need to be written into a deployment's YAML file. Instead, a configmap can be used for the operator and have it manage the Secret as an environment variable to be passed to the pods it manages. This configuration can be seen in the `operator-github-configmap.yaml` where environment variables are passed to the jenkins instance in the github configuration section.

# Github plugin

This plugin will utilize the organization that was previously created. The plugin will utilize the webhook functions that Github provides under organizations. The admin must register an endpoint where the Jenkins instance will be listening for the webhook. This is done under the organization's repository that contains the code for the jenkins instance. The Setup steps are:

1. Go to the organization's repository with the code for the project.
2. Go to Settings and then navigate to Webhooks.
3. Once in webhooks the admin must specify the PayloadURl (which must end in /github-webhook/).
4. The admin can now specify what events can trigger the webhook, like for example push events.

## Create a personal access token for Jenkins

## Creating an organization project in Jenkins

<p align="center">
    <img src=https://github.com/jenkinsOperator/dummy-pipeline/imgs/manage_jenkins.png>
</p>
