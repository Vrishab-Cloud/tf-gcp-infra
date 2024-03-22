# Steps

1) Install Terraform
   
2) GCP CLI:
   
        gcloud init

    (Note: Do not select any projects)

3) Authenticate: 
  
        gcloud auth login

4) Create and set Terraform up to use our current login:

        PROJECT_ID=dev-${RANDOM}
        gcloud projects create $PROJECT_ID --set-as-default

        gcloud auth application-default login

5) Associate the billing for the new project 
   
6) Enable required APIs 
   
        gcloud services enable compute.googleapis.com --project=$PROJECT_ID

        gcloud services enable servicenetworking.googleapis.com --project=$PROJECT_ID

        gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID

        gcloud services enable cloudfunctions.googleapis.com --project=$PROJECT_ID

        gcloud services enable pubsub.googleapis.com --project=$PROJECT_ID

        gcloud services enable eventarc.googleapis.com --project=$PROJECT_ID

        gcloud services enable  run.googleapis.com --project=$PROJECT_ID

7) Initialize terraform
        
        terraform init

(Note: It downloads the provider)

8) Plan & Apply
        
        terraform plan
        terraform apply

9) At end of the provisioning
        
        gcloud auth revoke

        gcloud auth application-default revoke
