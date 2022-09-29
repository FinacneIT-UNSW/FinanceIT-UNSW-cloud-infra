FUNCTIONS_PATH = ./functions
ZIP_PATH = ./lambdas_archives

all: zip_lambdas deploy

zip_lambdas:
	$(foreach file, $(wildcard $(FUNCTIONS_PATH)/*), zip $(ZIP_PATH)/$(basename $(notdir $(file))).zip $(file);)

deploy:
	terraform init
	terraform validate
	terraform apply -var-file="config.tfvars"
	terraform output > variables.out

destroy:
	terraform destroy