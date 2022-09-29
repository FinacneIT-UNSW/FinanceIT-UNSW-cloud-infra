FUNCTIONS_PATH = ./functions
ZIP_PATH = ./lambdas_archives

all: zip_lambdas apply_infra

zip_lambdas:
	$(foreach file, $(wildcard $(FUNCTIONS_PATH)/*), zip $(ZIP_PATH)/$(basename $(notdir $(file))).zip $(file);)

apply_infra:
	terraform -chdir=infra init
	terraform -chdir=infra validate
	terraform -chdir=infra apply