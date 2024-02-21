# Steps

1) Install Terraform
   
2) GCP CLI:
   
        gcloud init

    (Note: Do not select any projects)

3) Authenticate: 
  
        gcloud auth login

4) Create and set Terraform up to use our current login:

        PROJECT_ID=cloud-${RANDOM}
        gcloud projects create $PROJECT_ID --set-as-default

        gcloud auth application-default login

5) Associate the billing for the new project 
   
6) Enable required APIs 
   
        gcloud services enable compute.googleapis.com

7) Initialize terraform
        
        terraform init

(Note: It downloads the provider)

8) Plan & Apply
        
        terraform plan
        terraform apply

9) At end of the provisioning
        
        gcloud auth revoke

        gcloud auth application-default revoke
