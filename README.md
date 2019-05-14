# CEN Scaler
This project helps to automatically scale Cloud Enterprise Network (CEN) bandwidth packages based on different metrics and timing events. It ships together with Alibaba Cloud Function code and Terraform templates that set up all neccessary configurations and services to get you going fast.

# Installation and Usage
CEN Scaler is composed of two different parts: 
- The NodeJS based Alibaba Cloud Function Compute code that is responsible for scaling the bandwidth of your CEN instance at predefined points in time 
- The Terraform scripts that setup everything in your Alibaba Cloud account to make the automatic scaling work. This includes uploading and configuring the Function Compute code and configuring the minimal access rights and permissions for it to change the bandwidth on your behalf.    
## NPM
In order to install the neccessary dependencies of the Alibaba Cloud Function Compute code you need to have [NPM](https://www.npmjs.com/get-npm) installed on your machine. This repository does not include the depending node modules.
Once installed please run the following command in the `src` folder of this project:
`$ npm install`
 
 This will install all neccessary dependencies of the Alibaba Cloud Function Compute project on your local machine into `src/node_modules`. This will be bundled into a zip file later and uploaded into the cloud.

## Terraform
 HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.
 CEN-Scaler uses Terraform scripts to automatically setup and configure the entire environment in your Alibaba Cloud account. All ressources that CEN-Scaler creates for you do not incur any costs.

 To install Terraform on your machine please refer to [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).

 After you have installed it, please make sure to configure it accordingly with your Alibaba Cloud Access Key and Secret. Make sure that its permission include full access to Function Compute and Resource Access Management (RAM):
```bash
$ export ALICLOUD_ACCESS_KEY=<your_access_key>
$ export ALICLOUD_SECRET_KEY=<your_secret_key>
$ export ALICLOUD_REGION=eu-central-1 (or any other region which supports Function Compute)
```
 
 Then change to the `terraform/` directory and run
 ```bash
$ terraform init
$ terraform apply
```
This will configure Terraform accordingly for use with Alibaba Cloud and then execute the scripts. 

## Terraform Scripts
Before you can actually install CEN Scaler in your account you need to make some configuration changes in the scripts:
- Edit `terraform/variables.tf`: Change the variable `cen_id` to your CEN-Instance ID ([see here](https://github.com/arafato/CEN-Scaler/blob/master/terraform/variables.tf#L3))
- Edit `terraform/timebased.tf`: Adapt the Alibaba Cloud Function Compute event triggers to your specific needs in terms of number and also time spans ([see here](https://github.com/arafato/CEN-Scaler/blob/master/terraform/timebased.tf)).   

### Example
The default example of this project as configured in `terraform/timebased.tf` defines the following scenario:
- As defined by trigger `triggerscale_1`: Starting every Monday at 6am the CEN bandwidth is upscaled to 20 MBits. This bandwidth is then equally distributed between two region connections (each 10 MBits): `eu-central-1` <-> `cn-bejing`and `eu-central-1` <-> `cn-shanghai`. 
- As defined by trigger `triggerscale_2`: Starting every Saturday at 6am the CEN bandwidth is downscaled to 10 MBits. This bandwidth is then equally distributed between two region connections (each 5 MBits): `eu-central-1` <-> `cn-bejing`and `eu-central-1` <-> `cn-shanghai`.

This example scenario can be adapted to different timespans by changing the value of `cronExpression`. You can use [http://www.cronmaker.com/](http://www.cronmaker.com/) to easily generate cron expressions that fit your requirement. You can also add (or remove) triggers to accomodate for your specific scenario. Same is true for the number of region connections which can be extended or reduced as needed.  
 
# How it works


# Contributions
## What do I need to know to help?
If you are interested in making a code contribution and would like to learn more about the technologies that we use, check out the list below.

- Alibaba Cloud
- Alibaba Cloud Function Compute
- Terraform 

## How do I make a contribution?

Never made an open source contribution before? Wondering how contributions work in CEN-Scaler? Here's a quick rundown!

1. Find an issue that you are interested in addressing or a feature that you would like to add.

2. Fork the Azurite repository to your local GitHub organization. This means that you will have a copy of the repository under `your-GitHub-username/CEN-Scaler`.

3. Clone the repository to your local machine using git clone `https://github.com/github-username/cen-scaler.git`.

4. Create a new branch for your fix using `git checkout -b branch-name-here`.
Make the appropriate changes for the issue you are trying to address or the feature that you want to add.

5. Use `git add insert-paths-of-changed-files-here` to add the file contents of the changed files to the "snapshot" git uses to manage the state of the project, also known as the index.

6. Use `git commit -m "Insert a short message of the changes made here"` to store the contents of the index with a descriptive message.

7. Push the changes to the remote repository using `git push origin branch-name-here`.

8. Submit a pull request to the upstream repository.
Title the pull request with a short description of the changes made and the issue or bug number associated with your change. For example, you can title an issue like so "Added more log outputting to resolve #4352".
In the description of the pull request, explain the changes that you made, any issues you think exist with the pull request you made, and any questions you have for the maintainer. It's OK if your pull request is not perfect (no pull request is), the reviewer will be able to help you fix any problems and improve it!

9. Wait for the pull request to be reviewed by a maintainer.
Make changes to the pull request if the reviewing maintainer recommends them.

10. Celebrate your success after your pull request is merged!

## Where can I go for help?
If you need help, you can ask questions directly at our [issues site on Github](https://github.com/arafato/cen-scaler/issues).

